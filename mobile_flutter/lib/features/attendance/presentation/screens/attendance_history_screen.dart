import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../data/models/attendance_models.dart';
import '../providers/attendance_provider.dart';

class AttendanceHistoryScreen extends ConsumerWidget {
  final String courseId;
  final String courseCode;
  final String courseName;

  const AttendanceHistoryScreen({
    super.key,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionHistoryProvider(courseId));

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Attendance History',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            Text(courseCode,
                style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w400)),
          ],
        ),
        backgroundColor: context.appBarBg,
        elevation: 0,
      ),
      body: sessionsAsync.when(
        loading: () => const AppLoadingWidget.list(),
        error: (e, _) => AppErrorWidget(e,
            onRetry: () => ref.invalidate(sessionHistoryProvider(courseId))),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_edu_rounded,
                      size: 56, color: context.borderCol),
                  const SizedBox(height: 16),
                  Text('No sessions yet',
                      style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 17)),
                  const SizedBox(height: 8),
                  Text('Start a session to record attendance',
                      style: TextStyle(
                          color: context.textSecondary, fontSize: 14)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(USpacing.base),
            itemCount: sessions.length,
            itemBuilder: (_, i) => _SessionCard(
              session: sessions[i],
              courseId: courseId,
            ),
          );
        },
      ),
    );
  }
}

// ── Session history card ──────────────────────────────────────────────────────

class _SessionCard extends ConsumerWidget {
  final AttendanceSessionModel session;
  final String courseId;

  const _SessionCard({required this.session, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFmt = DateFormat('EEE, MMM d yyyy');
    final timeFmt = DateFormat('HH:mm');
    final reportAsync = ref.watch(sessionReportProvider(session.id));
    final recordsAsync = ref.watch(attendanceRecordsProvider(session.id));

    return Container(
      margin: const EdgeInsets.only(bottom: USpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: URadius.lgAll,
        boxShadow: context.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(USpacing.base),
            decoration: BoxDecoration(
              color: session.isClosed
                  ? context.surfaceFill
                  : context.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(URadius.lg)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        '${dateFmt.format(session.scheduledStart)}  ·  '
                        '${timeFmt.format(session.scheduledStart)}–'
                        '${timeFmt.format(session.scheduledEnd)}',
                        style: TextStyle(
                            fontSize: 12, color: context.textSecondary),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: session.status),
              ],
            ),
          ),

          // ── Stats strip ───────────────────────────────────────
          recordsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(USpacing.base),
              child: LinearProgressIndicator(),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (records) {
              if (records.isEmpty) return const SizedBox.shrink();
              final stats = AttendanceStats.compute(session, records);
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: USpacing.base, vertical: USpacing.md),
                child: Row(
                  children: [
                    _StatPill('${stats.present}', 'Present',
                        AttendanceStatus.present.color,
                        AttendanceStatus.present.bgColor),
                    const SizedBox(width: USpacing.sm),
                    _StatPill('${stats.lateArrival}', 'Late',
                        AttendanceStatus.lateArrival.color,
                        AttendanceStatus.lateArrival.bgColor),
                    const SizedBox(width: USpacing.sm),
                    _StatPill('${stats.absent}', 'Absent',
                        AttendanceStatus.absent.color,
                        AttendanceStatus.absent.bgColor),
                    const Spacer(),
                    Text(
                      '${stats.attendancePercent.toStringAsFixed(0)}%',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: _pctColor(context, stats.attendancePercent)),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── Download area ─────────────────────────────────────
          if (session.isClosed)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  USpacing.base, 0, USpacing.base, USpacing.base),
              child: reportAsync.when(
                loading: () => const SizedBox(
                    height: 36,
                    child: Center(child: LinearProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
                data: (report) {
                  if (report == null) {
                    return Text(
                      'Report not yet available',
                      style: TextStyle(
                          color: context.textSecondary, fontSize: 12),
                    );
                  }
                  return _DownloadRow(report: report, ref: ref);
                },
              ),
            ),
        ],
      ),
    );
  }

  Color _pctColor(BuildContext context, double pct) {
    if (pct >= 75) return context.success;
    if (pct >= 50) return context.warning;
    return context.error;
  }
}

// ── Download row ──────────────────────────────────────────────────────────────

class _DownloadRow extends ConsumerWidget {
  final AttendanceReportModel report;
  final WidgetRef ref;

  const _DownloadRow({required this.report, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _download(context, ref),
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Excel',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.primary,
              side: BorderSide(color: context.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: URadius.smAll),
            ),
          ),
        ),
        const SizedBox(width: USpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _openInBrowser(context),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('View',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.textSecondary,
              side: BorderSide(color: context.borderSubtle),
              shape: RoundedRectangleBorder(
                  borderRadius: URadius.smAll),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    try {
      // Get a fresh signed URL (the stored one may have expired)
      final url = await ref
          .read(attendanceRepositoryProvider)
          .getSignedDownloadUrl(report.storagePath);
      await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        UnifySnackbar.error(context, 'Could not open download link');
      }
    }
  }

  Future<void> _openInBrowser(BuildContext context) async {
    try {
      await launchUrl(Uri.parse(report.downloadUrl),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        UnifySnackbar.error(context, 'Could not open link');
      }
    }
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final SessionStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool active = status == SessionStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? context.success.withValues(alpha: 0.12)
            : context.surfaceDivider,
        borderRadius: URadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                color: context.success,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            active ? 'Live' : status.name[0].toUpperCase() + status.name.substring(1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: active ? context.success : context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  final Color bg;

  const _StatPill(this.count, this.label, this.color, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: USpacing.sm, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: URadius.pillAll),
      child: Text(
        '$count $label',
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
