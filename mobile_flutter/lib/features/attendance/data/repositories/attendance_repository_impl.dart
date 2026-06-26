import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unify/core/constants/supabase_tables.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_models.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final SupabaseClient _client;
  AttendanceRepositoryImpl(this._client);

  // ── Sessions ─────────────────────────────────────────────────────────────

  @override
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
  }) async {
    final data = {
      'course_id':        courseId,
      'course_code':      courseCode,
      'course_name':      courseName,
      'title':            title,
      'scheduled_start':  scheduledStart.toIso8601String(),
      'scheduled_end':    scheduledEnd.toIso8601String(),
      'actual_start':     DateTime.now().toIso8601String(),
      'status':           'active',
      'created_by':       createdBy,
      'building':         building,
      'room':             room,
      'university':       university,
      'lecturer_id':      lecturerId,
      'lecturer_name':    lecturerName,
      'total_registered': totalRegistered,
    };
    final response = await _client
        .from(SupabaseTables.attendanceSessions)
        .insert(data)
        .select()
        .single();
    return AttendanceSessionModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<AttendanceSessionModel?> getActiveSession(String courseId) async {
    final response = await _client
        .from(SupabaseTables.attendanceSessions)
        .select()
        .eq('course_id', courseId)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(1) as List;
    if (response.isEmpty) return null;
    return AttendanceSessionModel.fromJson(response.first as Map<String, dynamic>);
  }

  @override
  Future<List<AttendanceSessionModel>> getSessionHistory(
    String courseId, {
    int limit = 20,
  }) async {
    final response = await _client
        .from(SupabaseTables.attendanceSessions)
        .select()
        .eq('course_id', courseId)
        .order('scheduled_start', ascending: false)
        .limit(limit) as List;
    return response
        .map((j) => AttendanceSessionModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AttendanceSessionModel> updateSessionStatus(
    String sessionId,
    SessionStatus status, {
    DateTime? actualEnd,
  }) async {
    final updates = <String, dynamic>{'status': status.name};
    if (actualEnd != null) updates['actual_end'] = actualEnd.toIso8601String();

    final response = await _client
        .from(SupabaseTables.attendanceSessions)
        .update(updates)
        .eq('id', sessionId)
        .select()
        .single();
    return AttendanceSessionModel.fromJson(response as Map<String, dynamic>);
  }

  // ── Records ───────────────────────────────────────────────────────────────

  @override
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
  }) async {
    final data = {
      'session_id':    sessionId,
      'student_id':    studentId,
      'student_name':  studentName,
      'student_number': studentNumber,
      'email':         email,
      'status':        status.dbValue,
      'check_in_time': checkInTime?.toIso8601String(),
      'distance_m':    distanceM,
      'device':        device,
      'notes':         notes,
    };
    final response = await _client
        .from(SupabaseTables.attendanceRecords)
        .upsert(data, onConflict: 'session_id,student_id')
        .select()
        .single();
    return AttendanceRecordModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<AttendanceRecordModel>> getRecords(String sessionId) async {
    final response = await _client
        .from(SupabaseTables.attendanceRecords)
        .select()
        .eq('session_id', sessionId)
        .order('student_name') as List;
    return response
        .map((j) => AttendanceRecordModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAbsentStudents(
    String sessionId,
    List<Map<String, dynamic>> allStudents,
  ) async {
    if (allStudents.isEmpty) return;

    // Get already-recorded student IDs
    final existing = await _client
        .from(SupabaseTables.attendanceRecords)
        .select('student_id')
        .eq('session_id', sessionId) as List;
    final recordedIds = existing
        .map((r) => (r as Map<String, dynamic>)['student_id'] as String)
        .toSet();

    final absentRows = allStudents
        .where((s) => !recordedIds.contains(s['id'] as String))
        .map((s) => {
              'session_id':    sessionId,
              'student_id':    s['id'] as String,
              'student_name':  s['full_name'] as String? ?? 'Unknown',
              'student_number': s['student_id'] as String?,
              'email':         s['email'] as String?,
              'status':        'absent',
            })
        .toList();

    if (absentRows.isNotEmpty) {
      await _client
          .from(SupabaseTables.attendanceRecords)
          .insert(absentRows);
    }
  }

  // ── Reports ───────────────────────────────────────────────────────────────

  @override
  Future<AttendanceReportModel> saveReport({
    required String sessionId,
    required String courseId,
    required String generatedBy,
    required String storagePath,
    required String downloadUrl,
    required int fileSize,
  }) async {
    final response = await _client
        .from(SupabaseTables.attendanceReports)
        .insert({
          'session_id':   sessionId,
          'course_id':    courseId,
          'generated_by': generatedBy,
          'storage_path': storagePath,
          'download_url': downloadUrl,
          'file_size':    fileSize,
          'generated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
    return AttendanceReportModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<AttendanceReportModel>> getReports(String courseId, {int limit = 20}) async {
    final response = await _client
        .from(SupabaseTables.attendanceReports)
        .select()
        .eq('course_id', courseId)
        .order('generated_at', ascending: false)
        .limit(limit) as List;
    return response
        .map((j) => AttendanceReportModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AttendanceReportModel?> getReportForSession(String sessionId) async {
    final response = await _client
        .from(SupabaseTables.attendanceReports)
        .select()
        .eq('session_id', sessionId)
        .order('generated_at', ascending: false)
        .limit(1) as List;
    if (response.isEmpty) return null;
    return AttendanceReportModel.fromJson(response.first as Map<String, dynamic>);
  }

  @override
  Future<String> getSignedDownloadUrl(
    String storagePath, {
    int expiresInSeconds = 3600,
  }) async {
    final response = await _client.storage
        .from('attendance-reports')
        .createSignedUrl(storagePath, expiresInSeconds);
    return response;
  }
}
