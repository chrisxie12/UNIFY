import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'bootstrap.dart';
import 'firebase_options.dart';

const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://tuepkmjedmbxdlriform.supabase.co',
);
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1ZXBrbWplZG1ieGRscmlmb3JtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwOTAyNzgsImV4cCI6MjA5NjY2NjI3OH0.IcyZ8taXfVC-bOSAjz9wXk5bTkZMmIhKDYYvL7NGJi4',
);

void main() {
  bootstrap(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseAnonKey,
    );

    return const ProviderScope(child: UnifyApp());
  });
}
