import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

enum AttendanceStatus {
  present,
  lateArrival,
  absent,
  excused;

  String get dbValue {
    if (this == AttendanceStatus.lateArrival) return 'late';
    return name;
  }

  String get label {
    switch (this) {
      case AttendanceStatus.present:      return 'Present';
      case AttendanceStatus.lateArrival:  return 'Late';
      case AttendanceStatus.absent:       return 'Absent';
      case AttendanceStatus.excused:      return 'Excused';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.present:      return const Color(0xFF10B981);
      case AttendanceStatus.lateArrival:  return const Color(0xFFF59E0B);
      case AttendanceStatus.absent:       return const Color(0xFFEF4444);
      case AttendanceStatus.excused:      return const Color(0xFF3B82F6);
    }
  }

  Color get bgColor {
    switch (this) {
      case AttendanceStatus.present:      return const Color(0xFFD1FAE5);
      case AttendanceStatus.lateArrival:  return const Color(0xFFFEF3C7);
      case AttendanceStatus.absent:       return const Color(0xFFFEE2E2);
      case AttendanceStatus.excused:      return const Color(0xFFDBEAFE);
    }
  }

  // ARGB hex strings for Excel cell colouring
  String get excelArgb {
    switch (this) {
      case AttendanceStatus.present:      return 'FFD1FAE5';
      case AttendanceStatus.lateArrival:  return 'FFFEF3C7';
      case AttendanceStatus.absent:       return 'FFFEE2E2';
      case AttendanceStatus.excused:      return 'FFDBEAFE';
    }
  }

  static AttendanceStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case 'late':    return AttendanceStatus.lateArrival;
      case 'absent':  return AttendanceStatus.absent;
      case 'excused': return AttendanceStatus.excused;
      default:        return AttendanceStatus.present;
    }
  }
}

enum SessionStatus {
  active,
  closed,
  cancelled;

  static SessionStatus fromString(String s) {
    switch (s) {
      case 'closed':    return SessionStatus.closed;
      case 'cancelled': return SessionStatus.cancelled;
      default:          return SessionStatus.active;
    }
  }
}

// ── Attendance Session ────────────────────────────────────────────────────────

class AttendanceSessionModel {
  final String id;
  final String courseId;
  final String courseCode;
  final String courseName;
  final String title;
  final String? building;
  final String? room;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final SessionStatus status;
  final String createdBy;
  final String? university;
  final int totalRegistered;
  final String? lecturerId;
  final String? lecturerName;
  final DateTime createdAt;

  const AttendanceSessionModel({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.title,
    this.building,
    this.room,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    required this.status,
    required this.createdBy,
    this.university,
    this.totalRegistered = 0,
    this.lecturerId,
    this.lecturerName,
    required this.createdAt,
  });

  bool get isActive   => status == SessionStatus.active;
  bool get isClosed   => status == SessionStatus.closed;
  Duration get duration => scheduledEnd.difference(scheduledStart);
  bool get isPastEndTime => DateTime.now().isAfter(scheduledEnd);

  String get reportFilename =>
      '${courseCode}_${scheduledStart.toIso8601String().substring(0, 10)}_Attendance.xlsx';

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSessionModel(
      id:               json['id'] as String,
      courseId:         json['course_id'] as String,
      courseCode:       json['course_code'] as String,
      courseName:       json['course_name'] as String,
      title:            json['title'] as String,
      building:         json['building'] as String?,
      room:             json['room'] as String?,
      scheduledStart:   DateTime.parse(json['scheduled_start'] as String),
      scheduledEnd:     DateTime.parse(json['scheduled_end'] as String),
      actualStart:      json['actual_start'] != null ? DateTime.parse(json['actual_start'] as String) : null,
      actualEnd:        json['actual_end'] != null ? DateTime.parse(json['actual_end'] as String) : null,
      status:           SessionStatus.fromString(json['status'] as String? ?? 'active'),
      createdBy:        json['created_by'] as String,
      university:       json['university'] as String?,
      totalRegistered:  json['total_registered'] as int? ?? 0,
      lecturerId:       json['lecturer_id'] as String?,
      lecturerName:     json['lecturer_name'] as String?,
      createdAt:        DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'course_id':       courseId,
    'course_code':     courseCode,
    'course_name':     courseName,
    'title':           title,
    'building':        building,
    'room':            room,
    'scheduled_start': scheduledStart.toIso8601String(),
    'scheduled_end':   scheduledEnd.toIso8601String(),
    'status':          status.name,
    'created_by':      createdBy,
    'university':      university,
    'total_registered': totalRegistered,
    'lecturer_id':     lecturerId,
    'lecturer_name':   lecturerName,
  };
}

// ── Attendance Record (per student) ──────────────────────────────────────────

class AttendanceRecordModel {
  final String id;
  final String sessionId;
  final String studentId;
  final String studentName;
  final String? studentNumber;
  final String? email;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final double? distanceM;
  final String? device;
  final String? notes;
  final DateTime createdAt;

  const AttendanceRecordModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    this.studentNumber,
    this.email,
    required this.status,
    this.checkInTime,
    this.distanceM,
    this.device,
    this.notes,
    required this.createdAt,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id:            json['id'] as String,
      sessionId:     json['session_id'] as String,
      studentId:     json['student_id'] as String,
      studentName:   json['student_name'] as String? ?? 'Unknown',
      studentNumber: json['student_number'] as String?,
      email:         json['email'] as String?,
      status:        AttendanceStatus.fromString(json['status'] as String? ?? 'absent'),
      checkInTime:   json['check_in_time'] != null ? DateTime.parse(json['check_in_time'] as String) : null,
      distanceM:     (json['distance_m'] as num?)?.toDouble(),
      device:        json['device'] as String?,
      notes:         json['notes'] as String?,
      createdAt:     DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
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
}

// ── Computed statistics ───────────────────────────────────────────────────────

class AttendanceStats {
  final int total;
  final int present;
  final int lateArrival;
  final int absent;
  final int excused;
  final double attendancePercent;
  final Duration? sessionDuration;
  final DateTime? averageCheckIn;
  final double? averageDistanceM;

  const AttendanceStats({
    required this.total,
    required this.present,
    required this.lateArrival,
    required this.absent,
    required this.excused,
    required this.attendancePercent,
    this.sessionDuration,
    this.averageCheckIn,
    this.averageDistanceM,
  });

  int get attended => present + lateArrival;

  static AttendanceStats compute(
    AttendanceSessionModel session,
    List<AttendanceRecordModel> records,
  ) {
    final total    = session.totalRegistered > 0 ? session.totalRegistered : records.length;
    final present  = records.where((r) => r.status == AttendanceStatus.present).length;
    final lateArr  = records.where((r) => r.status == AttendanceStatus.lateArrival).length;
    final absent   = records.where((r) => r.status == AttendanceStatus.absent).length;
    final excused  = records.where((r) => r.status == AttendanceStatus.excused).length;

    final attended = present + lateArr + excused;
    final pct      = total > 0 ? (attended / total) * 100 : 0.0;

    final checkIns = records
        .where((r) => r.checkInTime != null)
        .map((r) => r.checkInTime!.millisecondsSinceEpoch)
        .toList();
    DateTime? avgCheckIn;
    if (checkIns.isNotEmpty) {
      final avg = checkIns.reduce((a, b) => a + b) ~/ checkIns.length;
      avgCheckIn = DateTime.fromMillisecondsSinceEpoch(avg);
    }

    final distances = records
        .where((r) => r.distanceM != null)
        .map((r) => r.distanceM!)
        .toList();
    double? avgDist;
    if (distances.isNotEmpty) {
      avgDist = distances.reduce((a, b) => a + b) / distances.length;
    }

    return AttendanceStats(
      total:             total,
      present:           present,
      lateArrival:       lateArr,
      absent:            absent,
      excused:           excused,
      attendancePercent: pct,
      sessionDuration:   session.scheduledEnd.difference(session.scheduledStart),
      averageCheckIn:    avgCheckIn,
      averageDistanceM:  avgDist,
    );
  }
}

// ── Report metadata ───────────────────────────────────────────────────────────

class AttendanceReportModel {
  final String id;
  final String sessionId;
  final String courseId;
  final String generatedBy;
  final String storagePath;
  final String downloadUrl;
  final int fileSize;
  final DateTime generatedAt;

  const AttendanceReportModel({
    required this.id,
    required this.sessionId,
    required this.courseId,
    required this.generatedBy,
    required this.storagePath,
    required this.downloadUrl,
    required this.fileSize,
    required this.generatedAt,
  });

  factory AttendanceReportModel.fromJson(Map<String, dynamic> json) {
    return AttendanceReportModel(
      id:           json['id'] as String,
      sessionId:    json['session_id'] as String,
      courseId:     json['course_id'] as String,
      generatedBy:  json['generated_by'] as String,
      storagePath:  json['storage_path'] as String,
      downloadUrl:  json['download_url'] as String,
      fileSize:     json['file_size'] as int? ?? 0,
      generatedAt:  DateTime.parse(json['generated_at'] as String),
    );
  }
}
