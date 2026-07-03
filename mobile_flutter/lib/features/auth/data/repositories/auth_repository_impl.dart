import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient? _client;

  AuthRepositoryImpl(this._client);

  SupabaseClient get _safeClient {
    final c = _client;
    if (c == null) throw Exception('Supabase not initialized');
    return c;
  }

  @override
  Future<AppUser> signUp({required String email, required String password}) async {
    final c = _safeClient;
    final res = await c.auth.signUp(email: email, password: password);
    final user = res.user;
    if (user == null) throw Exception('Sign up failed — please try again.');
    if (res.session == null) {
      // Supabase has email confirmation enabled. The account was created but
      // no session exists until the user clicks the link in their inbox.
      throw Exception(
        'Account created! Check your inbox for a confirmation link, then sign in.',
      );
    }
    return _fetchProfileWithClient(c, user.id, email);
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    final c = _safeClient;
    final res = await c.auth.signInWithPassword(email: email, password: password);
    final user = res.user;
    if (user == null) throw Exception('Sign in failed');
    return _fetchProfileWithClient(c, user.id, email);
  }

  @override
  Future<void> signInWithGoogle() async {
    final c = _safeClient;
    if (kIsWeb) {
      await c.auth.signInWithOAuth(
        OAuthProvider.google,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
    } else {
      await c.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.gctu.unify://auth/callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Future<void> signOut() => _safeClient.auth.signOut();

  @override
  Future<void> resetPassword(String email) async {
    await _safeClient.auth.resetPasswordForEmail(email);
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final c = _client;
    if (c == null) return null;
    final user = c.auth.currentUser;
    if (user == null) return null;
    return _fetchProfileWithClient(c, user.id, user.email ?? '');
  }

  @override
  Stream<AppUser?> watchCurrentUser() {
    final c = _client;
    if (c == null) return const Stream.empty();
    return c.auth.onAuthStateChange.asyncMap((event) async {
      final session = event.session;
      if (session == null) return null;
      return _fetchProfileWithClient(c, session.user.id, session.user.email ?? '');
    });
  }

  @override
  Future<void> completeOnboarding({
    required String displayName,
    required String school,
    required String programme,
    required int yearOfStudy,
  }) async {
    final c = _safeClient;
    final userId = c.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    await c.from('profiles').upsert({
      'id': userId,
      'full_name': displayName,
      'university_name': school,
      'programme': programme,
      'level': yearOfStudy.toString(),
      'onboarding_complete': true,
    });
  }

  Future<AppUser> _fetchProfileWithClient(SupabaseClient client, String userId, String email) async {
    final data = await client.from('profiles').select().eq('id', userId).maybeSingle();
    if (data == null) {
      return AppUserModel(
        id: userId,
        email: email,
        role: 'student',
        onboardingComplete: false,
        createdAt: DateTime.now(),
      );
    }
    return AppUserModel.fromJson({...data, 'email': email, 'email_backup': data['email_backup']});
  }
}
