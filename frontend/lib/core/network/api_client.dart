import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import '../auth/auth_models.dart';
import 'dio_setup.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorage _storage;
  Future<void>? _refreshInFlight;

  ApiClient(this._storage) {
    final baseUrl =
        dotenv.env['API_BASE_URL'] ?? dotenv.env['BASE_URL'] ?? AppConstants.apiBaseUrl;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    configureDioHttpClient(_dio);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['skipAuthRefresh'] == true) {
            // Still attach Authorization header if we have it; just skip refresh logic.
            final token = await _storage.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          }

          // If we have a token and it is expired (or about to expire), refresh before sending.
          final accessExp = await _storage.getAccessTokenExpiresAt();
          final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final isExpiredOrNearExpiry =
              accessExp != null && accessExp <= (nowSeconds + 5);
          if (isExpiredOrNearExpiry) {
            try {
              await _refreshTokens();
            } catch (_) {
              // If refresh fails, proceed with the original request; onError(401) will handle.
            }
          }

          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Quiet by default; errors are logged in onError.
          return handler.next(response);
        },
        onError: (error, handler) async {
          try {
            final statusCode = error.response?.statusCode;
            final uri = error.requestOptions.uri;
            final method = error.requestOptions.method;

            final headers = Map<String, dynamic>.from(error.requestOptions.headers);
            if (headers.containsKey('Authorization')) {
              headers['Authorization'] = 'Bearer <redacted>';
            }

            String stringify(dynamic data) {
              if (data == null) return 'null';
              if (data is String) return data;
              if (data is Map || data is List) {
                try {
                  return jsonEncode(data);
                } catch (_) {
                  return data.toString();
                }
              }
              return data.toString();
            }

            log(
              '✕ REQUEST ERROR [$method] $uri\n'
              'Type: ${error.type}\n'
              'Message: ${error.message}\n'
              'Cause: ${error.error}\n'
              'Status: $statusCode\n'
              'Request headers: $headers\n'
              'Request data: ${stringify(error.requestOptions.data)}\n'
              'Response data: ${stringify(error.response?.data)}',
              name: 'ApiClient',
            );
          } catch (_) {
            // Never fail the request flow due to logging.
          }

          final statusCode = error.response?.statusCode;
          final requestOptions = error.requestOptions;

          final shouldSkip = requestOptions.extra['skipAuthRefresh'] == true;
          final alreadyRetried = requestOptions.extra['authRetry'] == true;

          if (statusCode == 401 && !shouldSkip && !alreadyRetried) {
            try {
              await _refreshTokens();

              final newToken = await _storage.getToken();
              final opts = Options(
                method: requestOptions.method,
                headers: Map<String, dynamic>.from(requestOptions.headers),
                responseType: requestOptions.responseType,
                contentType: requestOptions.contentType,
                followRedirects: requestOptions.followRedirects,
                receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
                validateStatus: requestOptions.validateStatus,
                sendTimeout: requestOptions.sendTimeout,
                receiveTimeout: requestOptions.receiveTimeout,
                extra: Map<String, dynamic>.from(requestOptions.extra)
                  ..['authRetry'] = true,
              );

              if (newToken != null && newToken.isNotEmpty) {
                opts.headers ??= <String, dynamic>{};
                opts.headers!['Authorization'] = 'Bearer $newToken';
              }

              final retryResponse = await _dio.request(
                requestOptions.path,
                data: requestOptions.data,
                queryParameters: requestOptions.queryParameters,
                options: opts,
                cancelToken: requestOptions.cancelToken,
                onReceiveProgress: requestOptions.onReceiveProgress,
                onSendProgress: requestOptions.onSendProgress,
              );
              return handler.resolve(retryResponse);
            } catch (_) {
              // Refresh failed; fall through to logout behavior below.
            }
          }

          if (statusCode == 401) {
            await _storage.clearAll();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return await _dio.put(path, data: data, options: options);
  }

  Future<Response> delete(String path, {Options? options}) async {
    return await _dio.delete(path, options: options);
  }

  Future<void> _refreshTokens() async {
    if (_refreshInFlight != null) return _refreshInFlight!;

    final completer = Completer<void>();
    _refreshInFlight = completer.future;

    try {
      final accessToken = await _storage.getToken();
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        throw StateError('Missing refresh token');
      }

      // Use a separate Dio instance to avoid interceptor recursion.
      final refreshDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null && accessToken.isNotEmpty)
            'Authorization': 'Bearer $accessToken',
        },
      ));

      final response = await refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );

      final data = (response.data is Map<String, dynamic>)
          ? (response.data as Map<String, dynamic>)
          : <String, dynamic>{};

      final newAccessToken = (data['access_token'] ??
              data['accessToken'] ??
              data['access-token'])
          ?.toString();
      final newRefreshToken = (data['refresh_token'] ??
              data['refreshToken'] ??
              data['refresh-token'])
          ?.toString();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        throw FormatException('Missing access token in refresh response');
      }
      if (newRefreshToken == null || newRefreshToken.isEmpty) {
        throw FormatException('Missing refresh token in refresh response');
      }

      // Persist tokens first.
      await _storage.saveToken(newAccessToken);
      await _storage.saveRefreshToken(newRefreshToken);

      // Persist new expirations.
      final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expiresInRaw = data['expires_in'];
      final refreshExpiresInRaw = data['refresh_expires_in'];
      final expiresIn = expiresInRaw is int
          ? expiresInRaw
          : int.tryParse(expiresInRaw?.toString() ?? '');
      final refreshExpiresIn = refreshExpiresInRaw is int
          ? refreshExpiresInRaw
          : int.tryParse(refreshExpiresInRaw?.toString() ?? '');

      if (expiresIn != null && expiresIn > 0) {
        await _storage.saveAccessTokenExpiresAt(nowSeconds + expiresIn);
      } else {
        // Fallback: decode JWT exp if server didn't provide expires_in.
        try {
          final authUser = AuthUser.fromAccessToken(newAccessToken);
          await _storage.saveAccessTokenExpiresAt(authUser.exp);
        } catch (_) {}
      }

      if (refreshExpiresIn != null && refreshExpiresIn > 0) {
        await _storage.saveRefreshTokenExpiresAt(nowSeconds + refreshExpiresIn);
      }

      completer.complete();
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      _refreshInFlight = null;
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});
