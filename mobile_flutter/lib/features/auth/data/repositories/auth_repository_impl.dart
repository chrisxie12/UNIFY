import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<AppUser> signUp({required String email, required String password}) async {
    final res = await _client.auth.signUp(email: email, password: password);
    if (res.user == null) throw Exception('Sign up failed — please try again.');
    if (res.session == null) {
      // Supabase has email confirmation enabled. The account was created but
      // no session exists until the user clicks the link in their inbox.
      throw Exception(
        'Account created! Check your inbox for a confirmation link, then sign in.',
      );
    }
    return _fetchProfile(res.user!.id, email);
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    if (res.user == null) throw Exception('Sign in failed');
    return _fetchProfile(res.user!.id, email);
  }

  @override
  Future<void> signInWithGoogle() async {
    // Google rejects OAuth performed inside an embedded WebView
    // (error: disallowed_useragent). Force the external browser / Custom Tab.
    // The session is delivered back via the com.gctu.unify://auth deep link,
    // which Supabase consumes through onAuthStateChange (PKCE flow).
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.gctu.unify://auth/callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id, user.email ?? '');
  }

  @override
  Stream<AppUser?> watchCurrentUser() {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      if (event.session == null) return null;
      final u = event.session!.user;
      return _fetchProfile(u.id, u.email ?? '');
    });
  }

  @override
  Future<void> completeOnboarding({
    required String displayName,
    required String school,
    required String programme,
    required int yearOfStudy,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    await _client.from('profiles').upsert({
      'id': userId,
      'full_name': displayName,
      'university_name': school,
      'programme': programme,
      'level': yearOfStudy.toString(),
      'onboarding_complete': true,
    });
  }

  Future<AppUser> _fetchProfile(String userId, String email) async {
    final data = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    if (data == null) {
      // Profile doesn't exist yet (first sign-up before trigger fires)
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
