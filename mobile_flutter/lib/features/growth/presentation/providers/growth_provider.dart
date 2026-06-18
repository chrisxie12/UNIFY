import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/growth_models.dart';
import '../../data/repositories/growth_repository_impl.dart';

final growthRepositoryProvider = Provider<GrowthRepositoryImpl>((ref) {
  return GrowthRepositoryImpl(ref.watch(supabaseProvider));
});

// ── Admin: Waitlist / Codes / Beta / Referrals ───────────────

final waitlistProvider =
    FutureProvider.autoDispose<List<WaitlistEntry>>((ref) async {
  return ref.read(growthRepositoryProvider).getWaitlist();
});

final inviteCodesProvider =
    FutureProvider.autoDispose<List<InviteCode>>((ref) async {
  return ref.read(growthRepositoryProvider).getInviteCodes();
});

final betaTestersProvider =
    FutureProvider.autoDispose<List<BetaTester>>((ref) async {
  return ref.read(growthRepositoryProvider).getBetaTesters();
});

final allReferralsProvider =
    FutureProvider.autoDispose<List<Referral>>((ref) async {
  return ref.read(growthRepositoryProvider).getAllReferrals();
});

// ── Student-facing referrals ─────────────────────────────────

final myReferralsProvider =
    FutureProvider.autoDispose<List<Referral>>((ref) async {
  ref.watch(authStateProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(growthRepositoryProvider).getMyReferrals(user.id);
});

final myReferralCodeProvider =
    FutureProvider.autoDispose<InviteCode?>((ref) async {
  ref.watch(authStateProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.read(growthRepositoryProvider).getMyReferralCode(user.id);
});

final referralStatsProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  ref.watch(authStateProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return {'sent': 0, 'accepted': 0, 'active': 0};
  return ref.read(growthRepositoryProvider).referralStats(user.id);
});
