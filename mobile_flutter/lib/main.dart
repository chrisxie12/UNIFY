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
  await bootstrap(() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await dotenv.load(fileName: 'assets/.env');
    await Hive.initFlutter();
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (supabaseUrl != null && supabaseKey != null) {
      try {
        await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
      } catch (_) {}
    }
    return const ProviderScope(child: UnifyApp());
  }, sentryDsn: dotenv.env['SENTRY_DSN']);
}
