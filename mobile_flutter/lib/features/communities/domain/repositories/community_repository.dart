import '../../data/models/community_detail_model.dart';

abstract class CommunityRepository {
  Future<CommunityDetailModel> getCommunityDetail(String communityId, {String? currentUserId});
  Future<List<CommunityDetailModel>> getMyCommunities(String userId);
  Future<List<CommunityDetailModel>> searchCommunities(String query, String universityId);
  Future<bool> joinCommunity(String communityId, String userId);
  Future<bool> leaveCommunity(String communityId, String userId);
  Future<bool> updateMemberCount(String communityId);
  Future<List<CommunityDetailModel>> getRecommendedCommunities(String userId);
}
