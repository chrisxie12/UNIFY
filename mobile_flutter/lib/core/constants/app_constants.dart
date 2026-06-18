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
  static const String opportunitiesBox = 'opportunities_cache';
  static const String academicBox = 'academic_cache';
  static const String offlineResourcesBox = 'offline_resources';
  static const String launchBox = 'launch_cache';

  // App version (kept in sync with pubspec version + build number).
  // Used by the feedback center, analytics, and the app-update gate.
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Roles
  static const String roleStudent    = 'student';
  static const String roleAdmin      = 'admin';
  static const String roleSuperAdmin = 'superadmin';
}
