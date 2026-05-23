import 'package:dio/dio.dart';

class NetworkExceptions implements Exception {
  final String message;
  final String? prefix;

  NetworkExceptions([this.message = 'Something went wrong', this.prefix]);

  @override
  String toString() {
    return prefix != null ? '$prefix: $message' : message;
  }

  static NetworkExceptions getDioException(dynamic error) {
    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              return NetworkExceptions('Request Cancelled');
            case DioExceptionType.connectionTimeout:
              return NetworkExceptions('Connection Timeout');
            case DioExceptionType.receiveTimeout:
              return NetworkExceptions('Receive Timeout');
            case DioExceptionType.sendTimeout:
              return NetworkExceptions('Send Timeout');
            case DioExceptionType.connectionError:
              return NetworkExceptions('Connection Error');
            case DioExceptionType.badResponse:
              final response = error.response;
              if (response != null && response.data != null) {
                if (response.data is Map<String, dynamic> &&
                    response.data.containsKey('error')) {
                  return NetworkExceptions(response.data['error']);
                }
                return NetworkExceptions('Error: ${response.statusCode}');
              }
              return NetworkExceptions(
                'Received invalid status code: ${error.response?.statusCode}',
              );
            case DioExceptionType.badCertificate:
              return NetworkExceptions('Bad Certificate');
            default:
              return NetworkExceptions('Unexpected network error');
          }
        } else {
          return NetworkExceptions('Unexpected error occurred');
        }
      } catch (_) {
        return NetworkExceptions('Unexpected error occurred');
      }
    } else {
      if (error.toString().contains('is not a subtype of')) {
        return NetworkExceptions('Unable to process the data');
      } else {
        return NetworkExceptions('Unexpected error occurred');
      }
    }
  }
}
