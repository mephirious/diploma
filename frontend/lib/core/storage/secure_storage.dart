import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> saveAccessTokenExpiresAt(int unixSeconds) async {
    await _storage.write(
      key: AppConstants.accessTokenExpiresAtKey,
      value: unixSeconds.toString(),
    );
  }

  Future<int?> getAccessTokenExpiresAt() async {
    final raw = await _storage.read(key: AppConstants.accessTokenExpiresAtKey);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> saveRefreshTokenExpiresAt(int unixSeconds) async {
    await _storage.write(
      key: AppConstants.refreshTokenExpiresAtKey,
      value: unixSeconds.toString(),
    );
  }

  Future<int?> getRefreshTokenExpiresAt() async {
    final raw = await _storage.read(key: AppConstants.refreshTokenExpiresAtKey);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppConstants.userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: AppConstants.userIdKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage(const FlutterSecureStorage());
});

