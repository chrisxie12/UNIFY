import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../data/models/opportunity_models.dart';
import '../providers/opportunities_provider.dart';
import 'opportunity_form_screen.dart';

/// Admin opportunity management: manage listings, moderation queue, analytics.
class OpportunitiesAdminScreen extends ConsumerWidget {
  const OpportunitiesAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0.6,
          shadowColor: AppColors.border,
          title: const Text('Opportunity Admin',
              style: TextStyle(fontWeight: FontWeight.w800)),
          bottom: TabBar(
            labelColor: context.primary,
            unselectedLabelColor: AppColors.grey2,
            indicatorColor: context.primary,
            tabs: const [
              Tab(text: 'Manage'),
              Tab(text: 'Reports'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const OpportunityFormScreen())),
          backgroundColor: context.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('New',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        body: const TabBarView(
          children: [
            _ManageTab(),
            _ReportsTab(),
            _AnalyticsTab(),
          ],
        ),
      ),
    );
  }
}

class _ManageTab extends ConsumerWidget {
  const _ManageTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(opportunitiesProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AppErrorWidget(e),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text('No opportunities yet. Tap "New" to add one.',
                style: TextStyle(color: AppColors.grey2)),
          );
        }
        return RefreshIndicator(
          color: context.primary,
          onRefresh: () async => ref.invalidate(opportunitiesProvider),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ManageRow(opportunity: items[i]),
          ),
        );
      },
    );
  }
}

class _ManageRow extends ConsumerWidget {
  final OpportunityModel opportunity;
  const _ManageRow({required this.opportunity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = opportunity;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F1F3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: o.type.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(o.type.icon, color: o.type.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(o.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    if (o.isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified_rounded,
                          size: 14, color: o.type.color),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined,
                        size: 12, color: AppColors.grey3),
                    const SizedBox(width: 3),
                    Text('${o.viewCount}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.grey3)),
                    const SizedBox(width: 10),
                    Icon(Icons.bookmark_border_rounded,
                        size: 12, color: AppColors.grey3),
                    const SizedBox(width: 3),
                    Text('${o.saveCount}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.grey3)),
                    const SizedBox(width: 10),
                    Text(o.deadlineLabel,
                        style: TextStyle(
                            fontSize: 11,
                            color: o.isClosingSoon
                                ? AppColors.error
                                : AppColors.grey3)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.grey2),
            onSelected: (v) => _action(context, ref, v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                  value: o.isFeatured ? 'unfeature' : 'feature',
                  child: Text(o.isFeatured ? 'Unfeature' : 'Feature')),
              const PopupMenuItem(value: 'close', child: Text('Close')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _action(
      BuildContext context, WidgetRef ref, String action) async {
    final repo = ref.read(opportunitiesRepositoryProvider);
    switch (action) {
      case 'edit':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => OpportunityFormScreen(existing: opportunity)));
        return;
      case 'feature':
        await repo.updateOpportunity(opportunity.id, {'is_featured': true});
      case 'unfeature':
        await repo.updateOpportunity(opportunity.id, {'is_featured': false});
      case 'close':
        await repo.updateOpportunity(opportunity.id, {'status': 'closed'});
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete opportunity?'),
            content: const Text('This cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style:
                      FilledButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Delete')),
            ],
          ),
        );
        if (ok == true) await repo.deleteOpportunity(opportunity.id);
    }
    ref.invalidate(opportunitiesProvider);
    ref.invalidate(opportunityStatsProvider);
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(opportunityReportQueueProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AppErrorWidget(e),
      data: (reports) {
        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.10),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.verified_rounded,
                      size: 34, color: AppColors.success),
                ),
                const SizedBox(height: 14),
                const Text('Queue is clear',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: context.primary,
          onRefresh: () async =>
              ref.invalidate(opportunityReportQueueProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ReportCard(report: reports[i]),
          ),
        );
      },
    );
  }
}

class _ReportCard extends ConsumerWidget {
  final OpportunityReportItem report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F1F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(report.reason,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error)),
              ),
              const Spacer(),
              Text(report.createdAt.timeAgo,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.grey3)),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: report.opportunityId == null
                ? null
                : () => context.push(
                    '/opportunities/detail/${report.opportunityId}'),
            child: Text(report.opportunityTitle ?? 'Opportunity removed',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 6),
          Text('Reported by ${report.reporterName ?? 'a student'}',
              style: const TextStyle(fontSize: 12, color: AppColors.grey2)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _resolve(ref, 'dismissed'),
                  child: const Text('Dismiss'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: report.opportunityId == null
                      ? null
                      : () => _remove(ref),
                  style:
                      FilledButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Remove'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _resolve(WidgetRef ref, String status) async {
    await ref
        .read(opportunitiesRepositoryProvider)
        .resolveReport(report.id, status);
    ref.invalidate(opportunityReportQueueProvider);
    ref.invalidate(opportunityStatsProvider);
  }

  Future<void> _remove(WidgetRef ref) async {
    final repo = ref.read(opportunitiesRepositoryProvider);
    await repo.updateOpportunity(report.opportunityId!, {'status': 'archived'});
    await repo.resolveReport(report.id, 'actioned');
    ref.invalidate(opportunityReportQueueProvider);
    ref.invalidate(opportunityStatsProvider);
    ref.invalidate(opportunitiesProvider);
  }
}

class _AnalyticsTab extends ConsumerWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(opportunityStatsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AppErrorWidget(e),
      data: (stats) {
        final types = stats.typeCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final searches = stats.topSearches.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final maxType = types.isEmpty ? 0 : types.first.value;
        return RefreshIndicator(
          color: context.primary,
          onRefresh: () async => ref.invalidate(opportunityStatsProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  _statCard('Published', stats.published,
                      Icons.public_rounded, context.primary),
                  _statCard('Closing soon', stats.closingSoon,
                      Icons.alarm_rounded, AppColors.warning),
                  _statCard('Reports', stats.pendingReports,
                      Icons.flag_rounded, AppColors.error),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Opportunities by type',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              if (types.isEmpty)
                const Text('No data yet.',
                    style: TextStyle(color: AppColors.grey3))
              else
                ...types.map((e) {
                  final t = OpportunityType.fromKey(e.key);
                  return _barRow(t.label, e.value, maxType, t.color);
                }),
              const SizedBox(height: 24),
              const Text('Most searched',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              if (searches.isEmpty)
                const Text('No searches recorded yet.',
                    style: TextStyle(color: AppColors.grey3))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: searches
                      .map((e) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${e.key}  ·  ${e.value}',
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color) =>
      Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF0F1F3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text('$value',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              Text(label,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.grey2)),
            ],
          ),
        ),
      );

  Widget _barRow(String label, int value, int max, Color color) {
    final pct = max == 0 ? 0.0 : value / max;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark)),
              Text('$value',
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.grey2)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
