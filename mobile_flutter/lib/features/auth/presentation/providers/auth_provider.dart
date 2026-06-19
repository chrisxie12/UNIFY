import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(supabaseProvider));
});

final currentAppUserProvider = FutureProvider<AppUser?>((ref) async {
  ref.watch(authStateProvider); // invalidate when auth changes
  return ref.watch(authRepositoryProvider).getCurrentUser();
});

class AuthNotifier extends AsyncNotifier<void> {
  late AuthRepository _repo;

  @override
  Future<void> build() async {
    _repo = ref.watch(authRepositoryProvider);
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signUp(email: email, password: password).then((_) {}),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signIn(email: email, password: password).then((_) {}),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repo.signOut);
  }

  Future<void> resetPassword(String email) async {
    await _repo.resetPassword(email);
  }

  Future<void> completeOnboarding({
    required String displayName,
    required String school,
    required String programme,
    required int yearOfStudy,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.completeOnboarding(
        displayName: displayName,
        school: school,
        programme: programme,
        yearOfStudy: yearOfStudy,
      ),
    );
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
