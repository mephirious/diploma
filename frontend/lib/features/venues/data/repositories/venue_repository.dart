import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/venue_model.dart';

class VenueRepository {
  final ApiClient _apiClient;

  VenueRepository(this._apiClient);

  Future<List<VenueModel>> getVenues() async {
    final response = await _apiClient.get(ApiEndpoints.venues);
    final data = response.data as List;
    return data.map((json) => VenueModel.fromJson(json)).toList();
  }

  Future<VenueModel> getVenueById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.venueById(id));
    return VenueModel.fromJson(response.data);
  }

  Future<List<ResourceModel>> getResourcesByVenue(String venueId) async {
    final response = await _apiClient.get(
      ApiEndpoints.venueById(venueId),
      queryParameters: {'include': 'resources'},
    );
    final venue = VenueModel.fromJson(response.data);
    return venue.resources;
  }
}

final venueRepositoryProvider = Provider<VenueRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VenueRepository(apiClient);
});

