import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement_request_model.dart';
import '../models/badge_model.dart';
import '../models/community_request_model.dart';
import '../models/user_badge_model.dart';

class LeadershipRepositoryImpl {
  final SupabaseClient _client;

  LeadershipRepositoryImpl(this._client);

  // ── Badges ─────────────────────────────────────────────────

  Future<List<UserBadgeModel>> getUserBadges(String userId) async {
    final data = await _client
        .from('user_badges')
        .select('*, badges(*)')
        .eq('user_id', userId)
        .order('assigned_at', ascending: false);

    return (data as List).map((row) {
      final badge = BadgeModel.fromJson(row['badges'] as Map<String, dynamic>);
      return UserBadgeModel.fromJson(row as Map<String, dynamic>, badge: badge);
    }).toList();
  }

  // ── Leadership ─────────────────────────────────────────────

  Future<List<UserLeadershipModel>> getUserLeadership(String userId) async {
    final data = await _client
        .from('user_leadership')
        .select('*, leadership_roles(*)')
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (data as List).map((row) {
      final role = LeadershipRoleModel.fromJson(row['leadership_roles'] as Map<String, dynamic>);
      return UserLeadershipModel.fromJson(row as Map<String, dynamic>, role: role);
    }).toList();
  }

  Future<List<LeadershipRoleModel>> getAllRoles() async {
    final data = await _client
        .from('leadership_roles')
        .select()
        .limit(100)
        .order('priority', ascending: false);

    return (data as List).map((row) => LeadershipRoleModel.fromJson(row as Map<String, dynamic>)).toList();
  }

  /// Returns true if the user holds any active verified leadership position.
  Future<bool> isVerifiedLeader(String userId) async {
    final data = await _client
        .from('user_leadership')
        .select('id')
        .eq('user_id', userId)
        .eq('is_active', true);
    return (data as List).isNotEmpty;
  }

  // ── Community Requests ─────────────────────────────────────

  Future<CommunityRequestModel> createRequest(Map<String, dynamic> data) async {
    final result = await _client
        .from('community_requests')
        .insert(data)
        .select()
        .single();
    return CommunityRequestModel.fromJson(result);
  }

  Future<List<CommunityRequestModel>> getMyRequests(String userId) async {
    final data = await _client
        .from('community_requests')
        .select()
        .eq('requester_id', userId)
        .order('created_at', ascending: false);

    return data.map((row) => CommunityRequestModel.fromJson(row)).toList();
  }

  // ── Admin ──────────────────────────────────────────────────

  Future<List<CommunityRequestModel>> getAllRequests({List<String>? statuses}) async {
    var query = _client
        .from('community_requests')
        .select('*, profiles!community_requests_requester_id_fkey(full_name, avatar_url, programme, level)');

    final data = await query.limit(100).order('created_at', ascending: false);

    // Filter in Dart for compatibility with current Supabase client version
    if (statuses != null && statuses.isNotEmpty) {
      return (data as List)
          .map((row) => CommunityRequestModel.fromJson(row as Map<String, dynamic>))
          .where((r) => statuses.contains(r.status))
          .toList();
    }
    return (data as List).map((row) => CommunityRequestModel.fromJson(row as Map<String, dynamic>)).toList();
  }

  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    String? adminFeedback,
    required String reviewedBy,
  }) async {
    final updates = <String, dynamic>{
      'status': status,
      'reviewed_by': reviewedBy,
      'reviewed_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (adminFeedback != null) updates['admin_feedback'] = adminFeedback;
    await _client.from('community_requests').update(updates).eq('id', requestId);
  }

  /// Auto-creates a community from an approved request + assigns ownership.
  Future<void> approveAndCreateCommunity(Map<String, dynamic> requestData, String requestId) async {
    final slug = (requestData['community_name'] as String)
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    final community = await _client.from('communities').insert({
      'name': requestData['community_name'],
      'slug': slug,
      'description': requestData['purpose'],
      'community_type': requestData['community_type'],
      'university_id': requestData['university_id'],
      'faculty': requestData['faculty'],
      'department': requestData['department'],
      'programme': requestData['programme'],
      'level': requestData['level'],
      'academic_year': requestData['academic_year'],
      'created_by': requestData['requester_id'],
    }).select().single();

    await _client.from('community_members').insert({
      'community_id': community['id'],
      'user_id': requestData['requester_id'],
      'role': 'owner',
    });

    await _client.from('communities').update({'member_count': 1}).eq('id', community['id']);
  }

  // ── Community Managers ─────────────────────────────────────

  Future<List<CommunityManagerModel>> getCommunityManagers(String communityId) async {
    final data = await _client
        .from('community_managers')
        .select('*, profiles!community_managers_user_id_fkey(full_name, avatar_url)')
        .eq('community_id', communityId)
        .eq('is_active', true);

    return (data as List).map((row) => CommunityManagerModel.fromJson(row as Map<String, dynamic>)).toList();
  }

  Future<void> addCommunityManager({
    required String communityId,
    required String userId,
    required String role,
    required String assignedBy,
  }) async {
    await _client.from('community_managers').insert({
      'community_id': communityId,
      'user_id': userId,
      'role': role,
      'assigned_by': assignedBy,
    });
  }

  // ── Announcement Requests ──────────────────────────────────

  Future<AnnouncementRequestModel> createAnnouncementRequest(Map<String, dynamic> data) async {
    final result = await _client
        .from('announcement_requests')
        .insert(data)
        .select()
        .single();
    return AnnouncementRequestModel.fromJson(result as Map<String, dynamic>); // ignore: unnecessary_cast
  }

  Future<List<AnnouncementRequestModel>> getMyAnnouncementRequests(String userId) async {
    final data = await _client
        .from('announcement_requests')
        .select()
        .eq('requester_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((row) => AnnouncementRequestModel.fromJson(row as Map<String, dynamic>)).toList();
  }

  Future<List<AnnouncementRequestModel>> getAllAnnouncementRequests({List<String>? statuses}) async {
    var query = _client
        .from('announcement_requests')
        .select('*, profiles!announcement_requests_requester_id_fkey(full_name, avatar_url, programme)');

    final data = await query.limit(100).order('created_at', ascending: false);

    if (statuses != null && statuses.isNotEmpty) {
      return (data as List)
          .map((row) => AnnouncementRequestModel.fromJson(row as Map<String, dynamic>))
          .where((r) => statuses.contains(r.status))
          .toList();
    }
    return (data as List).map((row) => AnnouncementRequestModel.fromJson(row as Map<String, dynamic>)).toList();
  }

  Future<void> updateAnnouncementRequestStatus({
    required String requestId,
    required String status,
    String? adminNotes,
    required String reviewedBy,
  }) async {
    await _client.from('announcement_requests').update({
      'status': status,
      'admin_notes': adminNotes,
      'reviewed_by': reviewedBy,
      'reviewed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', requestId);

    if (status == 'approved') {
      // Fetch the request to create the actual announcement
      final req = await _client.from('announcement_requests').select().eq('id', requestId).single();
      await _client.from('announcements').insert({
        'author_id': req['requester_id'],
        'university_id': req['university_id'],
        'title': req['title'],
        'body': req['body'],
        'category': req['category'],
        'is_urgent': req['is_urgent'],
        'is_published': true,
        'published_at': DateTime.now().toUtc().toIso8601String(),
        'community_id': req['community_id'],
      });
    }
  }

  // ── My Communities (as manager/owner) ──────────────────────

  // ── My Communities (as owner/moderator) ────────────────────

  Future<List<Map<String, dynamic>>> getMyManagedCommunities(String userId) async {
    final data = await _client
        .from('community_members')
        .select('*, communities(*)')
        .eq('user_id', userId);
    // Filter in Dart for compatibility with current Supabase client version
    return (data as List)
        .where((r) => (r['role'] as String) == 'owner' || (r['role'] as String) == 'moderator')
        .cast<Map<String, dynamic>>()
        .toList();
  }

  // ── Duplicate Check ────────────────────────────────────────

  Future<bool> communitySlugExists(String slug) async {
    final data = await _client.from('communities').select('id').eq('slug', slug).maybeSingle();
    return data != null;
  }

  Future<bool> duplicateRequestExists({
    required String userId,
    required String communityName,
    required String communityType,
  }) async {
    final data = await _client
        .from('community_requests')
        .select('id, status')
        .eq('requester_id', userId)
        .eq('community_name', communityName)
        .eq('community_type', communityType);
    // Filter in Dart for compatibility with current Supabase client version
    final list = (data as List);
    return list.any((r) => (r['status'] as String) == 'pending' || (r['status'] as String) == 'approved');
  }

  // ── Community Members ──────────────────────────────────────

  Future<String?> getUserRoleInCommunity(String communityId, String userId) async {
    final data = await _client
        .from('community_members')
        .select('role')
        .eq('community_id', communityId)
        .eq('user_id', userId)
        .maybeSingle();
    return data?['role'] as String?;
  }

  // ── Search ─────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> searchProfiles({
    required String query,
    String? universityId,
    int limit = 20,
  }) async {
    final q = _client
        .from('profiles')
        .select('*, universities(name, short_name)')
        .or('full_name.ilike.%$query%,username.ilike.%$query%');

    if (universityId != null) {
      q.eq('university_id', universityId);
    }

    final data = await q.order('is_verified', ascending: false).limit(limit);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> searchCommunities({
    required String query,
    String? universityId,
    int limit = 20,
  }) async {
    final q = _client
        .from('communities')
        .select('*, universities(name, short_name)')
        .ilike('name', '%$query%');

    if (universityId != null) {
      q.eq('university_id', universityId);
    }

    final data = await q.limit(limit);
    return (data as List).cast<Map<String, dynamic>>();
  }
}
