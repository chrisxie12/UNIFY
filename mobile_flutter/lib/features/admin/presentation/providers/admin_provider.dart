import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/admin_repository_impl.dart';
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
import '../../domain/repositories/admin_repository.dart';
import '../../../../core/providers/supabase_provider.dart';

// ── Repository ──

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(ref.watch(supabaseProvider));
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(supabaseProvider).auth.currentUser?.id;
});

// ── Universities ──

final universitiesProvider = FutureProvider<List<UniversityModel>>((ref) async {
  return ref.watch(adminRepositoryProvider).getUniversities();
});

final universityProvider = FutureProvider.family<UniversityModel, String>((ref, id) async {
  return ref.watch(adminRepositoryProvider).getUniversity(id);
});

// ── Faculties ──

final facultiesProvider = FutureProvider.family<List<FacultyModel>, String>((ref, universityId) async {
  return ref.watch(adminRepositoryProvider).getFaculties(universityId);
});

// ── Departments ──

final departmentsProvider = FutureProvider.family<List<DepartmentModel>, String>((ref, facultyId) async {
  return ref.watch(adminRepositoryProvider).getDepartments(facultyId);
});

// ── Administrators ──

final administratorsProvider = FutureProvider<List<AdministratorModel>>((ref) async {
  return ref.watch(adminRepositoryProvider).getAdministrators();
});

final adminRolesProvider = FutureProvider<List<AdminRoleModel>>((ref) async {
  return ref.watch(adminRepositoryProvider).getAdminRoles();
});

final universityAdminsProvider = FutureProvider.family<List<AdministratorModel>, String>((ref, universityId) async {
  return ref.watch(adminRepositoryProvider).getAdministrators(universityId: universityId);
});

// ── Moderation ──

final moderationQueueProvider = FutureProvider<List<ModerationItemModel>>((ref) async {
  return ref.watch(adminRepositoryProvider).getModerationQueue();
});

final pendingModerationProvider = FutureProvider<List<ModerationItemModel>>((ref) async {
  return ref.watch(adminRepositoryProvider).getModerationQueue(status: 'pending');
});

// ── Marketplace Reports ──

final marketplaceReportsProvider = FutureProvider<List<MarketplaceReportModel>>((ref) async {
  return ref.watch(adminRepositoryProvider).getMarketplaceReports();
});

final pendingMarketplaceReportsProvider = FutureProvider<List<MarketplaceReportModel>>((ref) async {
  return ref.watch(adminRepositoryProvider).getMarketplaceReports(status: 'pending');
});

// ── Opportunities ──

final opportunitiesProvider = FutureProvider<List<OpportunityModel>>((ref) async {
  return ref.watch(adminRepositoryProvider).getOpportunities();
});

final pendingOpportunitiesProvider = FutureProvider<List<OpportunityModel>>((ref) async {
  return ref.watch(adminRepositoryProvider).getOpportunities(status: 'pending');
});

// ── Audit Logs ──

final auditLogsProvider = FutureProvider<List<AuditLogModel>>((ref) async {
  return ref.watch(adminRepositoryProvider).getAuditLogs();
});

// ── Announcements ──

final adminAnnouncementsProvider = FutureProvider<List<AdminAnnouncementModel>>((ref) async {
  return ref.watch(adminRepositoryProvider).getAnnouncements();
});

// ── Analytics ──

final latestAnalyticsProvider = FutureProvider<AnalyticsSnapshotModel>((ref) async {
  return ref.watch(adminRepositoryProvider).getLatestAnalytics(null);
});

final dashboardCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  return ref.watch(adminRepositoryProvider).getDashboardCounts();
});

// ── Admin Role ──

final currentUserAdminRoleProvider = FutureProvider<String?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ref.watch(adminRepositoryProvider).getUserAdminRole(userId);
});

// ── Verification Requests ──

final adminVerificationRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(adminRepositoryProvider).getVerificationRequests();
});

final pendingVerificationRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(adminRepositoryProvider).getVerificationRequests(status: 'pending');
});
