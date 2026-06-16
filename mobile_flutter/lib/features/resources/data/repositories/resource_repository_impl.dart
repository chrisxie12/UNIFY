import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/resource_repository.dart';
import '../models/community_resource_model.dart';

class ResourceRepositoryImpl implements ResourceRepository {
  final SupabaseClient _client;

  ResourceRepositoryImpl(this._client);

  @override
  Future<List<CommunityResourceModel>> getResources(String communityId, {String? resourceType}) async {
    final response = await _client
        .from('community_resources')
        .select('*, profiles(display_name, avatar_url)')
        .order('created_at', ascending: false) as List;

    final filtered = response.where((r) {
      final json = r as Map<String, dynamic>;
      if (json['community_id'] != communityId) return false;
      if (json['is_approved'] != true) return false;
      if (resourceType != null && resourceType != 'all' && json['resource_type'] != resourceType) return false;
      return true;
    }).toList();

    return filtered.map((json) {
      final profile = json['profiles'] as Map<String, dynamic>?;
      if (profile != null) {
        json['uploader_name'] = profile['display_name'];
        json['uploader_avatar'] = profile['avatar_url'];
      }
      return CommunityResourceModel.fromJson(json);
    }).toList();
  }

  @override
  Future<CommunityResourceModel> uploadResource(CommunityResourceModel resource) async {
    final response = await _client
        .from('community_resources')
        .insert(resource.toInsertJson())
        .select()
        .single();
    return CommunityResourceModel.fromJson(response);
  }

  @override
  Future<bool> deleteResource(String resourceId) async {
    try {
      await _client.from('community_resources').delete().filter('id', 'eq', resourceId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> approveResource(String resourceId) async {
    try {
      await _client.from('community_resources').update({'is_approved': true}).filter('id', 'eq', resourceId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> incrementDownloadCount(String resourceId) async {
    try {
      await _client.rpc('increment_resource_download', params: {'p_resource_id': resourceId});
      return true;
    } catch (_) {
      return false;
    }
  }
}
