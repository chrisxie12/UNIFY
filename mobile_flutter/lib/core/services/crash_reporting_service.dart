import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CrashReportingService {
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> init({String? dsn, String? environment}) async {
    if (_initialized) return;

    try {
      if (dsn != null && dsn.isNotEmpty) {
        await SentryFlutter.init(
          (options) {
            options.dsn = dsn;
            options.environment = environment ?? 'production';
            options.tracesSampleRate = 0.2;
          },
        );
        _initialized = true;
        debugPrint('[CrashReporting] Sentry initialized');
      } else {
        debugPrint('[CrashReporting] No DSN provided — skipping Sentry init');
      }
    } catch (e) {
      debugPrint('[CrashReporting] Failed to init: $e');
    }
  }

  void captureException(dynamic exception, {dynamic stackTrace}) {
    if (!_initialized) {
      debugPrint('[CrashReporting] (not sent) $exception');
      return;
    }
    Sentry.captureException(exception, stackTrace: stackTrace as StackTrace?);
  }

  void captureMessage(String message, {SentryLevel level = SentryLevel.info}) {
    if (!_initialized) return;
    Sentry.captureMessage(message, level: level);
  }

  void setUser(String userId, {String? email, String? username}) {
    if (!_initialized) return;
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: userId, email: email, username: username));
    });
  }

  void clearUser() {
    if (!_initialized) return;
    Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  void setTag(String key, String value) {
    if (!_initialized) return;
    Sentry.configureScope((scope) {
      scope.setTag(key, value);
    });
  }
}
