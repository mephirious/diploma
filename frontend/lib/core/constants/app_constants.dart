class AppConstants {
  static const String appName = 'Sport Booking';
  static const String apiBaseUrl = 'http://localhost:8080';

  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String accessTokenExpiresAtKey = 'access_token_expires_at';
  static const String refreshTokenExpiresAtKey = 'refresh_token_expires_at';
  static const String userIdKey = 'user_id';
}

class ApiEndpoints {
  static const String register = '/account/v1/register';
  static const String login = '/account/v1/login';
  static const String refresh = '/account/v1/refresh';
  static const String profile = '/account/v1/profile';

  static const String venues = '/api/v1/venues';
  static String venueById(String id) => '/api/v1/venues/$id';

  static const String reservations = '/api/v1/reservations';
  static String reservationById(String id) => '/api/v1/reservations/$id';

  // Booking service (auth required, Bearer token)
  static const String _bookingBase = '/booking/v1';
  static const String bookings = '$_bookingBase/bookings';
  static String bookingById(String id) => '$_bookingBase/bookings/$id';
  static String bookingCancel(String id) => '$_bookingBase/bookings/$id/cancel';
  static String bookingConfirm(String id) => '$_bookingBase/bookings/$id/confirm';

  // Payment service (auth required, Bearer token)
  static const String _paymentBase = '/payment/v1';
  static const String payments = '$_paymentBase/payments';
  static String paymentStatus(String id) => '$_paymentBase/payments/$id/status';

  static const String sessions = '/api/v1/sessions';
  static const String openSessions = '/api/v1/sessions/open';
  static String sessionById(String id) => '/api/v1/sessions/$id';
  static String joinSession(String id) => '/api/v1/sessions/$id/join';

  static String paySession(String id) => '/api/v1/sessions/$id/pay';

  /// Chat REST (KrakenD → chat service).
  static const String chatConversationsDirect = '/chat/v1/conversations/direct';
  static const String chatConversations = '/chat/v1/conversations';
  static String chatConversationById(String id) => '/chat/v1/conversations/$id';
  static String chatMessages(String conversationId) =>
      '/chat/v1/conversations/$conversationId/messages';
  static String chatMarkRead(String conversationId) =>
      '/chat/v1/conversations/$conversationId/read';
}
