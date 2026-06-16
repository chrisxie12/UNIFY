import '../models/community_resource_model.dart';

abstract class ResourceRepository {
  Future<List<CommunityResourceModel>> getResources(String communityId, {String? resourceType});
  Future<CommunityResourceModel> uploadResource(CommunityResourceModel resource);
  Future<bool> deleteResource(String resourceId);
  Future<bool> approveResource(String resourceId);
  Future<bool> incrementDownloadCount(String resourceId);
}
