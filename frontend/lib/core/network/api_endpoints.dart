class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Users
  static const String profile = '/profile';

  // Venues (venue_v1/audit.proto style: /venues, /venues/{id}, /venues/{venue_id}/resources, etc.)
  static const String venues = '/venue/v1/venues';

  /// GET /venue/v1/venues/{venue_id}/resources
  static String venueResources(String venueId) => '$venues/$venueId/resources';

  /// GET /venue/v1/venues/{venue_id}/schedule-result
  static String venueScheduleResult(String venueId) => '$venues/$venueId/schedule-result';

  /// POST /venue/v1/venues/{venue_id}/favorite
  /// DELETE /venue/v1/venues/{venue_id}/favorite
  static String venueFavorite(String venueId) => '$venues/$venueId/favorite';

  /// GET /venue/v1/resources/{resource_id}
  static const String resources = '/venue/v1/resources';

  static String resourceById(String id) => '$resources/$id';

  // Reservations
  static const String reservations = '/reservations';

  // Sessions
  static const String sessions = '/sessions';
  static const String openSessions = '/sessions/open';
}
