/// Payment intent from POST /payment/v1/payments or GET .../status.
class PaymentIntentModel {
  final String id;
  final String bookingId;
  final String userId;
  final int amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final int attemptNumber;
  final String? lastError;
  final DateTime? expiresAt;
  final DateTime? succeededAt;
  final DateTime? failedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentIntentModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.attemptNumber,
    this.lastError,
    this.expiresAt,
    this.succeededAt,
    this.failedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) {
    return PaymentIntentModel(
      id: json['id'] as String? ?? '',
      bookingId: json['booking_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      amount: _parseInt(json['amount']),
      currency: json['currency'] as String? ?? 'KZT',
      status: json['status'] as String? ?? 'processing',
      paymentMethod: json['payment_method'] as String? ?? 'card',
      attemptNumber: _parseInt(json['attempt_number']),
      lastError: json['last_error'] as String?,
      expiresAt: _parseDateTime(json['expires_at']),
      succeededAt: _parseDateTime(json['succeeded_at']),
      failedAt: _parseDateTime(json['failed_at']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  bool get isTerminal =>
      status == 'succeeded' || status == 'failed' || status == 'expired';

  bool get isSucceeded => status == 'succeeded';
}

class PaymentCreateRequest {
  final String bookingId;
  final String paymentMethod;

  const PaymentCreateRequest({
    required this.bookingId,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'booking_id': bookingId,
        'payment_method': paymentMethod,
      };
}

/// Maps UI payment selection to API `payment_method` (`card` | `apple_pay`).
String apiPaymentMethodFromSelection(String selectedPaymentMethod) {
  if (selectedPaymentMethod == 'apple_pay') return 'apple_pay';
  return 'card';
}
