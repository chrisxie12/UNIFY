import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bootstrap.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('[Firebase] Init skipped — google-services.json not present: $e');
  }
await dotenv.load(fileName: 'assets/.env');
  await bootstrap(() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Hive.initFlutter();
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (supabaseUrl != null && supabaseKey != null) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
        authOptions: const FlutterAuthClientOptions(
          autoRefreshToken: true,
          authFlowType: AuthFlowType.pkce,
        ),
      );
    }
    return const ProviderScope(child: UnifyApp());
  }, sentryDsn: dotenv.env['SENTRY_DSN']);
}
