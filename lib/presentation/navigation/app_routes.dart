class AppRoutes {
  AppRoutes._();

  // Main routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';

  // Event routes
  static const String eventDetail = '/event-detail';
  static const String createEvent = '/create-event';
  static const String editEvent = '/edit-event';

  // Group routes
  static const String groups = '/groups';
  static const String groupDetail = '/group-detail';
  static const String groupChat = '/group-chat';
  static const String createGroup = '/create-group';

  // Profile routes
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';

  // Rewards routes
  static const String rewardsDashboard = '/rewards-dashboard';
  static const String partnerBusinesses = '/partner-businesses';

  // Ticket routes
  static const String ticketPurchase = '/ticket-purchase';

  // Admin routes
  static const String adminDashboard = '/admin-dashboard';
  static const String adminUsers = '/admin-users';
  static const String adminEvents = '/admin-events';

  // Business routes
  static const String businessDashboard = '/business-dashboard';
  static const String businessEvents = '/business-events';
  static const String businessPartners = '/business-partners';

  // Explore routes
  static const String categoryExplore = '/category-explore';
}
