import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/ops_models.dart';
import '../providers/ops_provider.dart';
import '../widgets/ops_widgets.dart';

class SystemHealthScreen extends ConsumerWidget {
  const SystemHealthScreen({super.key});

  String _formatBytes(double? bytes) {
    if (bytes == null || bytes <= 0) return 'N/A';
    const mb = 1024 * 1024;
    const gb = mb * 1024;
    if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(1)} GB';
    return '${(bytes / mb).toStringAsFixed(1)} MB';
  }

  String _formatLatency(double? ms) {
    if (ms == null || ms <= 0) return 'N/A';
    return '${ms.toStringAsFixed(0)} ms';
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(systemHealthProvider);
    final errorsAsync = ref.watch(recentErrorsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('System Health',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(systemHealthProvider);
          ref.invalidate(recentErrorsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            healthAsync.when(
              loading: () => const _Loading(),
              error: (e, _) => _ErrorText(error: e),
              data: (m) {
                final errors24h = opsInt(m['errors_24h']);
                final critical24h = opsInt(m['critical_24h']);
                final apiErrors24h = opsInt(m['api_errors_24h']);
                final failedNotifs = opsInt(m['failed_notifications_24h']);
                final activeNow = opsInt(m['active_users_now']);
                final storage = m['latest_storage_bytes'] == null
                    ? null
                    : opsDouble(m['latest_storage_bytes']);
                final latency = m['latest_db_latency_ms'] == null
                    ? null
                    : opsDouble(m['latest_db_latency_ms']);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          OpsStatCard(
                            icon: Icons.bug_report_rounded,
                            value: '$errors24h',
                            label: 'Errors 24h',
                            color: AppColors.warning,
                          ),
                          OpsStatCard(
                            icon: Icons.dangerous_rounded,
                            value: '$critical24h',
                            label: 'Critical 24h',
                            color: critical24h > 0
                                ? AppColors.error
                                : AppColors.grey3,
                          ),
                          OpsStatCard(
                            icon: Icons.cloud_off_rounded,
                            value: '$apiErrors24h',
                            label: 'API errors 24h',
                            color: AppColors.info,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          OpsStatCard(
                            icon: Icons.notifications_off_rounded,
                            value: '$failedNotifs',
                            label: 'Failed notifs 24h',
                            color: AppColors.warning,
                          ),
                          OpsStatCard(
                            icon: Icons.person_pin_circle_rounded,
                            value: '$activeNow',
                            label: 'Active now',
                            color: AppColors.success,
                          ),
                          OpsStatCard(
                            icon: Icons.storage_rounded,
                            value: _formatBytes(storage),
                            label: 'Storage',
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          OpsStatCard(
                            icon: Icons.speed_rounded,
                            value: _formatLatency(latency),
                            label: 'DB latency',
                            color: AppColors.info,
                          ),
                          const Spacer(),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                'Recent errors',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark),
              ),
            ),
            errorsAsync.when(
              loading: () => const _Loading(),
              error: (e, _) => _ErrorText(error: e),
              data: (errors) {
                if (errors.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No recent errors logged',
                          style: TextStyle(color: AppColors.grey2)),
                    ),
                  );
                }
                return Column(
                  children: errors
                      .map((e) => _ErrorTile(
                            entry: e,
                            color: _severityColor(e.severity),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  final ErrorLogEntry entry;
  final Color color;
  const _ErrorTile({required this.entry, required this.color});

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (entry.source != null && entry.source!.isNotEmpty) entry.source!,
      if (entry.platform != null && entry.platform!.isNotEmpty) entry.platform!,
      entry.createdAt.timeAgo,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 5, 12, 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark),
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  style:
                      const TextStyle(fontSize: 11.5, color: AppColors.grey2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
}

class _ErrorText extends StatelessWidget {
  final Object error;
  const _ErrorText({required this.error});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text('Could not load: $error')),
      );
}
