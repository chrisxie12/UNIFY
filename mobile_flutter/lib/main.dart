import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'app.dart';
import 'bootstrap.dart';
import 'firebase_options.dart';

void main() {
  debugPrint('[STARTUP] main() called, calling bootstrap()');
  bootstrap(() async {
    debugPrint('[STARTUP] builder lambda entered');
    debugPrint('[STARTUP] calling Firebase.initializeApp()...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[STARTUP] Firebase.initializeApp() done');

    debugPrint('[STARTUP] returning UnifyApp');
    return const UnifyApp();
  });
}
