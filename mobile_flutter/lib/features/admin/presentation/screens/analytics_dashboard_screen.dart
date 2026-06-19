import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(latestAnalyticsProvider);
    final countsAsync = ref.watch(dashboardCountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(latestAnalyticsProvider);
          ref.invalidate(dashboardCountsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            analyticsAsync.when(
              data: (a) => AdminSectionCard(
                title: 'User Activity',
                icon: Icons.people_rounded,
                color: context.primary,
                children: [
                  Row(
                    children: [
                      _statTile(context, 'Active Students', '${a.activeStudents}', context.primary, Icons.school_rounded),
                      _statTile(context, 'Daily Active', '${a.dailyActive}', const Color(0xFF10B981), Icons.trending_up_rounded),
                    ],
                  ),
                  Row(
                    children: [
                      _statTile(context, 'Monthly Active', '${a.monthlyActive}', const Color(0xFF8B5CF6), Icons.people_rounded),
                    ],
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            analyticsAsync.when(
              data: (a) => AdminSectionCard(
                title: 'Platform Metrics',
                icon: Icons.analytics_rounded,
                color: AppColors.warning,
                children: [
                  Row(
                    children: [
                      _statTile(context, 'Communities', '${a.communities}', context.primary, Icons.groups_rounded),
                      _statTile(context, 'Events', '${a.eventsCount}', AppColors.warning, Icons.event_rounded),
                    ],
                  ),
                  Row(
                    children: [
                      _statTile(context, 'Posts', '${a.postsCount}', const Color(0xFF8B5CF6), Icons.article_rounded),
                      _statTile(context, 'Marketplace', '${a.marketplaceCount}', const Color(0xFFFF6B35), Icons.shopping_bag_rounded),
                    ],
                  ),
                  if (a.opportunitiesCount > 0)
                    Row(
                      children: [
                        _statTile(context, 'Opportunities', '${a.opportunitiesCount}', const Color(0xFF10B981), Icons.work_rounded),
                      ],
                    ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            countsAsync.when(
              data: (counts) => AdminSectionCard(
                title: 'Pending Items',
                icon: Icons.pending_actions_rounded,
                color: AppColors.warning,
                children: [
                  Row(
                    children: [
                      _statTile(context, 'Verifications', '${counts['pending_verifications'] ?? 0}', AppColors.warning, Icons.verified_user_rounded),
                      _statTile(context, 'Reports', '${counts['pending_moderation'] ?? 0}', AppColors.error, Icons.flag_rounded),
                    ],
                  ),
                  Row(
                    children: [
                      _statTile(context, 'Opportunities', '${counts['pending_opportunities'] ?? 0}', const Color(0xFF10B981), Icons.work_rounded),
                    ],
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statTile(BuildContext context, String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 9, color: context.textSecondary)),
          ],
        ),
      ),
    );
  }
}
