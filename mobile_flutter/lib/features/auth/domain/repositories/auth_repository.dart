import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signUp({required String email, required String password});
  Future<AppUser> signIn({required String email, required String password});
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
