import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  bool get hasSession => _client.auth.currentSession != null;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user);
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final user = res.user;
    if (user == null) throw const AuthException('Sign in failed.');
    return _fetchProfile(user);
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await _client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: {'full_name': fullName.trim()},
    );
    final user = res.user;
    if (user == null) throw const AuthException('Sign up failed.');
    // Profile row is auto-created by the handle_new_user() trigger.
    // Return a minimal entity for immediate navigation.
    return UserModel(
      id: user.id,
      email: user.email ?? email,
      fullName: fullName.trim(),
      universityId: '',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  // ── helpers ──────────────────────────────────────────────────────────────

  Future<UserEntity> _fetchProfile(User user) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      // Profile not yet created (race with trigger). Return minimal entity.
      return UserModel(
        id: user.id,
        email: user.email ?? '',
        universityId: '',
        createdAt: DateTime.now(),
      );
    }

    return UserModel.fromJson(data, email: user.email ?? '');
  }
}
