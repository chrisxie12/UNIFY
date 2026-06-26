import '../../data/models/attendance_models.dart';

abstract class AttendanceRepository {
  // ── Sessions ─────────────────────────────────────────────────────────────
  Future<AttendanceSessionModel> createSession({
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
  });

  Future<AttendanceSessionModel?> getActiveSession(String courseId);

  Future<List<AttendanceSessionModel>> getSessionHistory(
    String courseId, {
    int limit = 20,
  });

  Future<AttendanceSessionModel> updateSessionStatus(
    String sessionId,
    SessionStatus status, {
    DateTime? actualEnd,
  });

  // ── Records ───────────────────────────────────────────────────────────────
  Future<AttendanceRecordModel> upsertRecord({
    required String sessionId,
    required String studentId,
    required String studentName,
    required AttendanceStatus status,
    String? studentNumber,
    String? email,
    DateTime? checkInTime,
    double? distanceM,
    String? device,
    String? notes,
  });

  Future<List<AttendanceRecordModel>> getRecords(String sessionId);

  Future<void> markAbsentStudents(
    String sessionId,
    List<Map<String, dynamic>> allStudents,
  );

  // ── Reports ───────────────────────────────────────────────────────────────
  Future<AttendanceReportModel> saveReport({
    required String sessionId,
    required String courseId,
    required String generatedBy,
    required String storagePath,
    required String downloadUrl,
    required int fileSize,
  });

  Future<List<AttendanceReportModel>> getReports(String courseId, {int limit = 20});

  Future<AttendanceReportModel?> getReportForSession(String sessionId);

  Future<String> getSignedDownloadUrl(String storagePath, {int expiresInSeconds = 3600});
}
