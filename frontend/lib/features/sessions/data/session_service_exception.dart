import 'package:dio/dio.dart';

/// Parsed error from the session microservice (`code`, `message`, `fields`).
class SessionServiceException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, String>? fields;

  const SessionServiceException(
    this.message, {
    this.statusCode,
    this.fields,
  });

  factory SessionServiceException.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message']?.toString() ??
          data['error']?.toString() ??
          'Request failed';
      Map<String, String>? fields;
      final rawFields = data['fields'];
      if (rawFields is Map) {
        fields = rawFields.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }
      return SessionServiceException(msg, statusCode: status, fields: fields);
    }
    return SessionServiceException(
      error.message ?? 'Network error',
      statusCode: status,
    );
  }

  bool get isAlreadyJoined =>
      message.toLowerCase().contains('already joined');

  bool get isSessionFull =>
      message.toLowerCase().contains('full') ||
      message.toLowerCase().contains('session is full');

  bool get isSessionLocked =>
      message.toLowerCase().contains('lock') ||
      message.toLowerCase().contains('no longer accepting');

  bool get isUnauthorized => statusCode == 401;

  bool get isForbidden => statusCode == 403;

  @override
  String toString() => message;
}
