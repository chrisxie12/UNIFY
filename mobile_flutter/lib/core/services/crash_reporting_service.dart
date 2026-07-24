import 'package:flutter/foundation.dart';

class CrashReportingService {
  final bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> init({String? dsn, String? environment}) async {
    if (_initialized) return;
    debugPrint('[CrashReporting] Sentry not available — error monitoring disabled');
  }

  void captureException(dynamic exception, {dynamic stackTrace}) {
    debugPrint('[CrashReporting] (not sent) $exception');
  }

  void captureMessage(String message, {dynamic level}) {
    debugPrint('[CrashReporting] (not sent) $message');
  }

  void setUser(String userId, {String? email, String? username}) {}

  void clearUser() {}

  void setTag(String key, String value) {}
}
