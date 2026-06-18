import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/services/crash_reporting_service.dart';

final crashReportingService = CrashReportingService();

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  String? sentryDsn,
  String? environment,
}) async {
  await crashReportingService.init(dsn: sentryDsn, environment: environment);

  FlutterError.onError = (FlutterErrorDetails details) {
    crashReportingService.captureException(
      details.exception,
      stackTrace: details.stack,
    );
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    crashReportingService.captureException(error, stackTrace: stack);
    if (kDebugMode) {
      debugPrint('[PlatformError] $error\n$stack');
    }
    return true;
  };

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      try {
        await Firebase.initializeApp();
      } catch (e) {
        debugPrint('[Bootstrap] Firebase init skipped: $e');
      }

      final widget = await builder();
      runApp(widget);
    },
    (error, stackTrace) {
      crashReportingService.captureException(error, stackTrace: stackTrace);
      if (kDebugMode) {
        debugPrint('[ZonedError] $error\n$stackTrace');
      }
    },
  );
}
