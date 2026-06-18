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
    return UniversityModel.fromJson(response);
  }

  @override
  Future<bool> updateUniversity(String id, Map<String, dynamic> updates) async {
    try {
      await _client.from('universities').update(updates).filter('id', 'eq', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteUniversity(String id) async {
    try {
      await _client.from('universities').delete().filter('id', 'eq', id);
      return true;
    } catch (_) {
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
    return FacultyModel.fromJson(response);
  }

  @override
  Future<bool> updateFaculty(String id, Map<String, dynamic> updates) async {
    try {
      await _client.from('faculties').update(updates).filter('id', 'eq', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteFaculty(String id) async {
    try {
      await _client.from('faculties').delete().filter('id', 'eq', id);
      return true;
    } catch (_) {
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
    return DepartmentModel.fromJson(response);
  }

  @override
  Future<bool> updateDepartment(String id, Map<String, dynamic> updates) async {
    try {
      await _client.from('departments').update(updates).filter('id', 'eq', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteDepartment(String id) async {
    try {
      await _client.from('departments').delete().filter('id', 'eq', id);
      return true;
    } catch (_) {
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
    return AdministratorModel.fromJson(response);
  }

  @override
  Future<bool> updateAdminStatus(String id, bool isActive) async {
    try {
      await _client.from('university_administrators').update({'is_active': isActive}).filter('id', 'eq', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> removeAdmin(String id) async {
    try {
      await _client.from('university_administrators').delete().filter('id', 'eq', id);
      return true;
    } catch (_) {
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
      final request = await _client.from('verification_requests').select('user_id').filter('id', 'eq', requestId).single();
      await _client.from('profiles').update({'is_verified': true}).filter('id', 'eq', request['user_id']);
      return true;
    } catch (_) {
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
      return true;
    } catch (_) {
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
    } catch (_) {
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
    } catch (_) {
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
      return true;
    } catch (_) {
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
      await _client.from('marketplace_reports').update({
        'status': 'resolved',
        'action_taken': action,
        'reviewed_by': reviewedBy,
      }).filter('id', 'eq', id);
      return true;
    } catch (_) {
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
    } catch (_) {
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
  Future<List<AuditLogModel>> getAuditLogs({String? universityId, int limit = 50}) async {
    dynamic query = _client
        .from('audit_logs')
        .select('*, profiles(full_name)')
        .order('created_at', ascending: false)
        .limit(limit);
    if (universityId != null) query = query.filter('university_id', 'eq', universityId);
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
    } catch (_) {
      try {
        await _client.from('audit_logs').insert({
          'actor_id': actorId,
          'action': action,
          'entity_type': entityType,
          'entity_id': entityId,
          'university_id': universityId,
          'details': details ?? {},
        });
      } catch (_) {}
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
    } catch (_) {
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
    } catch (_) {
      return {};
    }
  }
}
