import 'dart:async';
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

  // Render build-phase errors visibly instead of a blank/grey screen so they
  // remain diagnosable in release web builds.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF1A1A1A),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SelectableText(
            'Build error:\n${details.exception}\n\n${details.stack ?? ''}',
            style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
          ),
        ),
      ),
    );
  };

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        final widget = await builder();
        runApp(widget);
      } catch (error, stackTrace) {
        // A failure during startup (Supabase/Hive/etc.) would otherwise leave
        // a permanently blank screen. Render the error so it's diagnosable.
        crashReportingService.captureException(error, stackTrace: stackTrace);
        runApp(_StartupErrorApp(error: error, stackTrace: stackTrace));
      }
    },
    (error, stackTrace) {
      crashReportingService.captureException(error, stackTrace: stackTrace);
      if (kDebugMode) {
        debugPrint('[ZonedError] $error\n$stackTrace');
      }
    },
  );
}

/// Shown when [bootstrap]'s builder throws — surfaces the real error instead
/// of a blank white screen. Exception *messages* survive minification, so this
/// is readable even in release web builds.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error, this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Startup error',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  '$error',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  '${stackTrace ?? ''}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
