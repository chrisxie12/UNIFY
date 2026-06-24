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
import 'firebase_options.dart';

// Compile-time constants injected via --dart-define (Vercel env vars → build command).
// On mobile local dev these are empty strings and credentials come from assets/.env.
const _kSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _kSupabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const _kSentryDsn   = String.fromEnvironment('SENTRY_DSN');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is only configured for Android/iOS. On web, currentPlatform throws
  // UnsupportedError by design (FlutterFire CLI never ran for web), so skip it.
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }
    // .env is bundled as an asset for local mobile dev only; not present on Vercel.
    try {
      await dotenv.load(fileName: 'assets/.env');
    } catch (e) {
      debugPrint('dotenv: could not load assets/.env ($e)');
    }
  }

  // Prefer --dart-define values (set at build time via Vercel env vars).
  // Fall back to .env values for local mobile development.
  final supabaseUrl = _kSupabaseUrl.isNotEmpty
      ? _kSupabaseUrl
      : dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseKey = _kSupabaseKey.isNotEmpty
      ? _kSupabaseKey
      : dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  final sentryDsn = _kSentryDsn.isNotEmpty
      ? _kSentryDsn
      : dotenv.env['SENTRY_DSN'];

  await bootstrap(() async {
    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    await Hive.initFlutter();
    if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
        authOptions: const FlutterAuthClientOptions(
          autoRefreshToken: true,
          authFlowType: AuthFlowType.pkce,
        ),
      );
    } else {
      debugPrint('[main] Supabase credentials missing — set SUPABASE_URL and SUPABASE_ANON_KEY env vars in Vercel, or add assets/.env for local dev');
    }
    return const ProviderScope(child: UnifyApp());
  }, sentryDsn: sentryDsn);
}
