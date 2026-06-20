import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(auditLogsProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(auditLogsProvider),
        child: logsAsync.when(
          data: (logs) {
            if (logs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_rounded, size: 48, color: context.borderCol),
                    SizedBox(height: 12),
                    Text('No audit logs yet', style: TextStyle(fontSize: 16, color: context.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (_, i) => _AuditLogCard(log: logs[i]),
            );
          },
          loading: () => const AppLoadingWidget.list(),
          error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(auditLogsProvider)),
        ),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final dynamic log;
  const _AuditLogCard({required this.log});

  IconData get _entityIcon {
    switch (log.entityType) {
      case 'university': return Icons.account_balance_rounded;
      case 'faculty': return Icons.school_rounded;
      case 'department': return Icons.account_tree_rounded;
      case 'verification': return Icons.verified_user_rounded;
      case 'badge': return Icons.workspace_premium_rounded;
      case 'community': return Icons.groups_rounded;
      case 'admin': return Icons.admin_panel_settings_rounded;
      case 'announcement': return Icons.campaign_rounded;
      default: return Icons.history_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_entityIcon, size: 18, color: context.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.actionLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  '${log.actorName ?? "Unknown"} · ${log.entityType.replaceAll("_", " ")}',
                  style: TextStyle(fontSize: 11, color: context.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(timeAgo(log.createdAt), style: TextStyle(fontSize: 10, color: context.textDisabled)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}