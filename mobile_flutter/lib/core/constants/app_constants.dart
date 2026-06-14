class AppConstants {
  AppConstants._();

  static const String appName = 'UNIFY';
  static const String tagline = 'Your campus, connected.';

  // Pagination
  static const int feedPageSize      = 20;
  static const int notifPageSize     = 30;
  static const int messagePageSize   = 40;

  // Timeouts
  static const Duration httpTimeout  = Duration(seconds: 15);
  static const Duration cacheExpiry  = Duration(hours: 6);

  // Hive boxes
  static const String feedBoxName     = 'feed_cache';
  static const String feedCacheBox    = 'feed_cache';
  static const String profileCacheBox = 'profile_cache';

  // Roles
  static const String roleStudent    = 'student';
  static const String roleAdmin      = 'admin';
  static const String roleSuperAdmin = 'superadmin';
}
