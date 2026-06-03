class AppConstants {
  static const String appName = 'Sport Booking';
  static const String apiBaseUrl = 'http://localhost:80';

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
  static const String venueRequests = '/account/v1/venue-requests';

  static const String venues = '/api/v1/venues';
  static String venueById(String id) => '/api/v1/venues/$id';

  static const String reservations = '/api/v1/reservations';
  static String reservationById(String id) => '/api/v1/reservations/$id';

  // Booking service (auth required, Bearer token)
  static const String _bookingBase = '/booking/v1';
  static const String bookingReservations = '$_bookingBase/reservations';
  static const String bookings = '$_bookingBase/bookings';
  static String bookingById(String id) => '$_bookingBase/bookings/$id';
  static String bookingCancel(String id) => '$_bookingBase/bookings/$id/cancel';
  static String bookingConfirm(String id) =>
      '$_bookingBase/bookings/$id/confirm';

  // Payment service (auth required, Bearer token)
  static const String _paymentBase = '/payment/v1';
  static const String payments = '$_paymentBase/payments';
  static String paymentStatus(String id) => '$_paymentBase/payments/$id/status';
  static String paymentRefund(String id) => '$_paymentBase/payments/$id/refund';

  static const String _sessionBase = '/session/v1';
  static const String sessions = '$_sessionBase/sessions';
  static String sessionById(String id) => '$_sessionBase/sessions/$id';
  static String joinSession(String id) => '$_sessionBase/sessions/$id/join';
  static String leaveSession(String id) => '$_sessionBase/sessions/$id/leave';
  static String sessionParticipants(String id) =>
      '$_sessionBase/sessions/$id/participants';
  static String joinSessionByInvite(String code) =>
      '$_sessionBase/sessions/join/$code';

  /// Chat REST (KrakenD → chat service).
  static const String chatConversationsDirect = '/chat/v1/conversations/direct';
  static const String chatConversations = '/chat/v1/conversations';
  static String chatConversationById(String id) => '/chat/v1/conversations/$id';
  static String chatMessages(String conversationId) =>
      '/chat/v1/conversations/$conversationId/messages';
  static String chatMarkRead(String conversationId) =>
      '/chat/v1/conversations/$conversationId/read';
  static const String chatUsersSearch = '/chat/v1/users/search';
}
