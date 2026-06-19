import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/moderation_item_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';

class ModerationCenterScreen extends ConsumerWidget {
  const ModerationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Moderation Center'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'All Reports'),
              Tab(text: 'Resolved'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ModerationList(status: 'pending'),
            _ModerationList(),
            _ModerationList(status: 'resolved'),
          ],
        ),
      ),
    );
  }
}

class _ModerationList extends ConsumerWidget {
  final String? status;
  const _ModerationList({this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = status == 'pending'
        ? pendingModerationProvider
        : moderationQueueProvider;
    final asyncData = ref.watch(provider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(provider),
      child: asyncData.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 48, color: context.borderCol),
                  SizedBox(height: 12),
                  Text('All clear!', style: TextStyle(fontSize: 16, color: context.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, i) => _ModerationCard(item: items[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ModerationCard extends ConsumerWidget {
  final ModerationItemModel item;
  const _ModerationCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (item.reportType) {
      'user' => Colors.orange,
      'post' => const Color(0xFF8B5CF6),
      'community' => context.primary,
      'marketplace' => const Color(0xFFFF6B35),
      'event' => const Color(0xFF10B981),
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
                  child: Icon(_reportIcon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.reportTypeLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                      const SizedBox(height: 2),
                      Text('by ${item.reporterName ?? "Unknown"}', style: const TextStyle(fontSize: 12, color: context.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge(item.status),
              ],
            ),
          ),
          if (item.reason != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: context.bg, borderRadius: BorderRadius.circular(10)),
                child: Text(item.reason!, style: const TextStyle(fontSize: 13, color: context.textPrimary, height: 1.4)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(timeAgo(item.createdAt), style: const TextStyle(fontSize: 11, color: context.textDisabled)),
          ),
          if (item.status == 'pending')
            Container(
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: context.borderCol))),
              child: Row(
                children: [
                  Expanded(child: _actionBtn(context, 'Dismiss', AppColors.grey1, () => _resolve(context, ref, 'dismissed'))),
                  Container(width: 1, height: 36, color: context.borderCol),
                  Expanded(child: _actionBtn(context, 'Resolve', AppColors.success, () => _resolve(context, ref, 'resolved'))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData get _reportIcon {
    switch (item.reportType) {
      case 'user': return Icons.person_rounded;
      case 'post': return Icons.article_rounded;
      case 'community': return Icons.groups_rounded;
      case 'marketplace': return Icons.shopping_bag_rounded;
      case 'event': return Icons.event_rounded;
      default: return Icons.flag_rounded;
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
            Icon(Icons.check_rounded, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _resolve(BuildContext context, WidgetRef ref, String status) async {
    final repo = ref.read(adminRepositoryProvider);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    await repo.updateModerationStatus(item.id, status, userId);
    ref.invalidate(pendingModerationProvider);
    ref.invalidate(moderationQueueProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report $status'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
      );
    }
  }
}
