import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../leadership/data/models/community_request_model.dart';
import '../models/community_content_models.dart';

class CommunitiesRepositoryImpl {
  final SupabaseClient _client;
  CommunitiesRepositoryImpl(this._client);

  // ── Browse / discover ───────────────────────────────────────

  Future<List<CommunityModel>> getCommunities({
    String? universityId,
    List<String>? types,
    String? search,
    int limit = 40,
  }) async {
    var query = _client
        .from('communities')
        .select()
        .eq('is_active', true);

    if (universityId != null) query = query.eq('university_id', universityId);
    if (search != null && search.isNotEmpty) {
      query = query.ilike('name', '%$search%');
    }

    final data = await query
        .order('member_count', ascending: false)
        .limit(limit);

    var communities = (data as List)
        .map((r) => CommunityModel.fromJson(r as Map<String, dynamic>))
        .toList();

    // Client-side type filter for multi-type groups
    if (types != null && types.isNotEmpty) {
      communities = communities.where((c) => types.contains(c.communityType)).toList();
    }

    return communities;
  }

  Future<CommunityModel?> getCommunityById(String id) async {
    final data = await _client
        .from('communities')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return CommunityModel.fromJson(data);
  }

  // ── Membership ──────────────────────────────────────────────

  Future<List<CommunityModel>> getMyMemberships(String userId) async {
    final data = await _client
        .from('community_members')
        .select('communities(*)')
        .eq('user_id', userId)
        .limit(50);

    return (data as List)
        .map((r) => CommunityModel.fromJson(r['communities'] as Map<String, dynamic>))
        .toList();
  }

  Future<String?> getUserRole(String communityId, String userId) async {
    final data = await _client
        .from('community_members')
        .select('role')
        .eq('community_id', communityId)
        .eq('user_id', userId)
        .maybeSingle();
    return data?['role'] as String?;
  }

  Future<void> joinCommunity(String communityId, String userId) async {
    await _client.from('community_members').insert({
      'community_id': communityId,
      'user_id': userId,
      'role': 'member',
    });
    // member_count is updated by DB trigger
  }

  Future<void> leaveCommunity(String communityId, String userId) async {
    await _client
        .from('community_members')
        .delete()
        .eq('community_id', communityId)
        .eq('user_id', userId);
    // member_count is updated by DB trigger
  }

  // ── Members list ────────────────────────────────────────────

  Future<List<CommunityMemberProfile>> getMembers(String communityId) async {
    final data = await _client
        .from('community_members')
        .select(
          '*, profiles!community_members_user_id_fkey('
          'full_name, avatar_url, programme, level, '
          'is_verified_leader, leadership_role'
          ')',
        )
        .eq('community_id', communityId)
        .order('joined_at', ascending: true)
        .limit(50);

    final members = (data as List)
        .map((r) => CommunityMemberProfile.fromJson(r as Map<String, dynamic>))
        .toList();

    // Sort: owners first, then moderators, then members
    const roleOrder = {'owner': 0, 'moderator': 1, 'member': 2};
    members.sort((a, b) =>
        (roleOrder[a.role] ?? 3).compareTo(roleOrder[b.role] ?? 3));

    return members;
  }

  // ── Community announcements ─────────────────────────────────

  Future<List<Map<String, dynamic>>> getCommunityAnnouncements(
    String communityId,
  ) async {
    final data = await _client
        .from('announcements')
        .select('*, profiles!author_id(full_name, avatar_url, is_verified_leader, leadership_role)')
        .eq('community_id', communityId)
        .eq('is_published', true)
        .order('is_pinned', ascending: false)
        .order('created_at', ascending: false)
        .limit(20);
    return (data as List).cast<Map<String, dynamic>>();
  }

  // ── Discussion posts ────────────────────────────────────────

  Future<List<CommunityPostModel>> getPosts(String communityId, {int limit = 20}) async {
    final data = await _client
        .from('community_posts')
        .select(
          '*, profiles!community_posts_author_id_fkey('
          'full_name, avatar_url, is_verified_leader, leadership_role'
          ')',
        )
        .eq('community_id', communityId)
        .order('is_pinned', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List)
        .map((r) => CommunityPostModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<CommunityPostModel> createPost({
    required String communityId,
    required String authorId,
    required String body,
    String? title,
    bool isPinned = false,
  }) async {
    final result = await _client
        .from('community_posts')
        .insert({
          'community_id': communityId,
          'author_id': authorId,
          'body': body,
          if (title != null && title.isNotEmpty) 'title': title,
          'is_pinned': isPinned,
        })
        .select(
          '*, profiles!community_posts_author_id_fkey('
          'full_name, avatar_url, is_verified_leader, leadership_role'
          ')',
        )
        .single();
    return CommunityPostModel.fromJson(result);
  }

  Future<void> deletePost(String postId) async {
    await _client.from('community_posts').delete().eq('id', postId);
  }

  // ── Comments ────────────────────────────────────────────────

  Future<List<CommunityCommentModel>> getComments(String postId) async {
    final data = await _client
        .from('post_comments')
        .select(
          '*, profiles!post_comments_author_id_fkey('
          'full_name, avatar_url, is_verified_leader'
          ')',
        )
        .eq('post_id', postId)
        .order('created_at', ascending: true)
        .limit(50);

    return (data as List)
        .map((r) => CommunityCommentModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> addComment({
    required String postId,
    required String authorId,
    required String body,
    String? parentId,
  }) async {
    await _client.from('post_comments').insert({
      'post_id': postId,
      'author_id': authorId,
      'body': body,
      if (parentId != null) 'parent_id': parentId,
    });
  }

  // ── Reactions ───────────────────────────────────────────────

  Future<bool> togglePostReaction(String postId, String userId) async {
    final existing = await _client
        .from('post_likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
      return false; // unliked
    } else {
      await _client.from('post_likes').insert({
        'post_id': postId,
        'user_id': userId,
      });
      return true; // liked
    }
  }

  // ── Resources ───────────────────────────────────────────────

  Future<List<CommunityResourceModel>> getResources(
    String communityId, {
    String? category,
    int limit = 20,
  }) async {
    var query = _client
        .from('community_resources')
        .select(
          '*, profiles!community_resources_uploader_id_fkey('
          'full_name, avatar_url'
          ')',
        )
        .eq('community_id', communityId);

    if (category != null) query = query.eq('category', category);

    final data = await query.order('created_at', ascending: false).limit(limit);

    return (data as List)
        .map((r) => CommunityResourceModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> incrementDownloads(String resourceId) async {
    await _client.rpc('increment_resource_downloads', params: {'rid': resourceId});
  }
}
