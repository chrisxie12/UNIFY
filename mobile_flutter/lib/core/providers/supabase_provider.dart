import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  try {
    return Supabase.instance.client;
  } catch (e) {
    debugPrint('[supabase] Not initialized — some features will be unavailable: $e');
    rethrow;
  }
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  try {
    return ref.watch(supabaseProvider).auth.onAuthStateChange;
  } catch (e) {
    debugPrint('[authState] Supabase unavailable, using empty stream: $e');
    return const Stream.empty();
  }
});

final currentUserProvider = Provider<User?>((ref) {
  try {
    return ref.watch(supabaseProvider).auth.currentUser;
  } catch (e) {
    debugPrint('[currentUser] Supabase unavailable: $e');
    return null;
  }
});
