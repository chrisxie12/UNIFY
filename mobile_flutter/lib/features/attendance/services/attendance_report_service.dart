import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/attendance_models.dart';
import '../domain/repositories/attendance_repository.dart';

/// Handles the full end-of-session workflow:
///   1. Lock session (status → closed)
///   2. Mark absent students
///   3. Calculate statistics
///   4. Generate .xlsx
///   5. Upload to Supabase Storage
///   6. Persist report metadata
///   7. Send in-app notifications
class AttendanceReportService {
  final AttendanceRepository _repo;
  final SupabaseClient _client;

  AttendanceReportService(this._repo, this._client);

  // ── Main entry-point ──────────────────────────────────────────────────────

  Future<AttendanceReportModel> finalizeSession({
    required AttendanceSessionModel session,
    required List<Map<String, dynamic>> enrolledStudents,
    required String finalizedBy,
  }) async {
    // 1. Lock session
    await _repo.updateSessionStatus(
      session.id,
      SessionStatus.closed,
      actualEnd: DateTime.now(),
    );

    // 2. Mark absent students who never checked in
    await _repo.markAbsentStudents(session.id, enrolledStudents);

    // 3. Fetch final records
    final records = await _repo.getRecords(session.id);

    // 4. Compute stats
    final stats = AttendanceStats.compute(session, records);

    // 5. Generate Excel bytes
    final bytes = _buildExcel(session, records, stats);

    // 6. Upload to Supabase Storage
    final storagePath =
        '${session.courseId}/${session.id}/attendance.xlsx';
    await _client.storage.from('attendance-reports').uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            contentType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            upsert: true,
          ),
        );

    // 7. Get public/signed URL
    final downloadUrl = await _client.storage
        .from('attendance-reports')
        .createSignedUrl(storagePath, 60 * 60 * 24 * 7); // 7 days

    // 8. Persist report metadata
    final report = await _repo.saveReport(
      sessionId:   session.id,
      courseId:    session.courseId,
      generatedBy: finalizedBy,
      storagePath: storagePath,
      downloadUrl: downloadUrl,
      fileSize:    bytes.length,
    );

    // 9. Notify class rep + lecturer
    await _notify(
      session:  session,
      report:   report,
      notifyId: finalizedBy,
    );
    if (session.lecturerId != null && session.lecturerId != finalizedBy) {
      await _notify(
        session:  session,
        report:   report,
        notifyId: session.lecturerId!,
      );
    }

    return report;
  }

  // ── Notification helper ───────────────────────────────────────────────────

  Future<void> _notify({
    required AttendanceSessionModel session,
    required AttendanceReportModel report,
    required String notifyId,
  }) async {
    try {
      await _client.rpc('create_notification', params: {
        'p_user_id':       notifyId,
        'p_type':          'attendance_report_ready',
        'p_title':         'Attendance report ready',
        'p_body':          'The report for ${session.courseName} – ${session.title} has been generated.',
        'p_reference_id':  report.sessionId,
        'p_reference_type': 'attendance_session',
        'p_data': {
          'session_id':   report.sessionId,
          'course_id':    report.courseId,
          'course_name':  session.courseName,
          'course_code':  session.courseCode,
          'download_url': report.downloadUrl,
          'storage_path': report.storagePath,
        },
      });
    } catch (_) {
      // Notification failure must not block the finalization result
    }
  }

  // ── Excel builder ─────────────────────────────────────────────────────────

  Uint8List _buildExcel(
    AttendanceSessionModel session,
    List<AttendanceRecordModel> records,
    AttendanceStats stats,
  ) {
    final excel = Excel.createExcel();
    // Remove the auto-created default sheet
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final sheet = excel['Attendance'];
    _buildAttendanceSheet(sheet, session, records, stats);

    return Uint8List.fromList(excel.encode()!);
  }

  void _buildAttendanceSheet(
    Sheet sheet,
    AttendanceSessionModel session,
    List<AttendanceRecordModel> records,
    AttendanceStats stats,
  ) {
    final fmt       = DateFormat('MMM d, yyyy');
    final timeFmt   = DateFormat('HH:mm');
    final stampFmt  = DateFormat('MMM d, yyyy HH:mm:ss');

    // ── Column widths ────────────────────────────────────────
    sheet.setColumnWidth(0, 6);   // No.
    sheet.setColumnWidth(1, 24);  // Student Name
    sheet.setColumnWidth(2, 18);  // Student ID
    sheet.setColumnWidth(3, 28);  // Email
    sheet.setColumnWidth(4, 16);  // Check-in Time
    sheet.setColumnWidth(5, 12);  // Status
    sheet.setColumnWidth(6, 14);  // Distance (m)
    sheet.setColumnWidth(7, 16);  // Device
    sheet.setColumnWidth(8, 20);  // Notes

    int row = 0;

    // ── Report title ─────────────────────────────────────────
    _mergedText(sheet, row, 0, 8, 'UNIFY — Attendance Report',
        bold: true, fontSize: 16,
        bgArgb: 'FF2563EB', fgArgb: 'FFFFFFFF',
        height: 28);
    row++;

    // ── University / course info ──────────────────────────────
    final infoRows = [
      ['University', session.university ?? ''],
      ['Course',     '${session.courseCode} – ${session.courseName}'],
      ['Session',    session.title],
      ['Building',   session.building ?? '—'],
      ['Room',       session.room ?? '—'],
      ['Date',       fmt.format(session.scheduledStart)],
      ['Start',      timeFmt.format(session.scheduledStart)],
      ['End',        timeFmt.format(session.scheduledEnd)],
      ['Generated',  stampFmt.format(DateTime.now())],
    ];

    for (final kv in infoRows) {
      _cell(sheet, row, 0, kv[0],
          bold: true, bgArgb: 'FFF3F4F6', height: 18);
      _mergedText(sheet, row, 1, 8, kv[1], height: 18);
      row++;
    }
    row++; // blank spacer

    // ── Table header ─────────────────────────────────────────
    const headers = [
      'No.', 'Student Name', 'Student ID', 'Email',
      'Check-in Time', 'Status', 'Distance (m)', 'Device', 'Notes',
    ];
    for (var c = 0; c < headers.length; c++) {
      _cell(sheet, row, c, headers[c],
          bold: true, bgArgb: 'FF374151', fgArgb: 'FFFFFFFF', height: 22);
    }
    row++;

    // ── Data rows ─────────────────────────────────────────────
    for (var i = 0; i < records.length; i++) {
      final rec   = records[i];
      final bgArg = rec.status.excelArgb;
      final vals  = [
        '${i + 1}',
        rec.studentName,
        rec.studentNumber ?? '',
        rec.email ?? '',
        rec.checkInTime != null ? timeFmt.format(rec.checkInTime!) : '—',
        rec.status.label,
        rec.distanceM != null ? rec.distanceM!.toStringAsFixed(1) : '—',
        rec.device ?? '—',
        rec.notes ?? '',
      ];
      for (var c = 0; c < vals.length; c++) {
        _cell(sheet, row, c, vals[c], bgArgb: bgArg, height: 18);
      }
      row++;
    }
    row++; // spacer

    // ── Summary ───────────────────────────────────────────────
    _mergedText(sheet, row, 0, 8, 'SUMMARY',
        bold: true, bgArgb: 'FF374151', fgArgb: 'FFFFFFFF', height: 22);
    row++;

    String _dur(Duration d) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return h > 0 ? '${h}h ${m}m' : '${m}m';
    }

    final summaryRows = [
      ['Total Registered',      '${stats.total}'],
      ['Present',               '${stats.present}'],
      ['Late',                  '${stats.lateArrival}'],
      ['Absent',                '${stats.absent}'],
      ['Excused',               '${stats.excused}'],
      ['Attendance %',          '${stats.attendancePercent.toStringAsFixed(1)}%'],
      ['Session Duration',      stats.sessionDuration != null ? _dur(stats.sessionDuration!) : '—'],
      ['Avg Check-in Time',     stats.averageCheckIn != null ? timeFmt.format(stats.averageCheckIn!) : '—'],
      ['Avg Distance (m)',      stats.averageDistanceM != null ? stats.averageDistanceM!.toStringAsFixed(1) : '—'],
    ];

    final summaryColors = {
      'Present':   'FFD1FAE5',
      'Late':      'FFFEF3C7',
      'Absent':    'FFFEE2E2',
      'Excused':   'FFDBEAFE',
      'Attendance %': 'FFE0E7FF',
    };

    for (final kv in summaryRows) {
      final bg = summaryColors[kv[0]] ?? 'FFF9FAFB';
      _cell(sheet, row, 0, kv[0], bold: true, bgArgb: 'FFF3F4F6', height: 18);
      _mergedText(sheet, row, 1, 3, kv[1], bgArgb: bg, bold: kv[0] == 'Attendance %', height: 18);
      row++;
    }
  }

  // ── Cell helpers ──────────────────────────────────────────────────────────

  void _cell(
    Sheet sheet,
    int row,
    int col,
    String value, {
    bool bold = false,
    String bgArgb = 'FFFFFFFF',
    String fgArgb = 'FF000000',
    double fontSize = 10,
    double height = 16,
  }) {
    sheet.setRowHeight(row, height);
    final c = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    c.value = TextCellValue(value);
    c.cellStyle = CellStyle(
      bold:                 bold,
      fontSize:             fontSize.toInt(),
      backgroundColorHex:   ExcelColor.fromHexString(bgArgb),
      fontColorHex:         ExcelColor.fromHexString(fgArgb),
      horizontalAlign:      col == 0 ? HorizontalAlign.Center : HorizontalAlign.Left,
      verticalAlign:        VerticalAlign.Center,
      leftBorder:  Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder:   Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );
  }

  void _mergedText(
    Sheet sheet,
    int row,
    int fromCol,
    int toCol,
    String value, {
    bool bold = false,
    String bgArgb = 'FFFFFFFF',
    String fgArgb = 'FF111827',
    double fontSize = 10,
    double height = 16,
  }) {
    sheet.setRowHeight(row, height);
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: fromCol, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: toCol,   rowIndex: row),
      customValue: TextCellValue(value),
    );
    final c = sheet.cell(CellIndex.indexByColumnRow(columnIndex: fromCol, rowIndex: row));
    c.cellStyle = CellStyle(
      bold:               bold,
      fontSize:           fontSize.toInt(),
      backgroundColorHex: ExcelColor.fromHexString(bgArgb),
      fontColorHex:       ExcelColor.fromHexString(fgArgb),
      horizontalAlign:    HorizontalAlign.Left,
      verticalAlign:      VerticalAlign.Center,
      leftBorder:  Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder:   Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );
  }
}
