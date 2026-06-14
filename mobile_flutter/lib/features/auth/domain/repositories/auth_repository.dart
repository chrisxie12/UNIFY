import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  /// Stream of Supabase auth state changes
  Stream<AuthState> get authStateChanges;

  /// Returns the currently signed-in user's profile, or null
  Future<UserEntity?> getCurrentUser();

  /// Sign in with email + password
  Future<UserEntity> signIn({required String email, required String password});

  /// Sign up — creates auth user and returns minimal entity
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sign out
  Future<void> signOut();

  /// Whether there is an active session right now
  bool get hasSession;
}
