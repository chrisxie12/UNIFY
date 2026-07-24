import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signUp({required String email, required String password});
  Future<AppUser> signIn({required String email, required String password});

  /// Launches the Google OAuth flow. The session is delivered asynchronously
  /// via the deep-link callback handled by supabase_flutter.
  Future<void> signInWithGoogle();

  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<AppUser?> getCurrentUser();
  Stream<AppUser?> watchCurrentUser();
  Future<void> completeOnboarding({
    required String displayName,
    required String school,
    required String programme,
    required int yearOfStudy,
  });
}
