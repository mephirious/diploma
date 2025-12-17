import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/session_model.dart';

class SessionRepository {
  final ApiClient _apiClient;

  SessionRepository(this._apiClient);

  Future<List<SessionModel>> getOpenSessions() async {
    final response = await _apiClient.get(ApiEndpoints.openSessions);
    final data = response.data as List;
    return data.map((json) => SessionModel.fromJson(json)).toList();
  }

  Future<SessionModel> getSessionById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.sessionById(id));
    return SessionModel.fromJson(response.data);
  }

  Future<void> joinSession(String sessionId) async {
    await _apiClient.post(ApiEndpoints.joinSession(sessionId));
  }

  Future<SessionModel> createSession({
    required String reservationId,
    required String sportType,
    required int maxParticipants,
    required double pricePerParticipant,
    String? skillLevel,
    String? description,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.sessions,
      data: {
        'reservation_id': reservationId,
        'sport_type': sportType,
        'max_participants': maxParticipants,
        'price_per_participant': pricePerParticipant,
        'skill_level': skillLevel,
        'description': description,
        'visibility': 'public',
      },
    );
    return SessionModel.fromJson(response.data);
  }
}

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SessionRepository(apiClient);
});

