class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = '/api/v1';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String refreshToken = '$baseUrl/auth/refresh';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String verifyEmail = '$baseUrl/auth/verify-email';

  // User endpoints
  static const String profile = '$baseUrl/user/profile';
  static const String updateProfile = '$baseUrl/user/profile';
  static const String uploadAvatar = '$baseUrl/user/avatar';
  static const String interests = '$baseUrl/user/interests';

  // Event endpoints
  static const String events = '$baseUrl/events';
  static String eventById(String id) => '$events/$id';
  static String joinEvent(String id) => '$events/$id/join';
  static String leaveEvent(String id) => '$events/$id/leave';
  static String eventAttendees(String id) => '$events/$id/attendees';
  static const String createEvent = '$baseUrl/events';
  static String updateEvent(String id) => '$events/$id';
  static String deleteEvent(String id) => '$events/$id';
  static String userEvents(String userId) => '$baseUrl/users/$userId/events';

  // Group endpoints
  static const String groups = '$baseUrl/groups';
  static String groupById(String id) => '$groups/$id';
  static String joinGroup(String id) => '$groups/$id/join';
  static String leaveGroup(String id) => '$groups/$id/leave';
  static String groupMembers(String id) => '$groups/$id/members';
  static const String createGroup = '$baseUrl/groups';
  static String updateGroup(String id) => '$groups/$id';
  static String deleteGroup(String id) => '$groups/$id';
  static String groupMessages(String id) => '$groups/$id/messages';
  static String sendMessage(String id) => '$groups/$id/messages';

  // Category endpoints
  static const String categories = '$baseUrl/categories';

  // Search endpoints
  static const String searchEvents = '$baseUrl/search/events';
  static const String searchGroups = '$baseUrl/search/groups';
  static const String searchUsers = '$baseUrl/search/users';
}
