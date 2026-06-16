import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/community_repository.dart';
import '../models/community_detail_model.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final SupabaseClient _client;

  CommunityRepositoryImpl(this._client);

  @override
  Future<CommunityDetailModel> getCommunityDetail(String communityId, {String? currentUserId}) async {
    final response = await _client
        .from('communities')
        .select('*, universities(name), creator:profiles!created_by(display_name, avatar_url, is_verified_leader, leadership_role)')
        .filter('id', 'eq', communityId)
        .single();

    final univ = response['universities'] as Map<String, dynamic>?;
    final creator = response['creator'] as Map<String, dynamic>?;
    response['university_name'] = univ?['name'];
    response['creator_name'] = creator?['display_name'];
    response['creator_avatar'] = creator?['avatar_url'];
    response['creator_is_verified_leader'] = creator?['is_verified_leader'];
    response['creator_leadership_role'] = creator?['leadership_role'];

    if (currentUserId != null) {
      final allMembers = await _client
          .from('community_members')
          .select('user_id, role')
          .filter('community_id', 'eq', communityId) as List;
      final member = allMembers.cast<Map<String, dynamic>>().where((m) => m['user_id'] == currentUserId).toList();
      response['is_member'] = member.isNotEmpty;
      response['membership_role'] = member.isNotEmpty ? member.first['role'] : null;
    }

    final managersResponse = await _client
        .from('community_managers')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .filter('community_id', 'eq', communityId)
        .order('assigned_at') as List;

    final activeManagers = managersResponse.where((m) => m['is_active'] == true).toList();

    response['managers'] = activeManagers.map((m) {
      final p = m['profiles'] as Map<String, dynamic>?;
      if (p != null) {
        m['display_name'] = p['display_name'];
        m['avatar_url'] = p['avatar_url'];
        m['is_verified_leader'] = p['is_verified_leader'];
        m['leadership_role'] = p['leadership_role'];
      }
      return m;
    }).toList();

    return CommunityDetailModel.fromJson(response);
  }

  @override
  Future<List<CommunityDetailModel>> getMyCommunities(String userId) async {
    final response = await _client
        .from('community_members')
        .select('community_id, role, communities(*)')
        .filter('user_id', 'eq', userId) as List;

    return response.map((json) {
      final community = json['communities'] as Map<String, dynamic>;
      community['is_member'] = true;
      community['membership_role'] = json['role'];
      return CommunityDetailModel.fromJson(community);
    }).toList();
  }

  @override
  Future<List<CommunityDetailModel>> searchCommunities(String query, String universityId) async {
    final response = await _client
        .from('communities')
        .select('*')
        .order('member_count', ascending: false) as List;

    final results = response.where((c) {
      final name = (c['name'] as String?)?.toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) && c['is_active'] == true;
    }).take(20).toList();

    return results.map((json) => CommunityDetailModel.fromJson(json)).toList();
  }

  @override
  Future<bool> joinCommunity(String communityId, String userId) async {
    try {
      await _client.from('community_members').insert({
        'community_id': communityId,
        'user_id': userId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> leaveCommunity(String communityId, String userId) async {
    try {
      await _client.from('community_members').delete().filter('community_id', 'eq', communityId).filter('user_id', 'eq', userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> updateMemberCount(String communityId) async {
    return true;
  }
}
