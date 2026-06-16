import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/community_request_model.dart';
import '../../data/models/user_badge_model.dart';
import '../../data/repositories/leadership_repository_impl.dart';

final leadershipRepositoryProvider = Provider<LeadershipRepositoryImpl>((ref) {
  return LeadershipRepositoryImpl(ref.watch(supabaseProvider));
});

final userBadgesProvider = FutureProvider.autoDispose<List<UserBadgeModel>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];
  return ref.read(leadershipRepositoryProvider).getUserBadges(user.id);
});

final userLeadershipProvider = FutureProvider.autoDispose<List<UserLeadershipModel>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];
  return ref.read(leadershipRepositoryProvider).getUserLeadership(user.id);
});

final isVerifiedLeaderProvider = FutureProvider.autoDispose<bool>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return false;
  return ref.read(leadershipRepositoryProvider).isVerifiedLeader(user.id);
});

final myCommunityRequestsProvider = FutureProvider.autoDispose<List<CommunityRequestModel>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];
  return ref.read(leadershipRepositoryProvider).getMyRequests(user.id);
});

final otherUserBadgesProvider = FutureProvider.autoDispose.family<List<UserBadgeModel>, String>((ref, userId) async {
  return ref.read(leadershipRepositoryProvider).getUserBadges(userId);
});

final otherUserLeadershipProvider = FutureProvider.autoDispose.family<List<UserLeadershipModel>, String>((ref, userId) async {
  return ref.read(leadershipRepositoryProvider).getUserLeadership(userId);
});
