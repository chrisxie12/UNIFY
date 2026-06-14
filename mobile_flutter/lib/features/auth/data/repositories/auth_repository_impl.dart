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
    if (res.user == null) throw Exception('Sign up failed');
    return _fetchProfile(res.user!.id, email);
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    if (res.user == null) throw Exception('Sign in failed');
    return _fetchProfile(res.user!.id, email);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

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
    required String programme,
    required int yearOfStudy,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    await _client.from('profiles').upsert({
      'id': userId,
      'display_name': displayName,
      'programme': programme,
      'year_of_study': yearOfStudy,
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
    return AppUserModel.fromJson({...data, 'email': email});
  }
}
