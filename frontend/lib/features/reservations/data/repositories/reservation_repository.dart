import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/reservation_model.dart';

class ReservationRepository {
  final ApiClient _apiClient;

  ReservationRepository(this._apiClient);

  Future<List<ReservationModel>> getMyReservations() async {
    final response = await _apiClient.get(ApiEndpoints.reservations);
    final data = response.data as List;
    return data.map((json) => ReservationModel.fromJson(json)).toList();
  }

  Future<ReservationModel> createReservation({
    required String apartmentId,
    String? comment,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.reservations,
      data: {
        'apartment_id': apartmentId,
        'comment': comment,
      },
    );
    return ReservationModel.fromJson(response.data);
  }
}

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReservationRepository(apiClient);
});

