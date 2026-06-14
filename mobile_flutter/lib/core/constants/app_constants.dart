class AppConstants {
  AppConstants._();

  static const String appName = 'UNIFY';
  static const String university = 'GCTU';
  static const String universityFull =
      'Ghana Communication Technology University';

  // Pagination
  static const int feedPageSize = 20;
  static const int adminPageSize = 30;

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 15);
  static const Duration cacheMaxAge = Duration(hours: 2);

  // Hive box names
  static const String feedCacheBox = 'feed_cache';
  static const String profileCacheBox = 'profile_cache';

  // Announcement categories
  static const List<String> announcementCategories = [
    'general',
    'academic',
    'events',
    'admin',
    'urgent',
  ];
}
