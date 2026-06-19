import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../data/models/opportunity_models.dart';
import '../providers/opportunities_provider.dart';

/// Kanban-style application tracker grouped by stage.
class ApplicationTrackerScreen extends ConsumerWidget {
  const ApplicationTrackerScreen({super.key});

  static const _columns = [
    ApplicationStage.saved,
    ApplicationStage.preparing,
    ApplicationStage.applied,
    ApplicationStage.interview,
    ApplicationStage.accepted,
    ApplicationStage.rejected,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(applicationsProvider);
    return DefaultTabController(
      length: _columns.length,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.appBarBg,
          surfaceTintColor: context.appBarBg,
          elevation: 0.6,
          shadowColor: context.borderCol,
          title: const Text('Application Tracker',
              style: TextStyle(fontWeight: FontWeight.w800)),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: context.primary,
            unselectedLabelColor: AppColors.grey2,
            indicatorColor: context.primary,
            tabs: _columns.map((s) => Tab(text: s.label)).toList(),
          ),
        ),
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(e),
          data: (apps) {
            if (apps.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                          color: context.cardBg, shape: BoxShape.circle),
                      child: Icon(Icons.track_changes_rounded,
                          size: 32, color: context.textDisabled),
                    ),
                    const SizedBox(height: 14),
                    const Text('Nothing tracked yet',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                        'Save an opportunity and set its status to start tracking.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 13, color: context.textSecondary)),
                  ],
                ),
              );
            }
            return TabBarView(
              children: _columns.map((stage) {
                final list =
                    apps.where((a) => a.stage == stage).toList();
                if (list.isEmpty) {
                  return Center(
                    child: Text('No ${stage.label.toLowerCase()} items',
                        style: TextStyle(color: context.textSecondary)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _AppRow(app: list[i]),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _AppRow extends ConsumerWidget {
  final TrackedApplication app;
  const _AppRow({required this.app});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = app.opportunity;
    return GestureDetector(
      onTap: o == null
          ? null
          : () => context.push('/opportunities/detail/${o.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (o?.type.color ?? AppColors.grey3)
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(o?.type.icon ?? Icons.work_outline_rounded,
                  color: o?.type.color ?? AppColors.grey3, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o?.title ?? 'Opportunity',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  if (o?.organization != null)
                    Text(o!.organization!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, color: context.textSecondary)),
                  if (o?.deadline != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 12,
                            color: o!.isClosingSoon
                                ? AppColors.error
                                : AppColors.grey3),
                        const SizedBox(width: 4),
                        Text(o.deadlineLabel,
                            style: TextStyle(
                                fontSize: 11,
                                color: o.isClosingSoon
                                    ? AppColors.error
                                    : AppColors.grey3)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<ApplicationStage>(
              icon: Icon(Icons.more_vert_rounded,
                  color: context.textSecondary),
              onSelected: (s) => _move(ref, s),
              itemBuilder: (_) => ApplicationStage.values
                  .where((s) => s != app.stage)
                  .map((s) => PopupMenuItem(
                      value: s, child: Text('Move to ${s.label}')))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _move(WidgetRef ref, ApplicationStage stage) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await ref.read(opportunitiesRepositoryProvider).setStage(
          userId: user.id,
          opportunityId: app.opportunityId,
          stage: stage,
        );
    ref.invalidate(applicationsProvider);
  }
}