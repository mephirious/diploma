class AppConstants {
  static const String appName = 'Sport Booking';
  static const String apiBaseUrl = 'http://localhost:8080';
  
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
}

class ApiEndpoints {
  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String profile = '/api/v1/profile';
  
  static const String venues = '/api/v1/venues';
  static String venueById(String id) => '/api/v1/venues/$id';
  
  static const String reservations = '/api/v1/reservations';
  static String reservationById(String id) => '/api/v1/reservations/$id';
  
  static const String sessions = '/api/v1/sessions';
  static const String openSessions = '/api/v1/sessions/open';
  static String sessionById(String id) => '/api/v1/sessions/$id';
  static String joinSession(String id) => '/api/v1/sessions/$id/join';
  
  static String paySession(String id) => '/api/v1/sessions/$id/pay';
}

