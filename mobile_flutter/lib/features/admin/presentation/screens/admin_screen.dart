import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../leadership/data/models/community_request_model.dart';
import '../../../leadership/presentation/providers/leadership_provider.dart';

// ── Admin Local Providers ────────────────────────────────────

final _allRequestsProvider = FutureProvider.autoDispose<List<CommunityRequestModel>>((ref) async {
  return ref.read(leadershipRepositoryProvider).getAllRequests();
});

final _pendingRequestsProvider = FutureProvider.autoDispose<List<CommunityRequestModel>>((ref) async {
  return ref.read(leadershipRepositoryProvider).getAllRequests(statuses: ['pending']);
});

class _AdminStats {
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  _AdminStats(this.total, this.pending, this.approved, this.rejected);
}

final _adminStatsProvider = FutureProvider.autoDispose<_AdminStats>((ref) async {
  final all = await ref.read(leadershipRepositoryProvider).getAllRequests();
  return _AdminStats(
    all.length,
    all.where((r) => r.status == 'pending').length,
    all.where((r) => r.status == 'approved').length,
    all.where((r) => r.status == 'rejected').length,
  );
});

// ── Screen ───────────────────────────────────────────────────

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Requests'),
              Tab(text: 'All History'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey3,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: TabBarView(
          children: [
            _PendingRequestsTab(),
            _AllRequestsTab(),
          ],
        ),
      ),
    );
  }
}

// ── Pending Requests Tab ─────────────────────────────────────

class _PendingRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(_pendingRequestsProvider);
    final statsAsync = ref.watch(_adminStatsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_pendingRequestsProvider);
        ref.invalidate(_adminStatsProvider);
        ref.invalidate(_allRequestsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats cards
          statsAsync.when(
            data: (stats) => _StatsGrid(stats: stats),
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox(height: 80),
          ),
          const SizedBox(height: 16),

          // Section header
          Row(
            children: [
              Icon(Icons.hourglass_empty_rounded, size: 16, color: context.primary),
              const SizedBox(width: 6),
              Text('Pending Reviews', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
            ],
          ),
          const SizedBox(height: 12),

          pendingAsync.when(
            data: (requests) {
              if (requests.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.grey4),
                        SizedBox(height: 12),
                        Text('All caught up!', style: TextStyle(fontSize: 15, color: AppColors.grey2, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('No pending requests to review.', style: TextStyle(fontSize: 13, color: AppColors.grey3)),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: requests.map((r) => _RequestCard(request: r)).toList(),
              );
            },
            error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}

// ── All Requests Tab ─────────────────────────────────────────

class _AllRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(_allRequestsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_allRequestsProvider);
        ref.invalidate(_adminStatsProvider);
        ref.invalidate(_pendingRequestsProvider);
      },
      child: allAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_rounded, size: 48, color: AppColors.grey4),
                  SizedBox(height: 12),
                  Text('No requests yet', style: TextStyle(fontSize: 15, color: AppColors.grey2)),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: requests.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RequestCard(request: r, showActions: false),
            )).toList(),
          );
        },
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// ── Stats Grid ───────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final _AdminStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(label: 'Total', value: '${stats.total}', color: AppColors.dark, icon: Icons.inbox_rounded),
        _StatTile(label: 'Pending', value: '${stats.pending}', color: AppColors.warning, icon: Icons.hourglass_empty_rounded),
        _StatTile(label: 'Approved', value: '${stats.approved}', color: AppColors.success, icon: Icons.check_circle_rounded),
        _StatTile(label: 'Rejected', value: '${stats.rejected}', color: AppColors.error, icon: Icons.cancel_rounded),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatTile({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey2)),
          ],
        ),
      ),
    );
  }
}

// ── Request Card ─────────────────────────────────────────────

class _RequestCard extends ConsumerWidget {
  final CommunityRequestModel request;
  final bool showActions;
  const _RequestCard({required this.request, this.showActions = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = switch (request.status) {
      'approved' => AppColors.success,
      'rejected' => AppColors.error,
      'changes_requested' => AppColors.warning,
      _ => AppColors.warning,
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.group_add_rounded, color: context.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.communityName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
                      const SizedBox(height: 2),
                      Text(_typeLabel(request.communityType), style: const TextStyle(fontSize: 12, color: AppColors.grey2)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(request.status.replaceAll('_', ' ').toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                if (request.faculty != null) _infoRow('Faculty', request.faculty!),
                if (request.department != null) _infoRow('Department', request.department!),
                if (request.programme != null) _infoRow('Programme', request.programme!),
                if (request.level != null) _infoRow('Level', 'Level ${request.level}'),
                if (request.academicYear != null) _infoRow('Year', request.academicYear!),
                if (request.estimatedStudentCount != null) _infoRow('Est. Students', '${request.estimatedStudentCount}'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Purpose', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.grey2)),
                      const SizedBox(height: 4),
                      Text(request.purpose, style: const TextStyle(fontSize: 13, color: AppColors.dark, height: 1.5)),
                    ],
                  ),
                ),
                if (request.adminFeedback != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Admin Feedback', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.grey2)),
                        const SizedBox(height: 4),
                        Text(request.adminFeedback!, style: const TextStyle(fontSize: 13, color: AppColors.dark, height: 1.5)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(_timeAgo(request.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.grey3)),
              ],
            ),
          ),

          // Actions
          if (showActions && request.status == 'pending') ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleAction(context, ref, 'rejected'),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _handleAction(context, ref, 'approved'),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Approve'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey2))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dark))),
      ],
    ),
  );

  String _typeLabel(String type) => switch (type) {
    'class' => 'Class Community',
    'level' => 'Level Community',
    'department' => 'Department Community',
    'faculty' => 'Faculty Community',
    'club' => 'Club',
    'university' => 'University Community',
    _ => type,
  };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String status) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(status == 'approved' ? 'Approve Request?' : 'Reject Request?'),
        content: Text(status == 'approved'
            ? 'This will create the community and assign the requester as owner.'
            : 'The requester will be notified of the rejection.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(status == 'approved' ? 'Approve' : 'Reject',
                style: TextStyle(color: status == 'approved' ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final client = ref.read(supabaseProvider);
      final admin = client.auth.currentUser;
      if (admin == null) return;

      final repo = ref.read(leadershipRepositoryProvider);

      await repo.updateRequestStatus(
        requestId: request.id,
        status: status,
        reviewedBy: admin.id,
      );

      if (status == 'approved') {
        // Fetch full request data and create community
        final requestData = await client
            .from('community_requests')
            .select()
            .eq('id', request.id)
            .single();
        await repo.approveAndCreateCommunity(requestData, request.id);
      }

      ref.invalidate(_pendingRequestsProvider);
      ref.invalidate(_allRequestsProvider);
      ref.invalidate(_adminStatsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'approved' ? 'Community created successfully!' : 'Request rejected.'),
            backgroundColor: status == 'approved' ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
