import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/ambassador_models.dart';
import '../../data/repositories/ambassador_repository_impl.dart';

final ambassadorRepositoryProvider = Provider<AmbassadorRepository>((ref) {
  return AmbassadorRepository(ref.watch(supabaseProvider));
});

// ── Admin ────────────────────────────────────────────────────

final ambassadorsProvider =
    FutureProvider.autoDispose<List<Ambassador>>((ref) async {
  return ref.read(ambassadorRepositoryProvider).getAmbassadors();
});

final ambassadorDetailProvider =
    FutureProvider.autoDispose.family<Ambassador, String>((ref, id) async {
  return ref.read(ambassadorRepositoryProvider).getAmbassador(id);
});

final ambassadorEventsProvider = FutureProvider.autoDispose
    .family<List<AmbassadorEvent>, String>((ref, ambassadorId) async {
  return ref.read(ambassadorRepositoryProvider).getEvents(ambassadorId);
});

final ambassadorStatsProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  return ref.read(ambassadorRepositoryProvider).stats();
});

// ── Student-facing ───────────────────────────────────────────

final myAmbassadorProvider =
    FutureProvider.autoDispose<Ambassador?>((ref) async {
  ref.watch(authStateProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.read(ambassadorRepositoryProvider).myAmbassadorProfile(user.id);
});
