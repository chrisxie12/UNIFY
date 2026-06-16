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
