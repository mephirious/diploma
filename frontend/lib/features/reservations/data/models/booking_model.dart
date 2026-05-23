import '../../../../core/utils/booking_datetime.dart';

/// Booking model matching Swagger bookingBookingMain / bookingBookingCreateReq.
/// All booking API requests require Bearer token.
class BookingModel {
  final String id;
  final String venueId;
  final String? resourceId;
  final String? sessionId;
  final String? userId;
  final String status;
  final String? paymentStatus;
  final String priceTotal; // API uses string (int64)
  final String? currency;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? timezone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? holdExpiresAt;
  final String? paymentIntentId;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;

  const BookingModel({
    required this.id,
    required this.venueId,
    this.resourceId,
    this.sessionId,
    this.userId,
    required this.status,
    this.paymentStatus,
    required this.priceTotal,
    this.currency,
    this.startAt,
    this.endAt,
    this.timezone,
    this.createdAt,
    this.updatedAt,
    this.holdExpiresAt,
    this.paymentIntentId,
    this.cancelReason,
    this.cancelledAt,
    this.confirmedAt,
    this.completedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String? ?? '',
      venueId: json['venue_id'] as String? ?? '',
      resourceId: json['resource_id'] as String?,
      sessionId: json['session_id'] as String?,
      userId: json['user_id'] as String?,
      status: json['status'] as String? ?? 'unknown',
      paymentStatus: json['payment_status'] as String?,
      priceTotal: json['price_total']?.toString() ?? '0',
      currency: json['currency'] as String?,
      startAt: _parseDateTime(json['start_at']),
      endAt: _parseDateTime(json['end_at']),
      timezone: json['timezone'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      holdExpiresAt: _parseDateTime(json['hold_expires_at']),
      paymentIntentId: json['payment_intent_id'] as String?,
      cancelReason: json['cancel_reason'] as String?,
      cancelledAt: _parseDateTime(json['cancelled_at']),
      confirmedAt: _parseDateTime(json['confirmed_at']),
      completedAt: _parseDateTime(json['completed_at']),
    );
  }

  static DateTime? _parseDateTime(dynamic v) => parseApiDateTime(v);

  /// Total price as int (API sends int64 as string).
  int get priceTotalInt => int.tryParse(priceTotal) ?? 0;

  /// Start instant in booking [timezone] (wall clock at venue).
  DateTime? get startAtForDisplay =>
      toBookingLocal(startAt, timezone);

  /// End instant in booking [timezone].
  DateTime? get endAtForDisplay => toBookingLocal(endAt, timezone);

  /// Booking date from start_at or created_at in booking timezone.
  DateTime get displayDate =>
      startAtForDisplay ??
      toBookingLocal(createdAt, timezone) ??
      DateTime.now();

  /// Start time string "HH:mm" in booking timezone.
  String get startTimeStr {
    final d = startAtForDisplay;
    return d != null ? formatTimeHm(d) : '';
  }

  /// End time string "HH:mm" in booking timezone.
  String get endTimeStr {
    final d = endAtForDisplay;
    return d != null ? formatTimeHm(d) : '';
  }

  /// Duration in hours.
  int get durationHours {
    if (startAt == null || endAt == null) return 0;
    return endAt!.difference(startAt!).inHours;
  }

  bool get isPaymentPending =>
      paymentStatus?.toLowerCase() == 'pending';

  /// Pending or failed payment: user can open checkout from booking details.
  bool get needsPaymentCompletion {
    final p = paymentStatus?.toLowerCase();
    return p == 'pending' || p == 'failed';
  }
}

/// Request body for POST /bookings (Booking_Create).
class BookingCreateRequest {
  final String venueId;
  final String? resourceId;
  final DateTime startAt;
  final DateTime endAt;
  /// IANA name; required by POST /bookings.
  final String timezone;
  final String? sessionId;
  final String? userId;
  final String priceTotal; // int64 as string
  final String? currency;
  final String? priceQuoteId;
  final String? idempotencyKey;
  final String? note;

  const BookingCreateRequest({
    required this.venueId,
    this.resourceId,
    required this.startAt,
    required this.endAt,
    required this.timezone,
    this.sessionId,
    this.userId,
    required this.priceTotal,
    this.currency,
    this.priceQuoteId,
    this.idempotencyKey,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'venue_id': venueId,
      if (resourceId != null) 'resource_id': resourceId,
      'start_at': startAt.toUtc().toIso8601String(),
      'end_at': endAt.toUtc().toIso8601String(),
      'timezone': timezone,
      if (sessionId != null) 'session_id': sessionId,
      if (userId != null) 'user_id': userId,
      'price_total': priceTotal,
      if (currency != null) 'currency': currency,
      if (priceQuoteId != null) 'price_quote_id': priceQuoteId,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (note != null) 'note': note,
    };
  }
}

/// Paged list from GET /booking/v1/bookings (`results` + `pagination_info`).
class BookingsListPageResult {
  final List<BookingModel> results;
  final int page;
  final int pageSize;
  final int? totalCount;

  const BookingsListPageResult({
    required this.results,
    required this.page,
    required this.pageSize,
    this.totalCount,
  });
}

/// Request body for POST /bookings/:id/cancel.
class BookingCancelRequest {
  final String? reason;
  final bool? refundRequested;
  final String? idempotencyKey;

  const BookingCancelRequest({
    this.reason,
    this.refundRequested,
    this.idempotencyKey,
  });

  Map<String, dynamic> toJson() {
    return {
      if (reason != null) 'reason': reason,
      if (refundRequested != null) 'refund_requested': refundRequested,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
    };
  }
}
