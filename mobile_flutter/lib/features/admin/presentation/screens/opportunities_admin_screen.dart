import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/opportunity_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';

class OpportunitiesAdminScreen extends ConsumerWidget {
  const OpportunitiesAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Opportunities'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'All'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OpportunityList(status: 'pending'),
            _OpportunityList(status: 'approved'),
            _OpportunityList(),
          ],
        ),
      ),
    );
  }
}

class _OpportunityList extends ConsumerWidget {
  final String? status;
  const _OpportunityList({this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(opportunitiesProvider);

    final items = asyncData.valueOrNull?.where((o) {
      if (status == null) return true;
      return o.status == status;
    }).toList() ?? [];

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(opportunitiesProvider),
      child: asyncData.when(
        data: (_) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.work_outline_rounded, size: 48, color: context.borderCol),
                  const SizedBox(height: 12),
                  Text(
                    status == 'pending' ? 'No pending opportunities' : 'No opportunities found',
                    style: TextStyle(fontSize: 16, color: context.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, i) => _OpportunityCard(opportunity: items[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(opportunitiesProvider)),
      ),
    );
  }
}

class _OpportunityCard extends ConsumerWidget {
  final OpportunityModel opportunity;
  const _OpportunityCard({required this.opportunity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (opportunity.opportunityType) {
      'scholarship' => const Color(0xFF10B981),
      'internship' => context.primary,
      'fellowship' => const Color(0xFF8B5CF6),
      'competition' => AppColors.warning,
      _ => AppColors.grey2,
    };

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
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(_typeIcon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opportunity.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                      const SizedBox(height: 2),
                      Text(opportunity.opportunityTypeLabel, style: TextStyle(fontSize: 12, color: context.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge(opportunity.status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: context.bg, borderRadius: BorderRadius.circular(10)),
              child: Text(opportunity.description, style: TextStyle(fontSize: 13, color: context.textPrimary, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                if (opportunity.organizerName != null)
                  Text(opportunity.organizerName!, style: TextStyle(fontSize: 11, color: context.textSecondary)),
                if (opportunity.deadline != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.access_time_rounded, size: 12, color: opportunity.isExpired ? AppColors.error : AppColors.grey2),
                  const SizedBox(width: 4),
                  Text(
                    opportunity.isExpired ? 'Expired' : timeAgo(opportunity.deadline!),
                    style: TextStyle(fontSize: 11, color: opportunity.isExpired ? AppColors.error : AppColors.grey2),
                  ),
                ],
              ],
            ),
          ),
          if (opportunity.isPending)
            Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: context.borderCol))),
              child: Row(
                children: [
                  Expanded(child: _actionBtn(context, 'Reject', AppColors.error, () => _handle(context, ref, 'rejected'))),
                  Container(width: 1, height: 36, color: context.borderCol),
                  Expanded(child: _actionBtn(context, 'Approve', AppColors.success, () => _handle(context, ref, 'approved'))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData get _typeIcon {
    switch (opportunity.opportunityType) {
      case 'scholarship': return Icons.school_rounded;
      case 'internship': return Icons.work_rounded;
      case 'fellowship': return Icons.groups_rounded;
      case 'competition': return Icons.emoji_events_rounded;
      default: return Icons.work_outline_rounded;
    }
  }

  Widget _actionBtn(BuildContext context, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(label == 'Approve' ? Icons.check_rounded : Icons.close_rounded, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _handle(BuildContext context, WidgetRef ref, String status) async {
    final repo = ref.read(adminRepositoryProvider);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    await repo.updateOpportunityStatus(opportunity.id, status, userId);
    ref.invalidate(opportunitiesProvider);
    ref.invalidate(pendingOpportunitiesProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opportunity $status'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
      );
    }
  }
}
