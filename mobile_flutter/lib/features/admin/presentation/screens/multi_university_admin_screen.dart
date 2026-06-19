import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../admin/presentation/providers/admin_provider.dart';
import '../../../admin/presentation/widgets/admin_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';

class MultiUniversityAdminScreen extends ConsumerWidget {
  const MultiUniversityAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(currentUserAdminRoleProvider);
    final role = roleAsync.valueOrNull;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(role == 'super_admin' ? 'Super Admin' : 'Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push('/admin/notifications'),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'University'),
              Tab(text: 'Content'),
              Tab(text: 'People'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(),
            _UniversityTab(),
            _ContentTab(),
            _PeopleTab(),
            _SettingsTab(),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(dashboardCountsProvider);
    final analyticsAsync = ref.watch(latestAnalyticsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dashboardCountsProvider);
        ref.invalidate(latestAnalyticsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          countsAsync.when(
            data: (counts) => Row(
              children: [
                _countTile(context, 'Users', '${counts['total_users'] ?? 0}', Icons.people_rounded, context.primary),
                _countTile(context, 'Communities', '${counts['total_communities'] ?? 0}', Icons.groups_rounded, const Color(0xFF10B981)),
              ],
            ),
            loading: () => const SizedBox(height: 60),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          countsAsync.when(
            data: (counts) => Row(
              children: [
                _countTile(context, 'Pending Verification', '${counts['pending_verifications'] ?? 0}', Icons.verified_user_rounded, AppColors.warning),
                _countTile(context, 'Pending Reports', '${counts['pending_moderation'] ?? 0}', Icons.flag_rounded, AppColors.warning),
              ],
            ),
            loading: () => const SizedBox(height: 60),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          analyticsAsync.when(
            data: (a) => AdminSectionCard(
              title: 'Analytics',
              icon: Icons.trending_up_rounded,
              color: const Color(0xFF8B5CF6),
              onViewAll: () => context.push('/admin/analytics'),
              children: [
                Row(
                  children: [
                    _statTile(context, 'Active Students', '${a.activeStudents}', context.primary, Icons.school_rounded),
                    _statTile(context, 'DAU', '${a.dailyActive}', const Color(0xFF10B981), Icons.trending_up_rounded),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _statTile(context, 'MAU', '${a.monthlyActive}', const Color(0xFF8B5CF6), Icons.people_rounded),
                    _statTile(context, 'Events', '${a.eventsCount}', AppColors.warning, Icons.event_rounded),
                  ],
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          AdminSectionCard(
            title: 'Quick Actions',
            icon: Icons.flash_on_rounded,
            color: AppColors.warning,
            children: [
              _actionItem(context, 'Manage Universities', Icons.account_balance_rounded, context.primary, () => context.push('/admin/universities')),
              _actionItem(context, 'Moderation Queue', Icons.flag_rounded, AppColors.warning, () => context.push('/admin/moderation')),
              _actionItem(context, 'Send Announcement', Icons.campaign_rounded, const Color(0xFF10B981), () => context.push('/admin/communication')),
              _actionItem(context, 'View Audit Logs', Icons.history_rounded, const Color(0xFF8B5CF6), () => context.push('/admin/audit-logs')),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _countTile(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderCol),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.textPrimary)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: context.textSecondary), textAlign: TextAlign.center),
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

  Widget _actionItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary)),
      trailing: Icon(Icons.chevron_right_rounded, color: context.textDisabled),
      onTap: onTap,
      dense: true,
    );
  }
}

class _UniversityTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universitiesAsync = ref.watch(universitiesProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(universitiesProvider),
      child: universitiesAsync.when(
        data: (universities) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AdminActionCard(
              title: 'Manage Universities',
              subtitle: '${universities.length} registered',
              icon: Icons.account_balance_rounded,
              color: context.primary,
              onTap: () => context.push('/admin/universities'),
            ),
            const SizedBox(height: 12),
            AdminActionCard(
              title: 'Faculties & Schools',
              subtitle: 'Organize academic structure',
              icon: Icons.school_rounded,
              color: const Color(0xFF10B981),
              onTap: () => context.push('/admin/faculties'),
            ),
            const SizedBox(height: 12),
            AdminActionCard(
              title: 'Departments',
              subtitle: 'Manage programmes & levels',
              icon: Icons.account_tree_rounded,
              color: const Color(0xFF8B5CF6),
              onTap: () => context.push('/admin/departments'),
            ),
            const SizedBox(height: 12),
            AdminActionCard(
              title: 'Branding',
              subtitle: 'Theme colors, logo, welcome screen',
              icon: Icons.palette_rounded,
              color: AppColors.warning,
              onTap: () => context.push('/admin/branding'),
            ),
            const SizedBox(height: 16),
            Text('Registered Universities', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 12),
            ...universities.map((u) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderCol),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_rounded, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
                        if (u.shortName != null)
                          Text(u.shortName!, style: TextStyle(fontSize: 12, color: context.textSecondary)),
                      ],
                    ),
                  ),
                  if (u.shortName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(u.shortName!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.primary)),
                    ),
                ],
              ),
            )),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(universitiesProvider)),
      ),
    );
  }
}

class _ContentTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modAsync = ref.watch(pendingModerationProvider);
    final oppAsync = ref.watch(pendingOpportunitiesProvider);
    final modCount = modAsync.valueOrNull?.length ?? 0;
    final oppCount = oppAsync.valueOrNull?.length ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminActionCard(
          title: 'Moderation Center',
          subtitle: modCount > 0 ? '$modCount pending reports' : 'No pending reports',
          icon: Icons.flag_rounded,
          color: AppColors.warning,
          onTap: () => context.push('/admin/moderation'),
        ),
        const SizedBox(height: 12),
        AdminActionCard(
          title: 'Community Management',
          subtitle: 'View, suspend, feature communities',
          icon: Icons.groups_rounded,
          color: context.primary,
          onTap: () => context.push('/admin/communities'),
        ),
        const SizedBox(height: 12),
        AdminActionCard(
          title: 'Marketplace Admin',
          subtitle: 'Reports, listings, sellers',
          icon: Icons.shopping_bag_rounded,
          color: const Color(0xFFFF6B35),
          onTap: () => context.push('/admin/marketplace'),
        ),
        const SizedBox(height: 12),
        AdminActionCard(
          title: 'Events Admin',
          subtitle: 'Approve, feature, manage events',
          icon: Icons.event_rounded,
          color: const Color(0xFF10B981),
          onTap: () => context.push('/admin/events'),
        ),
        const SizedBox(height: 12),
        AdminActionCard(
          title: 'Academic Hub Admin',
          subtitle: 'Resources, past questions, materials',
          icon: Icons.menu_book_rounded,
          color: const Color(0xFF8B5CF6),
          onTap: () => context.push('/admin/academic'),
        ),
        const SizedBox(height: 12),
        AdminActionCard(
          title: 'Opportunities',
          subtitle: oppCount > 0 ? '$oppCount pending approvals' : 'Manage scholarships & internships',
          icon: Icons.work_rounded,
          color: AppColors.warning,
          onTap: () => context.push('/admin/opportunities'),
        ),
      ],
    );
  }
}

class _PeopleTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifAsync = ref.watch(pendingVerificationRequestsProvider);
    final verifCount = verifAsync.valueOrNull?.length ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminActionCard(
          title: 'Verification Management',
          subtitle: verifCount > 0 ? '$verifCount pending verifications' : 'Verify students & leaders',
          icon: Icons.verified_user_rounded,
          color: context.primary,
          onTap: () => context.push('/admin/verification'),
        ),
        const SizedBox(height: 12),
        AdminActionCard(
          title: 'Admin Management',
          subtitle: 'Assign & manage admin roles',
          icon: Icons.admin_panel_settings_rounded,
          color: AppColors.warning,
          onTap: () => context.push('/admin/admins'),
        ),
        const SizedBox(height: 12),
        AdminActionCard(
          title: 'Analytics Dashboard',
          subtitle: 'User growth, engagement, activity',
          icon: Icons.analytics_rounded,
          color: const Color(0xFF8B5CF6),
          onTap: () => context.push('/admin/analytics'),
        ),
        const SizedBox(height: 12),
        AdminActionCard(
          title: 'Audit Logs',
          subtitle: 'Track all admin actions',
          icon: Icons.history_rounded,
          color: context.textPrimary,
          onTap: () => context.push('/admin/audit-logs'),
        ),
      ],
    );
  }
}

class _SettingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminActionCard(
          title: 'Communication Center',
          subtitle: 'Send announcements to users',
          icon: Icons.campaign_rounded,
          color: context.primary,
          onTap: () => context.push('/admin/communication'),
        ),
        const SizedBox(height: 12),
        AdminActionCard(
          title: 'University Branding',
          subtitle: 'Theme colors, logo, welcome screen',
          icon: Icons.palette_rounded,
          color: AppColors.warning,
          onTap: () => context.push('/admin/branding'),
        ),
        const SizedBox(height: 12),
        AdminActionCard(
          title: 'Verification Requirements',
          subtitle: 'Configure verification rules',
          icon: Icons.verified_rounded,
          color: const Color(0xFF8B5CF6),
          onTap: () => context.push('/admin/verification-requirements'),
        ),
      ],
    );
  }
}
