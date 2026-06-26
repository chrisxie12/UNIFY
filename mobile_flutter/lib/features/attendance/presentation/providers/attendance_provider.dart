import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unify/core/providers/supabase_provider.dart';
import '../../data/models/attendance_models.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../services/attendance_report_service.dart';

// ── Infrastructure providers ──────────────────────────────────────────────────

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(ref.watch(supabaseProvider));
});

final attendanceReportServiceProvider = Provider<AttendanceReportService>((ref) {
  return AttendanceReportService(
    ref.watch(attendanceRepositoryProvider),
    ref.watch(supabaseProvider),
  );
});

// ── Data providers ────────────────────────────────────────────────────────────

final activeSessionProvider =
    FutureProvider.family<AttendanceSessionModel?, String>((ref, courseId) async {
  return ref.watch(attendanceRepositoryProvider).getActiveSession(courseId);
});

final sessionHistoryProvider =
    FutureProvider.family<List<AttendanceSessionModel>, String>((ref, courseId) async {
  return ref.watch(attendanceRepositoryProvider).getSessionHistory(courseId);
});

final attendanceRecordsProvider =
    FutureProvider.family<List<AttendanceRecordModel>, String>((ref, sessionId) async {
  return ref.watch(attendanceRepositoryProvider).getRecords(sessionId);
});

final attendanceStatsProvider =
    FutureProvider.family<AttendanceStats, String>((ref, sessionId) async {
  final records = await ref.watch(attendanceRecordsProvider(sessionId).future);
  // We need the session to compute stats; build a minimal version from records
  // The full session is passed in by the caller when needed.
  // This provider is used for the history view where session is already known.
  final present = records.where((r) => r.status == AttendanceStatus.present).length;
  final late_   = records.where((r) => r.status == AttendanceStatus.lateArrival).length;
  final absent  = records.where((r) => r.status == AttendanceStatus.absent).length;
  final excused = records.where((r) => r.status == AttendanceStatus.excused).length;
  final total   = records.length;
  final pct     = total > 0 ? ((present + late_ + excused) / total * 100) : 0.0;
  return AttendanceStats(
    total: total,
    present: present,
    lateArrival: late_,
    absent: absent,
    excused: excused,
    attendancePercent: pct,
  );
});

final sessionReportProvider =
    FutureProvider.family<AttendanceReportModel?, String>((ref, sessionId) async {
  return ref.watch(attendanceRepositoryProvider).getReportForSession(sessionId);
});

final courseReportsProvider =
    FutureProvider.family<List<AttendanceReportModel>, String>((ref, courseId) async {
  return ref.watch(attendanceRepositoryProvider).getReports(courseId);
});

// ── Session notifier ──────────────────────────────────────────────────────────
//
// Handles create, finalize, and check-in actions with optimistic state.

class AttendanceSessionNotifier
    extends StateNotifier<AsyncValue<AttendanceSessionModel?>> {
  AttendanceSessionNotifier(this._repo, this._service, this._ref)
      : super(const AsyncValue.data(null));

  final AttendanceRepository _repo;
  final AttendanceReportService _service;
  final Ref _ref;

  Future<AttendanceSessionModel> startSession({
    required String courseId,
    required String courseCode,
    required String courseName,
    required String title,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    required String createdBy,
    String? building,
    String? room,
    String? university,
    String? lecturerId,
    String? lecturerName,
    int totalRegistered = 0,
  }) async {
    state = const AsyncValue.loading();
    final session = await _repo.createSession(
      courseId:        courseId,
      courseCode:      courseCode,
      courseName:      courseName,
      title:           title,
      scheduledStart:  scheduledStart,
      scheduledEnd:    scheduledEnd,
      createdBy:       createdBy,
      building:        building,
      room:            room,
      university:      university,
      lecturerId:      lecturerId,
      lecturerName:    lecturerName,
      totalRegistered: totalRegistered,
    );
    state = AsyncValue.data(session);
    _ref.invalidate(activeSessionProvider(courseId));
    return session;
  }

  Future<AttendanceRecordModel> checkIn({
    required String sessionId,
    required String studentId,
    required String studentName,
    String? studentNumber,
    String? email,
    double? distanceM,
    String? device,
  }) async {
    final isLate = state.valueOrNull?.isPastEndTime ?? false;
    return _repo.upsertRecord(
      sessionId:    sessionId,
      studentId:    studentId,
      studentName:  studentName,
      status:       isLate ? AttendanceStatus.lateArrival : AttendanceStatus.present,
      studentNumber: studentNumber,
      email:        email,
      checkInTime:  DateTime.now(),
      distanceM:    distanceM,
      device:       device,
    );
  }

  Future<AttendanceReportModel> finalizeSession({
    required AttendanceSessionModel session,
    required List<Map<String, dynamic>> enrolledStudents,
    required String finalizedBy,
  }) async {
    final report = await _service.finalizeSession(
      session:          session,
      enrolledStudents: enrolledStudents,
      finalizedBy:      finalizedBy,
    );
    state = const AsyncValue.data(null);
    _ref.invalidate(activeSessionProvider(session.courseId));
    _ref.invalidate(sessionHistoryProvider(session.courseId));
    _ref.invalidate(courseReportsProvider(session.courseId));
    return report;
  }
}

final attendanceSessionNotifierProvider = StateNotifierProvider<
    AttendanceSessionNotifier, AsyncValue<AttendanceSessionModel?>>((ref) {
  return AttendanceSessionNotifier(
    ref.watch(attendanceRepositoryProvider),
    ref.watch(attendanceReportServiceProvider),
    ref,
  );
});
