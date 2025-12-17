import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _storage;

  AuthRepository(this._apiClient, this._storage);

  Future<LoginResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    final loginResponse = LoginResponse.fromJson(response.data);
    
    await _storage.saveToken(loginResponse.accessToken);
    await _storage.saveRefreshToken(loginResponse.refreshToken);
    await _storage.saveUserId(loginResponse.userId);

    return loginResponse;
  }

  Future<String> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    return response.data['user_id'] as String;
  }

  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.profile);
    return UserModel.fromJson(response.data);
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

