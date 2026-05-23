import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository(this._apiClient);

  /// GET /booking/v1/bookings — list my bookings (auth required).
  /// Pass [userId] to filter by user (e.g. current user's sub).
  Future<List<BookingModel>> listBookings({
    String? userId,
    int page = 0,
    int pageSize = 50,
    String? status,
    bool includeCancelled = true,
    DateTime? from,
    DateTime? to,
  }) async {
    final r = await listBookingsPaged(
      userId: userId,
      page: page,
      pageSize: pageSize,
      status: status,
      includeCancelled: includeCancelled,
      from: from,
      to: to,
    );
    return r.results;
  }

  /// Paged list with `list_params.sort` (default `-end_at`), `list_params.page` from 0.
  Future<BookingsListPageResult> listBookingsPaged({
    String? userId,
    int page = 0,
    int pageSize = 30,
    String listSort = '-end_at',
    String? status,
    bool includeCancelled = true,
    DateTime? from,
    DateTime? to,
  }) async {
    final query = <String, dynamic>{
      'list_params.page': page.toString(),
      'list_params.page_size': pageSize.toString(),
      'list_params.sort': listSort,
      if (userId != null && userId.isNotEmpty) 'user_id': userId,
      if (status != null) 'status': status,
      'include_cancelled': includeCancelled,
      if (from != null) 'from': from.toUtc().toIso8601String(),
      if (to != null) 'to': to.toUtc().toIso8601String(),
    };
    final response = await _apiClient.get(
      ApiEndpoints.bookings,
      queryParameters: query,
    );
    final data = response.data as Map<String, dynamic>?;
    if (data == null) {
      return BookingsListPageResult(
        results: const [],
        page: page,
        pageSize: pageSize,
      );
    }
    final results = data['results'] as List<dynamic>?;
    final list = results == null
        ? const <BookingModel>[]
        : results
            .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
            .toList();
    final pagination = data['pagination_info'] as Map<String, dynamic>?;
    int? totalCount;
    int parsedPage = page;
    int parsedSize = pageSize;
    if (pagination != null) {
      totalCount = int.tryParse(pagination['total_count']?.toString() ?? '');
      parsedPage = int.tryParse(pagination['page']?.toString() ?? '') ?? page;
      parsedSize =
          int.tryParse(pagination['page_size']?.toString() ?? '') ?? pageSize;
    }
    return BookingsListPageResult(
      results: list,
      page: parsedPage,
      pageSize: parsedSize,
      totalCount: totalCount,
    );
  }

  /// POST /booking/v1/bookings — create booking (auth required).
  Future<BookingModel> createBooking(BookingCreateRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.bookings,
      data: request.toJson(),
    );
    final data = response.data as Map<String, dynamic>;
    return BookingModel.fromJson(data);
  }

  /// GET /booking/v1/bookings/:id — get one booking (auth required).
  Future<BookingModel> getBooking(String id) async {
    final response = await _apiClient.get(ApiEndpoints.bookingById(id));
    final data = response.data as Map<String, dynamic>;
    return BookingModel.fromJson(data);
  }

  /// POST /booking/v1/bookings/:id/cancel — cancel booking (auth required).
  Future<BookingModel> cancelBooking(String id, BookingCancelRequest body) async {
    final response = await _apiClient.post(
      ApiEndpoints.bookingCancel(id),
      data: body.toJson(),
    );
    final data = response.data as Map<String, dynamic>;
    return BookingModel.fromJson(data);
  }
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingRepository(apiClient);
});
