import 'dart:developer';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import 'dio_setup.dart';
import 'network_exceptions.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

class DioClient {
  late final Dio _dio;

  DioClient() {
    final baseUrl =
        dotenv.env['API_BASE_URL'] ?? dotenv.env['BASE_URL'] ?? AppConstants.apiBaseUrl;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: 15000),
        receiveTimeout: const Duration(milliseconds: 15000),
        responseType: ResponseType.json,
      ),
    );
    configureDioHttpClient(_dio);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final headers = Map<String, dynamic>.from(options.headers);
          if (headers.containsKey('Authorization')) {
            headers['Authorization'] = 'Bearer <redacted>';
          }

          dynamic requestData = options.data;
          if (requestData is Map) {
            requestData = Map<String, dynamic>.from(requestData);
            for (final key in ['password', 'refresh_token', 'access_token']) {
              if (requestData.containsKey(key)) {
                requestData[key] = '<redacted>';
              }
            }
          }

          log(
            '→ REQUEST ${options.method} ${options.uri}\n'
            'Headers: $headers\n'
            'Query: ${options.queryParameters}\n'
            'Body: $requestData',
            name: 'DioClient',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log(
            '← RESPONSE ${response.statusCode} ${response.requestOptions.uri}',
            name: 'DioClient',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final res = e.response;
          final statusCode = res?.statusCode;
          final uri = e.requestOptions.uri;
          final method = e.requestOptions.method;

          final headers = Map<String, dynamic>.from(e.requestOptions.headers);
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
            'Type: ${e.type}\n'
            'Message: ${e.message}\n'
            'Cause: ${e.error}\n'
            'Status: $statusCode\n'
            'Request headers: $headers\n'
            'Request data: ${stringify(e.requestOptions.data)}\n'
            'Response data: ${stringify(res?.data)}',
            name: 'DioClient',
          );

          return handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }

  Future<dynamic> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }

  // Basic PUT, DELETE methods can be added similarly
  Future<dynamic> put(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }

  Future<dynamic> delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }
}
