import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/venue_model.dart';
import '../models/resource_model.dart';
import '../models/venue_schedule_result_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class PaginatedVenuesResponse {
  final List<VenueModel> venues;
  final int page;
  final int pageSize;
  final int totalCount;

  PaginatedVenuesResponse({
    required this.venues,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  /// [page] is 0-based (first page is `0`).
  bool get hasMore => ((page + 1) * pageSize) < totalCount;
}

class VenueRepository {
  final DioClient _dioClient;
  final ApiClient _apiClient;

  VenueRepository(this._dioClient, this._apiClient);

  Future<PaginatedVenuesResponse> getVenuesPage({
    required int page,
    int pageSize = 40,
    String? search,
    String? sport,
    bool favoritesOnly = false,
  }) async {
    final params = <String, dynamic>{
      'list_params.sort': '-updated_at',
      'list_params.page': page.toString(),
      'list_params.page_size': pageSize.toString(),
      'list_params.with_total_count': 'true',
    };

    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    if (sport != null && sport.isNotEmpty) {
      params['sport'] = sport;
    }
    if (favoritesOnly) {
      params['favorites_only'] = 'true';
    }

    final dynamic data;
    if (favoritesOnly) {
      // favorites_only requires authentication — use the auth-aware client.
      final resp = await _apiClient.get(ApiEndpoints.venues, queryParameters: params);
      data = resp.data;
    } else {
      data = await _dioClient.get(ApiEndpoints.venues, queryParameters: params);
    }

    final List<dynamic> results;
    int respPage = page;
    int respPageSize = pageSize;
    int totalCount = 0;

    if (data is Map<String, dynamic>) {
      if (data['results'] is List) {
        results = data['results'] as List<dynamic>;
      } else {
        results = const [];
      }

      final pagination = data['pagination_info'] as Map<String, dynamic>?;
      if (pagination != null) {
        respPage = int.tryParse(pagination['page']?.toString() ?? '') ?? page;
        respPageSize =
            int.tryParse(pagination['page_size']?.toString() ?? '') ??
                pageSize;
        totalCount =
            int.tryParse(pagination['total_count']?.toString() ?? '') ?? 0;
      }
    } else if (data is List) {
      // Fallback: plain list with no pagination_info.
      results = data;
      totalCount = results.length;
    } else {
      results = const [];
    }

    final venues = results
        .map((e) => VenueModel.fromApiJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedVenuesResponse(
      venues: venues,
      page: respPage,
      pageSize: respPageSize,
      totalCount: totalCount,
    );
  }

  // Convenience: first page without explicit pagination handling.
  Future<List<VenueModel>> getVenues() async {
    final resp = await getVenuesPage(page: 0, pageSize: 40);
    return resp.venues;
  }

  Future<VenueModel?> getVenueById(String id) async {
    final data = await _dioClient.get('${ApiEndpoints.venues}/$id');

    if (data is Map<String, dynamic>) {
      return VenueModel.fromApiJson(data);
    }

    return null;
  }

  Future<List<VenueModel>> searchVenues(String query) async {
    final resp = await getVenuesPage(page: 0, pageSize: 40, search: query);
    return resp.venues;
  }

  /// GET /venue/v1/resources/{id} — single resource (name, images, etc.).
  Future<ResourceModel?> getResourceById(String id) async {
    if (id.isEmpty) return null;
    final data = await _dioClient.get(ApiEndpoints.resourceById(id));
    if (data is Map<String, dynamic>) {
      return ResourceModel.fromJson(data);
    }
    return null;
  }

  /// GET /venues/{venue_id}/resources — list resources for a venue.
  Future<List<ResourceModel>> getResources(String venueId, {int pageSize = 100}) async {
    final params = <String, dynamic>{
      'list_params.page': '1',
      'list_params.page_size': pageSize.toString(),
      'list_params.with_total_count': 'true',
    };
    final data = await _dioClient.get(
      ApiEndpoints.venueResources(venueId),
      queryParameters: params,
    );
    if (data is! Map<String, dynamic>) return [];
    final results = data['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => ResourceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /venues/{venue_id}/schedule-result — resources with schedules, pricing, blackouts.
  Future<VenueScheduleResultModel> getScheduleResult(
    String venueId, {
    String? resourceId,
    DateTime? from,
    DateTime? to,
    bool includeInactive = false,
  }) async {
    final params = <String, dynamic>{
      'include_inactive': includeInactive,
    };
    if (resourceId != null && resourceId.isNotEmpty) params['resource_id'] = resourceId;
    if (from != null) params['from'] = from.toUtc().toIso8601String();
    if (to != null) params['to'] = to.toUtc().toIso8601String();

    final data = await _dioClient.get(
      ApiEndpoints.venueScheduleResult(venueId),
      queryParameters: params,
    );
    if (data is Map<String, dynamic>) {
      return VenueScheduleResultModel.fromJson(data);
    }
    return VenueScheduleResultModel(venueId: venueId);
  }

  /// Add a venue to the authenticated user's favorites.
  Future<void> addFavorite(String venueId) async {
    await _apiClient.post(ApiEndpoints.venueFavorite(venueId));
  }

  /// Remove a venue from the authenticated user's favorites.
  Future<void> removeFavorite(String venueId) async {
    await _apiClient.delete(ApiEndpoints.venueFavorite(venueId));
  }

  /// Fetch only favorited venues for the authenticated user (paginated).
  Future<PaginatedVenuesResponse> getFavoritesPage({
    int page = 0,
    int pageSize = 100,
  }) async {
    return getVenuesPage(
      page: page,
      pageSize: pageSize,
      favoritesOnly: true,
    );
  }
}

final venueRepositoryProvider = Provider<VenueRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final apiClient = ref.watch(apiClientProvider);
  return VenueRepository(dioClient, apiClient);
});
