import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../domain/repositories/community_repository.dart';
import '../../data/models/community_detail_model.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepositoryImpl(ref.watch(supabaseProvider));
});

final communityDetailProvider = FutureProvider.family<CommunityDetailModel, String>((ref, communityId) async {
  final repo = ref.watch(communityRepositoryProvider);
  return repo.getCommunityDetail(communityId);
});

final myCommunitiesProvider = FutureProvider.family<List<CommunityDetailModel>, String>((ref, userId) async {
  final repo = ref.watch(communityRepositoryProvider);
  return repo.getMyCommunities(userId);
});

final communitySearchProvider = FutureProvider.family<List<CommunityDetailModel>, String>((ref, query) async {
  final repo = ref.watch(communityRepositoryProvider);
  return repo.searchCommunities(query, '');
});

// Recommended communities for a user based on their profile
final recommendedCommunitiesProvider = FutureProvider.family<List<CommunityDetailModel>, String>((ref, userId) async {
  final repo = ref.watch(communityRepositoryProvider);
  return repo.getRecommendedCommunities(userId);
});

// Community members list
final communityMembersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, communityId) async {
  final supabase = ref.watch(supabaseProvider);
  final response = await supabase
      .from('community_members')
      .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role, programme, level)')
      .filter('community_id', 'eq', communityId) as List;
  return response.cast<Map<String, dynamic>>();
});

// Is current user a manager
final isCommunityManagerProvider = FutureProvider.family<bool, String>((ref, communityId) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return false;
  final response = await supabase
      .from('community_managers')
      .select('id')
      .filter('community_id', 'eq', communityId)
      .filter('user_id', 'eq', userId)
      .filter('is_active', 'eq', true) as List;
  return response.isNotEmpty;
});
