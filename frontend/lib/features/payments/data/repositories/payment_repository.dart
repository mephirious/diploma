import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/payment_intent_model.dart';

class PaymentPollTimeoutException implements Exception {
  const PaymentPollTimeoutException();
}

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  /// POST /payment/v1/payments
  Future<PaymentIntentModel> createPayment(PaymentCreateRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.payments,
      data: request.toJson(),
    );
    final data = response.data as Map<String, dynamic>;
    return PaymentIntentModel.fromJson(data);
  }

  /// GET /payment/v1/payments/{id}/status
  Future<PaymentIntentModel> getPaymentStatus(String intentId) async {
    final response = await _apiClient.get(ApiEndpoints.paymentStatus(intentId));
    final data = response.data as Map<String, dynamic>;
    return PaymentIntentModel.fromJson(data);
  }

  /// POST /payment/v1/payments/{id}/refund
  Future<PaymentIntentModel> refundPayment(
    String intentId,
    PaymentRefundRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.paymentRefund(intentId),
      data: request.toJson(),
    );
    final data = response.data as Map<String, dynamic>;
    return PaymentIntentModel.fromJson(data);
  }

  /// Poll until terminal status or [timeout].
  Future<PaymentIntentModel> pollUntilTerminal(
    String intentId, {
    Duration timeout = const Duration(seconds: 30),
    Duration interval = const Duration(seconds: 1),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final intent = await getPaymentStatus(intentId);
      if (intent.isTerminal) return intent;
      final remaining = deadline.difference(DateTime.now());
      if (remaining <= Duration.zero) break;
      await Future.delayed(
        remaining < interval ? remaining : interval,
      );
    }
    throw const PaymentPollTimeoutException();
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentRepository(apiClient);
});
