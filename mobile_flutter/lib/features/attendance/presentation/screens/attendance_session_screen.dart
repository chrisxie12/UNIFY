import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../data/models/attendance_models.dart';
import '../providers/attendance_provider.dart';

class AttendanceSessionScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const AttendanceSessionScreen({super.key, required this.sessionId});

  @override
  ConsumerState<AttendanceSessionScreen> createState() =>
      _AttendanceSessionScreenState();
}

class _AttendanceSessionScreenState
    extends ConsumerState<AttendanceSessionScreen> {
  Timer? _refreshTimer;
  Timer? _autoCloseTimer;
  bool _finalizing = false;

  @override
  void initState() {
    super.initState();
    // Refresh records every 10 seconds for live check-in updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      ref.invalidate(attendanceRecordsProvider(widget.sessionId));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  void _scheduleAutoClose(AttendanceSessionModel session) {
    _autoCloseTimer?.cancel();
    final remaining = session.scheduledEnd.difference(DateTime.now());
    if (remaining.isNegative) {
      _triggerAutoClose(session);
      return;
    }
    _autoCloseTimer = Timer(remaining, () => _triggerAutoClose(session));
  }

  void _triggerAutoClose(AttendanceSessionModel session) {
    if (!mounted || _finalizing) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Session ended',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'The scheduled end time has passed. UNIFY will now finalise the attendance and generate the Excel report.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _finalizeSession(session);
            },
            child: const Text('Generate Report'),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizeSession(AttendanceSessionModel session) async {
    if (_finalizing) return;
    setState(() => _finalizing = true);
    try {
      final uid = ref.read(supabaseProvider).auth.currentUser!.id;
      // In a real app, fetch enrolled students from the community membership table.
      // Passing an empty list means only checked-in students are recorded;
      // absent rows are skipped (safe default when roster is unavailable).
      final report = await ref
          .read(attendanceSessionNotifierProvider.notifier)
          .finalizeSession(
            session:          session,
            enrolledStudents: [],
            finalizedBy:      uid,
          );
      if (mounted) {
        context.pushReplacement('/attendance/history/${session.courseId}',
            extra: {'highlight': report.id});
      }
    } catch (e) {
      if (mounted) {
        setState(() => _finalizing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(attendanceRecordsProvider(widget.sessionId));
    // Load the session from state or history
    final sessionState = ref.watch(attendanceSessionNotifierProvider);
    final session = sessionState.valueOrNull;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Live Attendance',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            if (session != null)
              Text(session.courseName,
                  style: TextStyle(
                      fontSize: 12, color: context.textSecondary,
                      fontWeight: FontWeight.w400)),
          ],
        ),
        backgroundColor: context.appBarBg,
        elevation: 0,
        actions: [
          if (session != null && !_finalizing)
            TextButton.icon(
              onPressed: () => _confirmClose(session),
              icon: const Icon(Icons.lock_rounded, size: 16),
              label: const Text('Close',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: TextButton.styleFrom(foregroundColor: context.error),
            ),
        ],
      ),
      body: Column(
        children: [
          if (session != null) _SessionBanner(session: session),
          Expanded(
            child: recordsAsync.when(
              loading: () => const AppLoadingWidget.list(),
              error: (e, _) => AppErrorWidget(e,
                  onRetry: () => ref.invalidate(
                      attendanceRecordsProvider(widget.sessionId))),
              data: (records) {
                // Schedule auto-close once we have session data
                if (session != null && session.isActive) {
                  WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _scheduleAutoClose(session));
                }
                return _RecordList(
                    records: records, sessionId: widget.sessionId);
              },
            ),
          ),
          if (_finalizing) _FinalizingBanner(),
        ],
      ),
    );
  }

  void _confirmClose(AttendanceSessionModel session) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Close session?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'This will mark remaining students absent, calculate statistics, and generate the Excel report.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _finalizeSession(session);
            },
            style: FilledButton.styleFrom(backgroundColor: context.error),
            child: const Text('Close & Generate'),
          ),
        ],
      ),
    );
  }
}

// ── Session info banner ───────────────────────────────────────────────────────

class _SessionBanner extends StatefulWidget {
  final AttendanceSessionModel session;
  const _SessionBanner({required this.session});

  @override
  State<_SessionBanner> createState() => _SessionBannerState();
}

class _SessionBannerState extends State<_SessionBanner> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final r = widget.session.scheduledEnd.difference(DateTime.now());
    if (mounted) setState(() => _remaining = r.isNegative ? Duration.zero : r);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _countdown {
    if (_remaining == Duration.zero) return 'Session ended';
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    return h > 0
        ? '${h}h ${m.toString().padLeft(2, '0')}m'
        : '${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final isLow   = _remaining.inMinutes <= 10 && _remaining != Duration.zero;
    final ended   = _remaining == Duration.zero;

    return Container(
      margin: const EdgeInsets.all(USpacing.base),
      padding: const EdgeInsets.all(USpacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ended
              ? [context.error, context.error.withValues(alpha: 0.8)]
              : isLow
                  ? [context.warning, context.warning.withValues(alpha: 0.8)]
                  : [context.primary, context.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: URadius.lgAll,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.session.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (widget.session.building != null)
                          widget.session.building!,
                        if (widget.session.room != null)
                          'Room ${widget.session.room}',
                      ].join(' · '),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.80),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_countdown,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          fontFeatures: [FontFeature.tabularFigures()])),
                  Text(
                    '${timeFmt.format(widget.session.scheduledStart)} – '
                    '${timeFmt.format(widget.session.scheduledEnd)}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Record list ───────────────────────────────────────────────────────────────

class _RecordList extends StatelessWidget {
  final List<AttendanceRecordModel> records;
  final String sessionId;

  const _RecordList({required this.records, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');

    // Sort: present/late first, then absent/excused
    final sorted = [...records]..sort((a, b) {
        final order = {
          AttendanceStatus.present:     0,
          AttendanceStatus.lateArrival: 1,
          AttendanceStatus.excused:     2,
          AttendanceStatus.absent:      3,
        };
        final cmp = order[a.status]!.compareTo(order[b.status]!);
        if (cmp != 0) return cmp;
        return a.studentName.compareTo(b.studentName);
      });

    final presentCount = records
        .where((r) =>
            r.status == AttendanceStatus.present ||
            r.status == AttendanceStatus.lateArrival)
        .length;

    return Column(
      children: [
        // Summary bar
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: USpacing.base, vertical: USpacing.sm),
          child: Row(
            children: [
              Text('$presentCount checked in',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: context.success)),
              const Spacer(),
              Text('${records.length} total',
                  style: TextStyle(color: context.textSecondary, fontSize: 13)),
            ],
          ),
        ),
        Expanded(
          child: records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.how_to_reg_rounded,
                          size: 48, color: context.borderCol),
                      const SizedBox(height: 12),
                      Text('Waiting for check-ins',
                          style: TextStyle(color: context.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: USpacing.base),
                  itemCount: sorted.length,
                  itemBuilder: (_, i) {
                    final rec = sorted[i];
                    return _RecordTile(record: rec, timeFmt: timeFmt);
                  },
                ),
        ),
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  final AttendanceRecordModel record;
  final DateFormat timeFmt;

  const _RecordTile({required this.record, required this.timeFmt});

  @override
  Widget build(BuildContext context) {
    final s = record.status;
    return Container(
      margin: const EdgeInsets.only(bottom: USpacing.sm),
      padding: const EdgeInsets.all(USpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: URadius.mdAll,
        border: Border.all(color: s.bgColor, width: 1.5),
        boxShadow: context.shadowXs,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: s.bgColor,
            child: Text(
              record.studentName.isNotEmpty
                  ? record.studentName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                  color: s.color, fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.studentName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                if (record.studentNumber != null)
                  Text(record.studentNumber!,
                      style: TextStyle(
                          fontSize: 11, color: context.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: USpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: s.bgColor,
                  borderRadius: URadius.pillAll,
                ),
                child: Text(s.label,
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: s.color)),
              ),
              if (record.checkInTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(timeFmt.format(record.checkInTime!),
                      style: TextStyle(
                          fontSize: 11, color: context.textSecondary)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinalizingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.primary,
      padding: const EdgeInsets.all(USpacing.base),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2)),
          SizedBox(width: 12),
          Text('Generating Excel report…',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
