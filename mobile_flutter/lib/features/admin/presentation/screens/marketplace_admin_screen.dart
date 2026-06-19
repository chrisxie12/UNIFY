import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/marketplace_report_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/extensions/theme_extensions.dart';

class MarketplaceAdminScreen extends ConsumerWidget {
  const MarketplaceAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Marketplace Admin'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Resolved'),
              Tab(text: 'All'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ReportList(status: 'pending'),
            _ReportList(status: 'resolved'),
            _ReportList(),
          ],
        ),
      ),
    );
  }
}

class _ReportList extends ConsumerWidget {
  final String? status;
  const _ReportList({this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(marketplaceReportsProvider);
    final items = asyncData.valueOrNull?.where((r) {
      if (status == null) return true;
      return r.status == status;
    }).toList() ?? [];

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(marketplaceReportsProvider),
      child: asyncData.when(
        data: (_) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 48, color: context.borderCol),
                  SizedBox(height: 12),
                  Text('No reports', style: TextStyle(fontSize: 16, color: context.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, i) => _MarketplaceReportCard(report: items[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(marketplaceReportsProvider)),
      ),
    );
  }
}

class _MarketplaceReportCard extends ConsumerWidget {
  final MarketplaceReportModel report;
  const _MarketplaceReportCard({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFFFF6B35), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Listing #${report.listingId.substring(0, 8)}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                      Text('by ${report.reporterName ?? "Unknown"}', style: TextStyle(fontSize: 12, color: context.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge(report.status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: context.bg, borderRadius: BorderRadius.circular(10)),
              child: Text(report.reason, style: TextStyle(fontSize: 13, color: context.textPrimary)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(timeAgo(report.createdAt), style: TextStyle(fontSize: 11, color: context.textDisabled)),
          ),
          if (report.status == 'pending')
            Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: context.borderCol))),
              child: Row(
                children: [
                  Expanded(child: _actionBtn(context, 'Dismiss', AppColors.grey1, () => _resolve(context, ref, 'dismissed'))),
                  Container(width: 1, height: 36, color: context.borderCol),
                  Expanded(child: _actionBtn(context, 'Remove', AppColors.error, () => _resolve(context, ref, 'resolved', 'listing_removed'))),
                  Container(width: 1, height: 36, color: context.borderCol),
                  Expanded(child: _actionBtn(context, 'Warn', AppColors.warning, () => _resolve(context, ref, 'resolved', 'seller_warned'))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
      ),
    );
  }

  Future<void> _resolve(BuildContext context, WidgetRef ref, String status, [String? action]) async {
    final repo = ref.read(adminRepositoryProvider);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    await repo.resolveMarketplaceReport(report.id, action ?? 'dismissed', userId);
    ref.invalidate(marketplaceReportsProvider);
    ref.invalidate(pendingMarketplaceReportsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report $status'), behavior: SnackBarBehavior.floating),
      );
    }
  }
}