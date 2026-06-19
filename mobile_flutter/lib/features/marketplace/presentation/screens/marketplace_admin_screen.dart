import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../data/models/marketplace_models.dart';
import '../providers/marketplace_provider.dart';

/// Admin dashboard: moderation queue + marketplace analytics.
class MarketplaceAdminScreen extends ConsumerWidget {
  const MarketplaceAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          surfaceTintColor: Colors.white,
          elevation: 0.6,
          shadowColor: AppColors.border,
          title: const Text('Marketplace Admin',
              style: TextStyle(fontWeight: FontWeight.w800)),
          bottom: TabBar(
            labelColor: context.primary,
            unselectedLabelColor: AppColors.grey2,
            indicatorColor: context.primary,
            tabs: const [
              Tab(text: 'Reports'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ReportsTab(),
            _AnalyticsTab(),
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(marketplaceReportQueueProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load reports\n$e')),
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
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded,
                      size: 34, color: AppColors.success),
                ),
                const SizedBox(height: 14),
                const Text('Queue is clear',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text('No pending listing reports.',
                    style: TextStyle(fontSize: 13, color: context.textSecondary)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(marketplaceReportQueueProvider),
          color: context.primary,
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
  final ListingReportItem report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
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
                  style: const TextStyle(
                      fontSize: 11, color: context.textDisabled)),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: report.listingId == null
                ? null
                : () => context
                    .push('/marketplace/listing/${report.listingId}'),
            child: Text(report.listingTitle ?? 'Listing removed',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          if (report.details != null && report.details!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(report.details!,
                style: const TextStyle(
                    fontSize: 13, color: context.textPrimary)),
          ],
          const SizedBox(height: 6),
          Text('Reported by ${report.reporterName ?? 'a student'}',
              style: const TextStyle(fontSize: 12, color: context.textSecondary)),
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
                  onPressed: report.listingId == null
                      ? null
                      : () => _removeListing(ref),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error),
                  child: const Text('Remove listing'),
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
        .read(marketplaceRepositoryProvider)
        .resolveReport(report.id, status);
    ref.invalidate(marketplaceReportQueueProvider);
    ref.invalidate(marketplaceStatsProvider);
  }

  Future<void> _removeListing(WidgetRef ref) async {
    final repo = ref.read(marketplaceRepositoryProvider);
    await repo.moderateListing(report.listingId!,
        moderation: 'rejected', status: 'removed');
    await repo.resolveReport(report.id, 'actioned');
    ref.invalidate(marketplaceReportQueueProvider);
    ref.invalidate(marketplaceStatsProvider);
    ref.invalidate(listingsProvider);
  }
}

class _AnalyticsTab extends ConsumerWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(marketplaceStatsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load analytics\n$e')),
      data: (stats) {
        final cats = stats.categoryCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final searches = stats.topSearches.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(marketplaceStatsProvider),
          color: context.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  _statCard('Active', stats.activeListings,
                      Icons.storefront_rounded, context.primary),
                  _statCard('Sold', stats.soldListings,
                      Icons.check_circle_rounded, AppColors.success),
                  _statCard('Reports', stats.pendingReports,
                      Icons.flag_rounded, AppColors.error),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Popular categories',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              if (cats.isEmpty)
                const Text('No data yet.',
                    style: TextStyle(color: context.textDisabled))
              else
                ...cats.map((e) => _barRow(
                    e.key.replaceAll('_', ' '),
                    e.value,
                    cats.first.value,
                    context)),
              const SizedBox(height: 24),
              const Text('Most searched',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              if (searches.isEmpty)
                const Text('No searches recorded yet.',
                    style: TextStyle(color: context.textDisabled))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: searches
                      .map((e) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: context.cardBg,
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
            color: context.cardBg,
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
                  style: const TextStyle(
                      fontSize: 11, color: context.textSecondary)),
            ],
          ),
        ),
      );

  Widget _barRow(String label, int value, int max, BuildContext context) {
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
                      color: context.textPrimary)),
              Text('$value',
                  style: const TextStyle(
                      fontSize: 13, color: context.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation(context.primary),
            ),
          ),
        ],
      ),
    );
  }
}
