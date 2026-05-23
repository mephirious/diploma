import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/auth/auth_models.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _storage;

  AuthRepository(this._apiClient, this._storage);

  Future<AuthTokens> login(String email, String password) async {
    final request = LoginRequest(username: email, password: password);
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    final data = response.data as Map<String, dynamic>;
    final accessToken = (data['access_token'] ??
            data['accessToken'] ??
            data['access-token'])
        ?.toString();
    final refreshToken = (data['refresh_token'] ??
            data['refreshToken'] ??
            data['refresh-token'])
        ?.toString();

    if (accessToken == null || accessToken.isEmpty) {
      throw FormatException('Missing access token in login response');
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      throw FormatException('Missing refresh token in login response');
    }

    // Decode exp/sub for expiry + shared session metadata.
    late final AuthUser authUser;
    try {
      authUser = AuthUser.fromAccessToken(accessToken);
    } catch (_) {
      // If token isn't a valid JWT for some reason, still allow auth tokens flow.
      authUser = const AuthUser(
        sub: '',
        username: '',
        firstName: null,
        lastName: null,
        email: '',
        roles: [],
        exp: 0,
      );
    }

    await _storage.saveToken(accessToken);
    await _storage.saveRefreshToken(refreshToken);
    if (authUser.exp > 0) {
      await _storage.saveAccessTokenExpiresAt(authUser.exp);
    }

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
    }
    if (refreshExpiresIn != null && refreshExpiresIn > 0) {
      await _storage.saveRefreshTokenExpiresAt(nowSeconds + refreshExpiresIn);
    }

    if (authUser.sub.isNotEmpty) {
      await _storage.saveUserId(authUser.sub);
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExp: authUser.exp,
    );
  }

  Future<AuthTokens> refreshTokens() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('Missing refresh token');
    }

    final response = await _apiClient.post(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
      options: Options(extra: {'skipAuthRefresh': true}),
    );

    final data = response.data as Map<String, dynamic>;
    final accessToken = (data['access_token'] ??
            data['accessToken'] ??
            data['access-token'])
        ?.toString();
    final newRefreshToken = (data['refresh_token'] ??
            data['refreshToken'] ??
            data['refresh-token'])
        ?.toString();

    if (accessToken == null || accessToken.isEmpty) {
      throw FormatException('Missing access token in refresh response');
    }
    if (newRefreshToken == null || newRefreshToken.isEmpty) {
      throw FormatException('Missing refresh token in refresh response');
    }

    await _storage.saveToken(accessToken);
    await _storage.saveRefreshToken(newRefreshToken);

    // Reset expiration times from server (if present), otherwise fallback to JWT exp.
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
      final authUser = AuthUser.fromAccessToken(accessToken);
      await _storage.saveAccessTokenExpiresAt(authUser.exp);
    }

    if (refreshExpiresIn != null && refreshExpiresIn > 0) {
      await _storage.saveRefreshTokenExpiresAt(nowSeconds + refreshExpiresIn);
    }

    final authUser = AuthUser.fromAccessToken(accessToken);
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: newRefreshToken,
      accessTokenExp: authUser.exp,
    );
  }

  Future<void> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    // API may return a success object or be empty; we just proceed to login.
    if (response.data is Map<String, dynamic>) {
      // no-op
    }
  }

  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.profile);
    final data = response.data as Map<String, dynamic>;

    // Supports both legacy and account_v1-ish response shapes.
    final id = (data['id'] ?? data['user_id'] ?? data['sub'])?.toString() ?? '';
    final email = (data['email'] ?? '').toString();

    final firstName =
        (data['first_name'] ?? data['firstName'] ?? '').toString().trim();
    final lastName =
        (data['last_name'] ?? data['lastName'] ?? '').toString().trim();
    final fullNameFromNames = (() {
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        return '$firstName $lastName';
      }
      if (firstName.isNotEmpty) return firstName;
      if (lastName.isNotEmpty) return lastName;
      return null;
    })();

    final fullName = fullNameFromNames ??
        (data['full_name'] ??
                data['fullName'] ??
                data['username'] ??
                data['preferred_username'])
            ?.toString()
            .trim() ??
        '';

    if (fullName.isEmpty) {
      // Ensure required `fullName` is never null/empty.
      final fallback = (data['username'] ??
              data['preferred_username'] ??
              data['id'] ??
              data['user_id'])?.toString();
      if (fallback == null || fallback.isEmpty) {
        throw FormatException('Missing user name in profile response');
      }
    }

    final phone = data['phone']?.toString();

    return UserModel(
      id: id,
      email: email,
      fullName: fullName.isEmpty
          ? (data['username'] ?? data['preferred_username'] ?? id).toString()
          : fullName,
      phone: phone,
    );
  }

  Future<bool> isAuthenticated() async {
    return await _storage.isAuthenticated();
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(apiClient, storage);
});

