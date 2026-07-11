import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'bootstrap.dart';
import 'firebase_options.dart';

void main() {
  bootstrap(() async {
    // Initialize Firebase with platform-specific configuration
    // (iOS uses GoogleService-Info.plist, Android uses google-services.json)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Return the Riverpod-wrapped app
    return const UnifyApp();
  });
}
