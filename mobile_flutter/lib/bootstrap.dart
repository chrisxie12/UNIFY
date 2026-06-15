import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      // TODO: forward to Sentry / Firebase Crashlytics
      debugPrint('[FlutterError] ${details.exceptionAsString()}');
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('[PlatformError] $error\n$stack');
    }
    return true;
  };

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      final widget = await builder();
      runApp(widget);
    },
    (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ZonedError] $error\n$stackTrace');
      }
    },
  );
}
