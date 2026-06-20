import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/admin_repository.dart';
import '../models/university_model.dart';
import '../models/faculty_model.dart';
import '../models/department_model.dart';
import '../models/admin_role_model.dart';
import '../models/administrator_model.dart';
import '../models/audit_log_model.dart';
import '../models/moderation_item_model.dart';
import '../models/admin_announcement_model.dart';
import '../models/opportunity_model.dart';
import '../models/marketplace_report_model.dart';
import '../models/analytics_snapshot_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final SupabaseClient _client;

  AdminRepositoryImpl(this._client);

  String get _actorId => _client.auth.currentUser?.id ?? '';

  Future<void> _sendNotification({
    required String userId,
    required String type,
    required String title,
    String? body,
    String? referenceId,
    String? referenceType,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _client.rpc('create_notification', params: {
        'p_user_id': userId,
        'p_type': type,
        'p_title': title,
        'p_body': body,
        'p_reference_id': referenceId,
        'p_reference_type': referenceType,
        'p_data': data ?? {},
      });
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] sendNotification error: $e');
    }
  }

  // ── Universities ──

  @override
  Future<List<UniversityModel>> getUniversities() async {
    final response = await _client
        .from('universities')
        .select()
        .order('name', ascending: true)
        .limit(100) as List;
    return response.map((json) => UniversityModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<UniversityModel> getUniversity(String id) async {
    final response = await _client
        .from('universities')
        .select()
        .filter('id', 'eq', id)
        .single();
    return UniversityModel.fromJson(response);
  }

  @override
  Future<UniversityModel> createUniversity(Map<String, dynamic> data) async {
    final response = await _client
        .from('universities')
        .insert(data)
        .select()
        .single();
    final model = UniversityModel.fromJson(response);
    await logAction(_actorId, 'create_university', 'university', model.id,
        details: {'name': data['name'] as String? ?? ''});
    return model;
  }

  @override
  Future<bool> updateUniversity(String id, Map<String, dynamic> updates) async {
    try {
      await _client.from('universities').update(updates).filter('id', 'eq', id);
      await logAction(_actorId, 'update_university', 'university', id);
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteUniversity(String id) async {
    try {
      await _client.from('universities').delete().filter('id', 'eq', id);
      await logAction(_actorId, 'delete_university', 'university', id);
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Faculties ──

  @override
  Future<List<FacultyModel>> getFaculties(String universityId) async {
    final response = await _client
        .from('faculties')
        .select()
        .filter('university_id', 'eq', universityId)
        .order('name', ascending: true)
        .limit(100) as List;
    return response.map((json) => FacultyModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<FacultyModel> getFaculty(String id) async {
    final response = await _client
        .from('faculties')
        .select()
        .filter('id', 'eq', id)
        .single();
    return FacultyModel.fromJson(response);
  }

  @override
  Future<FacultyModel> createFaculty(Map<String, dynamic> data) async {
    final response = await _client
        .from('faculties')
        .insert(data)
        .select()
        .single();
    final model = FacultyModel.fromJson(response);
    await logAction(_actorId, 'create_faculty', 'faculty', model.id,
        details: {'name': data['name'] as String? ?? ''});
    return model;
  }

  @override
  Future<bool> updateFaculty(String id, Map<String, dynamic> updates) async {
    try {
      await _client.from('faculties').update(updates).filter('id', 'eq', id);
      await logAction(_actorId, 'update_faculty', 'faculty', id);
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteFaculty(String id) async {
    try {
      await _client.from('faculties').delete().filter('id', 'eq', id);
      await logAction(_actorId, 'delete_faculty', 'faculty', id);
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Departments ──

  @override
  Future<List<DepartmentModel>> getDepartments(String facultyId) async {
    final response = await _client
        .from('departments')
        .select()
        .filter('faculty_id', 'eq', facultyId)
        .order('name', ascending: true)
        .limit(200) as List;
    return response.map((json) => DepartmentModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<DepartmentModel> getDepartment(String id) async {
    final response = await _client
        .from('departments')
        .select()
        .filter('id', 'eq', id)
        .single();
    return DepartmentModel.fromJson(response);
  }

  @override
  Future<DepartmentModel> createDepartment(Map<String, dynamic> data) async {
    final response = await _client
        .from('departments')
        .insert(data)
        .select()
        .single();
    final model = DepartmentModel.fromJson(response);
    await logAction(_actorId, 'create_department', 'department', model.id,
        details: {'name': data['name'] as String? ?? ''});
    return model;
  }

  @override
  Future<bool> updateDepartment(String id, Map<String, dynamic> updates) async {
    try {
      await _client.from('departments').update(updates).filter('id', 'eq', id);
      await logAction(_actorId, 'update_department', 'department', id);
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteDepartment(String id) async {
    try {
      await _client.from('departments').delete().filter('id', 'eq', id);
      await logAction(_actorId, 'delete_department', 'department', id);
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Admin Roles & Administrators ──

  @override
  Future<List<AdminRoleModel>> getAdminRoles() async {
    final response = await _client
        .from('admin_roles')
        .select()
        .order('role', ascending: true)
        .limit(50) as List;
    return response.map((json) => AdminRoleModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<AdministratorModel>> getAdministrators({String? universityId, String? facultyId, String? departmentId}) async {
    dynamic query = _client
        .from('university_administrators')
        .select('*, admin_roles(role, description), profiles(full_name, avatar_url)');
    if (universityId != null) query = query.filter('university_id', 'eq', universityId);
    if (facultyId != null) query = query.filter('faculty_id', 'eq', facultyId);
    if (departmentId != null) query = query.filter('department_id', 'eq', departmentId);
    final response = await query.order('created_at', ascending: false).limit(100) as List;
    return response.map((json) => AdministratorModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<AdministratorModel> assignAdminRole(Map<String, dynamic> data) async {
    final response = await _client
        .from('university_administrators')
        .insert(data)
        .select('*, admin_roles(role, description), profiles(full_name, avatar_url)')
        .single();
    final model = AdministratorModel.fromJson(response);
    await logAction(_actorId, 'assign_admin_role', 'admin', model.id,
        details: {'user_id': model.userId, 'role': model.roleName ?? ''});
    await _sendNotification(
      userId: model.userId,
      type: 'role_assigned',
      title: 'Admin Role Assigned',
      body: model.roleName != null
          ? 'You have been assigned the admin role: ${model.roleName}.'
          : 'You have been assigned an admin role.',
      referenceId: model.id,
      referenceType: 'admin_role',
      data: {'admin_id': model.id, 'role': model.roleName ?? ''},
    );
    return model;
  }

  @override
  Future<bool> updateAdminStatus(String id, bool isActive) async {
    try {
      final adminRecord = await _client.from('university_administrators')
          .select('user_id').filter('id', 'eq', id).single();
      final userId = adminRecord['user_id'] as String;
      await _client.from('university_administrators').update({'is_active': isActive}).filter('id', 'eq', id);
      await logAction(_actorId, 'update_admin_status', 'admin', id, details: {'is_active': isActive});
      await _sendNotification(
        userId: userId,
        type: isActive ? 'role_assigned' : 'admin_removed',
        title: isActive ? 'Admin Access Restored' : 'Admin Access Suspended',
        body: isActive
            ? 'Your admin privileges have been reinstated.'
            : 'Your admin privileges have been temporarily suspended.',
        referenceId: id,
        referenceType: 'admin_role',
        data: {'admin_id': id, 'is_active': isActive},
      );
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> removeAdmin(String id) async {
    try {
      final adminRecord = await _client.from('university_administrators')
          .select('user_id').filter('id', 'eq', id).single();
      final userId = adminRecord['user_id'] as String;
      await _client.from('university_administrators').delete().filter('id', 'eq', id);
      await logAction(_actorId, 'remove_admin', 'admin', id);
      await _sendNotification(
        userId: userId,
        type: 'admin_removed',
        title: 'Admin Role Removed',
        body: 'Your admin role has been removed from the system.',
        referenceId: id,
        referenceType: 'admin_role',
        data: {'admin_id': id},
      );
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<String?> getUserAdminRole(String userId) async {
    final response = await _client
        .from('university_administrators')
        .select('admin_roles!inner(role)')
        .filter('user_id', 'eq', userId)
        .filter('is_active', 'eq', true)
        .maybeSingle();
    if (response == null) return null;
    final roleData = response['admin_roles'] as Map<String, dynamic>?;
    return roleData?['role'] as String?;
  }

  // ── Verification ──

  @override
  Future<List<Map<String, dynamic>>> getVerificationRequests({String? status}) async {
    dynamic query = _client
        .from('verification_requests')
        .select('*, profiles!verification_requests_user_id_fkey(full_name, avatar_url, programme, faculty, department, university_id)')
        .order('created_at', ascending: false)
        .limit(100);
    if (status != null) query = query.filter('status', 'eq', status);
    final response = await query as List;
    return response.cast<Map<String, dynamic>>();
  }

  @override
  Future<bool> approveVerification(String requestId, String reviewedBy, {String? roleId, String? notes}) async {
    try {
      await _client.from('verification_requests').update({
        'status': 'approved',
        'reviewed_by': reviewedBy,
        'reviewed_at': DateTime.now().toIso8601String(),
        if (notes != null) 'admin_notes': notes,
      }).filter('id', 'eq', requestId);
      final request = await _client.from('verification_requests')
          .select('user_id').filter('id', 'eq', requestId).single();
      await _client.from('profiles').update({'is_verified': true}).filter('id', 'eq', request['user_id']);
      await logAction(reviewedBy, 'approve_verification', 'verification', requestId,
          details: {if (notes != null) 'notes': notes});
      await _sendNotification(
        userId: request['user_id'] as String,
        type: 'verification_approved',
        title: 'Verification Approved ✓',
        body: notes != null
            ? 'Your verification was approved. $notes'
            : 'Your identity has been verified. Welcome to the verified community!',
        referenceId: requestId,
        referenceType: 'verification',
        data: {'request_id': requestId},
      );
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> rejectVerification(String requestId, String reviewedBy, {String? notes}) async {
    try {
      await _client.from('verification_requests').update({
        'status': 'rejected',
        'reviewed_by': reviewedBy,
        'reviewed_at': DateTime.now().toIso8601String(),
        if (notes != null) 'admin_notes': notes,
      }).filter('id', 'eq', requestId);
      final req = await _client.from('verification_requests')
          .select('user_id').filter('id', 'eq', requestId).single();
      await logAction(reviewedBy, 'reject_verification', 'verification', requestId,
          details: {if (notes != null) 'notes': notes});
      await _sendNotification(
        userId: req['user_id'] as String,
        type: 'verification_rejected',
        title: 'Verification Not Approved',
        body: notes ?? 'Your verification request was not approved at this time. You may resubmit with additional documentation.',
        referenceId: requestId,
        referenceType: 'verification',
        data: {'request_id': requestId},
      );
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> assignBadge(String userId, String badgeId) async {
    try {
      await _client.from('user_badges').insert({
        'user_id': userId, 'badge_id': badgeId, 'awarded_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> revokeBadge(String userId, String badgeId) async {
    try {
      await _client.from('user_badges').delete()
          .filter('user_id', 'eq', userId)
          .filter('badge_id', 'eq', badgeId);
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Moderation ──

  @override
  Future<List<ModerationItemModel>> getModerationQueue({String? status, String? reportType}) async {
    dynamic query = _client
        .from('moderation_queue')
        .select('*, profiles(reported_by:fk_reported_by!inner(full_name))')
        .order('created_at', ascending: false)
        .limit(100);
    if (status != null) query = query.filter('status', 'eq', status);
    if (reportType != null) query = query.filter('report_type', 'eq', reportType);
    final response = await query as List;
    return response.map((json) => ModerationItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> updateModerationStatus(String id, String status, String reviewedBy, {String? resolution}) async {
    try {
      await _client.from('moderation_queue').update({
        'status': status,
        'reviewed_by': reviewedBy,
        'updated_at': DateTime.now().toIso8601String(),
        if (resolution != null) 'resolution': resolution,
      }).filter('id', 'eq', id);
      await logAction(reviewedBy, '${status}_moderation', 'moderation', id,
          details: {if (resolution != null) 'resolution': resolution});
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Marketplace ──

  @override
  Future<List<MarketplaceReportModel>> getMarketplaceReports({String? status}) async {
    dynamic query = _client
        .from('marketplace_reports')
        .select('*, profiles(full_name)')
        .order('created_at', ascending: false)
        .limit(100);
    if (status != null) query = query.filter('status', 'eq', status);
    final response = await query as List;
    return response.map((json) => MarketplaceReportModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> resolveMarketplaceReport(String id, String action, String reviewedBy) async {
    try {
      final report = await _client.from('marketplace_reports')
          .select('reporter_id').filter('id', 'eq', id).single();
      await _client.from('marketplace_reports').update({
        'status': 'resolved',
        'action_taken': action,
        'reviewed_by': reviewedBy,
      }).filter('id', 'eq', id);
      await logAction(reviewedBy, 'resolve_marketplace_report', 'marketplace_report', id,
          details: {'action': action});
      await _sendNotification(
        userId: report['reporter_id'] as String,
        type: 'marketplace_report_resolved',
        title: 'Your Report Has Been Reviewed',
        body: 'We reviewed your marketplace report and took action: $action.',
        referenceId: id,
        referenceType: 'marketplace_report',
        data: {'report_id': id, 'action': action},
      );
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Opportunities ──

  @override
  Future<List<OpportunityModel>> getOpportunities({String? status, String? type}) async {
    dynamic query = _client
        .from('opportunities')
        .select('*, profiles(full_name), universities(name)')
        .order('created_at', ascending: false)
        .limit(100);
    if (status != null) query = query.filter('status', 'eq', status);
    if (type != null) query = query.filter('opportunity_type', 'eq', type);
    final response = await query as List;
    return response.map((json) => OpportunityModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> updateOpportunityStatus(String id, String status, String reviewedBy) async {
    try {
      await _client.from('opportunities').update({
        'status': status,
        'reviewed_by': reviewedBy,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).filter('id', 'eq', id);
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Analytics ──

  @override
  Future<AnalyticsSnapshotModel> getLatestAnalytics(String? universityId) async {
    dynamic query = _client
        .from('analytics_snapshots')
        .select()
        .order('snapshot_date', ascending: false)
        .limit(1);
    if (universityId != null) query = query.filter('university_id', 'eq', universityId);
    final response = await query as List;
    if (response.isEmpty) {
      return AnalyticsSnapshotModel(
        id: '',
        universityId: universityId,
        snapshotDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
    }
    return AnalyticsSnapshotModel.fromJson(response.first as Map<String, dynamic>);
  }

  @override
  Future<List<AnalyticsSnapshotModel>> getAnalyticsHistory(String? universityId, {int days = 30}) async {
    dynamic query = _client
        .from('analytics_snapshots')
        .select()
        .order('snapshot_date', ascending: false)
        .limit(days);
    if (universityId != null) query = query.filter('university_id', 'eq', universityId);
    final response = await query as List;
    return response.map((json) => AnalyticsSnapshotModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  // ── Audit Logs ──

  @override
  Future<List<AuditLogModel>> getAuditLogs({
    String? universityId,
    String? actionFilter,
    String? entityType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    dynamic query = _client
        .from('audit_logs')
        .select('*, profiles(full_name)')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    if (universityId != null) query = query.filter('university_id', 'eq', universityId);
    if (actionFilter != null) query = query.filter('action', 'ilike', '%$actionFilter%');
    if (entityType != null) query = query.filter('entity_type', 'eq', entityType);
    if (startDate != null) query = query.filter('created_at', 'gte', startDate.toIso8601String());
    if (endDate != null) query = query.filter('created_at', 'lte', endDate.toIso8601String());
    final response = await query as List;
    return response.map((json) => AuditLogModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> logAction(String actorId, String action, String entityType, String? entityId, {String? universityId, Map<String, dynamic>? details}) async {
    try {
      await _client.rpc('log_admin_action', params: {
        'actor_id': actorId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'university_id': universityId,
        'details': details ?? {},
      });
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] logAction (rpc) error: $e');
      try {
        await _client.from('audit_logs').insert({
          'actor_id': actorId,
          'action': action,
          'entity_type': entityType,
          'entity_id': entityId,
          'university_id': universityId,
          'details': details ?? {},
        });
      } catch (e2) {
        debugPrint('[AdminRepositoryImpl] logAction (fallback) error: $e2');
      }
    }
  }

  // ── Announcements ──

  @override
  Future<List<AdminAnnouncementModel>> getAnnouncements({String? scopeType, String? scopeId}) async {
    dynamic query = _client
        .from('admin_announcements')
        .select('*, profiles(full_name)')
        .order('created_at', ascending: false)
        .limit(100);
    if (scopeType != null) query = query.filter('scope_type', 'eq', scopeType);
    if (scopeId != null) query = query.filter('scope_id', 'eq', scopeId);
    final response = await query as List;
    return response.map((json) => AdminAnnouncementModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<AdminAnnouncementModel> createAnnouncement(Map<String, dynamic> data) async {
    final response = await _client
        .from('admin_announcements')
        .insert(data)
        .select('*, profiles(full_name)')
        .single();
    return AdminAnnouncementModel.fromJson(response);
  }

  @override
  Future<bool> sendAnnouncementPush(String announcementId) async {
    try {
      await _client.from('admin_announcements').update({'send_push': true}).filter('id', 'eq', announcementId);
      return true;
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Dashboard ──

  @override
  Future<Map<String, int>> getDashboardCounts({String? universityId}) async {
    try {
      final totalUsers = await _client.from('profiles').select('id').limit(1) as List;
      final totalCommunities = await _client.from('communities').select('id').limit(1) as List;
      final pendingVerifications = await _client.from('verification_requests').select('id').filter('status', 'eq', 'pending').limit(1) as List;
      final pendingModeration = await _client.from('moderation_queue').select('id').filter('status', 'eq', 'pending').limit(1) as List;
      final pendingOpportunities = await _client.from('opportunities').select('id').filter('status', 'eq', 'pending').limit(1) as List;

      return {
        'total_users': totalUsers.length,
        'total_communities': totalCommunities.length,
        'pending_verifications': pendingVerifications.length,
        'pending_moderation': pendingModeration.length,
        'pending_opportunities': pendingOpportunities.length,
      };
    } catch (e) {
      debugPrint('[AdminRepositoryImpl] getDashboardCounts error: $e');
      return {};
    }
  }
}
