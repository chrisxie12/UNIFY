import '../../data/models/university_model.dart';
import '../../data/models/faculty_model.dart';
import '../../data/models/department_model.dart';
import '../../data/models/admin_role_model.dart';
import '../../data/models/administrator_model.dart';
import '../../data/models/audit_log_model.dart';
import '../../data/models/moderation_item_model.dart';
import '../../data/models/admin_announcement_model.dart';
import '../../data/models/opportunity_model.dart';
import '../../data/models/marketplace_report_model.dart';
import '../../data/models/analytics_snapshot_model.dart';

abstract class AdminRepository {
  // ── Universities ──
  Future<List<UniversityModel>> getUniversities();
  Future<UniversityModel> getUniversity(String id);
  Future<UniversityModel> createUniversity(Map<String, dynamic> data);
  Future<bool> updateUniversity(String id, Map<String, dynamic> updates);
  Future<bool> deleteUniversity(String id);

  // ── Faculties ──
  Future<List<FacultyModel>> getFaculties(String universityId);
  Future<FacultyModel> getFaculty(String id);
  Future<FacultyModel> createFaculty(Map<String, dynamic> data);
  Future<bool> updateFaculty(String id, Map<String, dynamic> updates);
  Future<bool> deleteFaculty(String id);

  // ── Departments ──
  Future<List<DepartmentModel>> getDepartments(String facultyId);
  Future<DepartmentModel> getDepartment(String id);
  Future<DepartmentModel> createDepartment(Map<String, dynamic> data);
  Future<bool> updateDepartment(String id, Map<String, dynamic> updates);
  Future<bool> deleteDepartment(String id);

  // ── Admin Roles ──
  Future<List<AdminRoleModel>> getAdminRoles();
  Future<List<AdministratorModel>> getAdministrators({String? universityId, String? facultyId, String? departmentId});
  Future<AdministratorModel> assignAdminRole(Map<String, dynamic> data);
  Future<bool> updateAdminStatus(String id, bool isActive);
  Future<bool> removeAdmin(String id);
  Future<String?> getUserAdminRole(String userId);

  // ── Verification ──
  Future<List<Map<String, dynamic>>> getVerificationRequests({String? status});
  Future<bool> approveVerification(String requestId, String reviewedBy, {String? roleId, String? notes});
  Future<bool> rejectVerification(String requestId, String reviewedBy, {String? notes});
  Future<bool> assignBadge(String userId, String badgeId);
  Future<bool> revokeBadge(String userId, String badgeId);

  // ── Moderation ──
  Future<List<ModerationItemModel>> getModerationQueue({String? status, String? reportType});
  Future<bool> updateModerationStatus(String id, String status, String reviewedBy, {String? resolution});

  // ── Marketplace ──
  Future<List<MarketplaceReportModel>> getMarketplaceReports({String? status});
  Future<bool> resolveMarketplaceReport(String id, String action, String reviewedBy);

  // ── Opportunities ──
  Future<List<OpportunityModel>> getOpportunities({String? status, String? type});
  Future<bool> updateOpportunityStatus(String id, String status, String reviewedBy);

  // ── Analytics ──
  Future<AnalyticsSnapshotModel> getLatestAnalytics(String? universityId);
  Future<List<AnalyticsSnapshotModel>> getAnalyticsHistory(String? universityId, {int days = 30});

  // ── Audit Logs ──
  Future<List<AuditLogModel>> getAuditLogs({
    String? universityId,
    String? actionFilter,
    String? entityType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  });
  Future<void> logAction(String actorId, String action, String entityType, String? entityId, {String? universityId, Map<String, dynamic>? details});

  // ── Announcements ──
  Future<List<AdminAnnouncementModel>> getAnnouncements({String? scopeType, String? scopeId});
  Future<AdminAnnouncementModel> createAnnouncement(Map<String, dynamic> data);
  Future<bool> sendAnnouncementPush(String announcementId);

  // ── Dashboard ──
  Future<Map<String, int>> getDashboardCounts({String? universityId});
}
