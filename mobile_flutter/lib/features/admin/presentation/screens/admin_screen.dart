import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../leadership/data/models/community_request_model.dart';
import '../../../leadership/data/models/announcement_request_model.dart';
import '../../../leadership/presentation/providers/leadership_provider.dart';
import '../../../verification/data/models/verification_request_model.dart';
import 'representative_detail_screen.dart';

// ── Admin Local Providers ────────────────────────────────────

final _allRequestsProvider = FutureProvider.autoDispose<List<CommunityRequestModel>>((ref) async {
  return ref.read(leadershipRepositoryProvider).getAllRequests();
});

final _pendingRequestsProvider = FutureProvider.autoDispose<List<CommunityRequestModel>>((ref) async {
  return ref.read(leadershipRepositoryProvider).getAllRequests(statuses: ['pending']);
});

final _allVerificationProvider = FutureProvider.autoDispose<List<VerificationRequestModel>>((ref) async {
  final client = ref.read(supabaseProvider);
  final data = await client.from('verification_requests').select('*, profiles!verification_requests_user_id_fkey(full_name, avatar_url, programme)').order('created_at', ascending: false);
  return (data as List).map((row) => VerificationRequestModel.fromJson(row as Map<String, dynamic>)).toList();
});

final _pendingVerificationProvider = FutureProvider.autoDispose<List<VerificationRequestModel>>((ref) async {
  final client = ref.read(supabaseProvider);
  final data = await client.from('verification_requests').select('*, profiles!verification_requests_user_id_fkey(full_name, avatar_url, programme)').eq('status', 'pending').order('created_at', ascending: false);
  return (data as List).map((row) => VerificationRequestModel.fromJson(row as Map<String, dynamic>)).toList();
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

final _verificationStatsProvider = FutureProvider.autoDispose<_AdminStats>((ref) async {
  final client = ref.read(supabaseProvider);
  final all = await client.from('verification_requests').select('status');
  final list = (all as List);
  return _AdminStats(
    list.length,
    list.where((r) => r['status'] == 'pending').length,
    list.where((r) => r['status'] == 'approved').length,
    list.where((r) => r['status'] == 'rejected').length,
  );
});

final _announcementStatsProvider = FutureProvider.autoDispose<_AdminStats>((ref) async {
  final all = await ref.read(leadershipRepositoryProvider).getAllAnnouncementRequests();
  return _AdminStats(
    all.length,
    all.where((r) => r.status == 'pending').length,
    all.where((r) => r.status == 'approved').length,
    all.where((r) => r.status == 'rejected').length,
  );
});

final _adminUnreadNotificationsProvider = FutureProvider.autoDispose<int>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.read(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return 0;

  final data = await client
      .from('notifications')
      .select()
      .filter('user_id', 'eq', user.id)
      .order('created_at', ascending: false) as List;

  return data
      .where((n) => n['is_read'] == false)
      .where((n) => ['admin_new_request', 'community_changes_requested'].contains(n['type']))
      .length;
});

// ── Screen ───────────────────────────────────────────────────

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(_adminUnreadNotificationsProvider);
    final unreadCount = unreadAsync.valueOrNull ?? 0;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/admin/notifications'),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Communities'),
              Tab(text: 'Verification'),
              Tab(text: 'Announcements'),
              Tab(text: 'History'),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: AppColors.grey3,
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        body: TabBarView(
          children: [
            _PendingRequestsTab(),
            _VerificationTab(),
            _AnnouncementRequestsTab(),
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
              Text('Pending Reviews', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
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
            Text(label, style: TextStyle(fontSize: 10, color: context.textSecondary)),
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
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => RepresentativeDetailScreen(userId: request.requesterId),
                  )),
                  child: Row(
                    children: [
                      Icon(Icons.person_search_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Text('View Representative', style: TextStyle(fontSize: 12, color: context.primary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Actions
          if (showActions && request.status == 'pending') ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleRequestInfo(context, ref),
                          icon: const Icon(Icons.feedback_rounded, size: 16),
                          label: const Text('Request Info'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            side: const BorderSide(color: AppColors.warning),
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
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
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

  Future<void> _handleRequestInfo(BuildContext context, WidgetRef ref) async {
    final feedbackCtrl = TextEditingController();
    final feedback = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Request More Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Provide feedback on what information is needed:', style: TextStyle(fontSize: 13, color: AppColors.grey1)),
            const SizedBox(height: 12),
            TextField(
              controller: feedbackCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. Please provide evidence of your leadership position',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, feedbackCtrl.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );

    if (feedback == null || feedback.isEmpty) return;

    try {
      final client = ref.read(supabaseProvider);
      final admin = client.auth.currentUser;
      if (admin == null) return;

      final repo = ref.read(leadershipRepositoryProvider);
      await repo.updateRequestStatus(
        requestId: request.id,
        status: 'changes_requested',
        adminFeedback: feedback,
        reviewedBy: admin.id,
      );

      try {
        await client.rpc('create_notification', params: {
          'p_user_id': request.requesterId,
          'p_type': 'community_changes_requested',
          'p_title': 'More Information Needed',
          'p_message': 'Admin requested changes for "${request.communityName}": $feedback',
          'p_ref_id': request.id,
          'p_ref_type': 'community_request',
        });
      } catch (_) {}

      ref.invalidate(_pendingRequestsProvider);
      ref.invalidate(_allRequestsProvider);
      ref.invalidate(_adminStatsProvider);
      ref.invalidate(_adminUnreadNotificationsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback sent to requester.'),
            backgroundColor: AppColors.warning,
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
        final requestData = await client
            .from('community_requests')
            .select()
            .eq('id', request.id)
            .single();
        await repo.approveAndCreateCommunity(requestData, request.id);
        try {
          await client.rpc('create_notification', params: {
            'p_user_id': request.requesterId,
            'p_type': 'community_approved',
            'p_title': 'Community Approved',
            'p_message': 'Your request for "${request.communityName}" has been approved.',
            'p_ref_id': request.id,
            'p_ref_type': 'community_request',
          });
        } catch (_) {}
      } else if (status == 'rejected') {
        try {
          await client.rpc('create_notification', params: {
            'p_user_id': request.requesterId,
            'p_type': 'community_rejected',
            'p_title': 'Community Request Rejected',
            'p_message': 'Your request for "${request.communityName}" was not approved.',
            'p_ref_id': request.id,
            'p_ref_type': 'community_request',
          });
        } catch (_) {}
      }

      ref.invalidate(_pendingRequestsProvider);
      ref.invalidate(_allRequestsProvider);
      ref.invalidate(_adminStatsProvider);
      ref.invalidate(_adminUnreadNotificationsProvider);

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

// ═══════════════════════════════════════════════════════════════
// ANNOUNCEMENT REQUESTS TAB
// ═══════════════════════════════════════════════════════════════

class _AnnouncementRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingAnnouncementRequestsProvider);
    final statsAsync = ref.watch(_announcementStatsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(pendingAnnouncementRequestsProvider);
        ref.invalidate(allAnnouncementRequestsProvider);
        ref.invalidate(_announcementStatsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          statsAsync.when(
            data: (stats) => _StatsGrid(stats: stats),
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox(height: 80),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.campaign_rounded, size: 16, color: context.primary),
              const SizedBox(width: 6),
              Text('Pending Announcements', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
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
                        Text('No pending announcements.', style: TextStyle(fontSize: 13, color: AppColors.grey3)),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: requests.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AnnouncementRequestCard(request: r),
                )).toList(),
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

class _AnnouncementRequestCard extends ConsumerWidget {
  final AnnouncementRequestModel request;
  const _AnnouncementRequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catIcon = switch (request.category) {
      'lecture' => Icons.menu_book_rounded,
      'quiz' => Icons.quiz_rounded,
      'assignment' => Icons.assignment_rounded,
      'project' => Icons.build_rounded,
      'seminar' => Icons.groups_rounded,
      'workshop' => Icons.handyman_rounded,
      'exam' => Icons.fact_check_rounded,
      'emergency' => Icons.warning_amber_rounded,
      _ => Icons.campaign_rounded,
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(catIcon, color: const Color(0xFF8B5CF6), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
                      const SizedBox(height: 2),
                      Text(request.category[0].toUpperCase() + request.category.substring(1), style: const TextStyle(fontSize: 12, color: AppColors.grey2)),
                    ],
                  ),
                ),
                if (request.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('URGENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.error)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (request.targetAudience != null)
                  _infoRow('Audience', request.targetAudience!),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(request.body, style: const TextStyle(fontSize: 13, color: AppColors.dark, height: 1.5)),
                ),
                const SizedBox(height: 12),
                Text(_timeAgo(request.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.grey3)),
              ],
            ),
          ),
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
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey2))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dark))),
      ],
    ),
  );

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
        title: Text(status == 'approved' ? 'Approve Announcement?' : 'Reject Announcement?'),
        content: Text(status == 'approved'
            ? 'This will publish the announcement to the feed.'
            : 'The requester will be notified.'),
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

      await repo.updateAnnouncementRequestStatus(
        requestId: request.id,
        status: status,
        reviewedBy: admin.id,
      );

      ref.invalidate(pendingAnnouncementRequestsProvider);
      ref.invalidate(allAnnouncementRequestsProvider);
      ref.invalidate(_announcementStatsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'approved' ? 'Announcement published!' : 'Announcement rejected.'),
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

// ═══════════════════════════════════════════════════════════════
// VERIFICATION MODERATION TAB
// ═══════════════════════════════════════════════════════════════

class _VerificationTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(_pendingVerificationProvider);
    final statsAsync = ref.watch(_verificationStatsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_pendingVerificationProvider);
        ref.invalidate(_allVerificationProvider);
        ref.invalidate(_verificationStatsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          statsAsync.when(
            data: (stats) => _StatsGrid(stats: stats),
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox(height: 80),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.verified_user_rounded, size: 16, color: context.primary),
              const SizedBox(width: 6),
              Text('Pending Verifications', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
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
                        Text('No pending verifications', style: TextStyle(fontSize: 15, color: AppColors.grey2, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: requests.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _VerificationCard(request: r),
                )).toList(),
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

class _VerificationCard extends ConsumerWidget {
  final VerificationRequestModel request;
  const _VerificationCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
                    color: context.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.verified_user_rounded, color: context.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.position, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
                      const SizedBox(height: 2),
                      if (request.classRepresented != null)
                        Text(request.classRepresented!, style: const TextStyle(fontSize: 12, color: AppColors.grey2)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                if (request.department != null)
                  _infoRow('Department', request.department!),
                _infoRow('Academic Year', request.academicYear ?? '—'),
                if (request.evidenceUrl != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _viewEvidence(context, request.evidenceUrl!),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.visibility_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('View Evidence', style: TextStyle(fontSize: 13, color: context.primary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text('Submitted ${_timeAgo(request.createdAt)}', style: const TextStyle(fontSize: 11, color: AppColors.grey3)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleVerification(context, ref, 'rejected'),
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
                    onPressed: () => _handleVerification(context, ref, 'approved'),
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _viewEvidence(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Evidence'),
        content: SizedBox(
          width: double.maxFinite,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(url, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Text('Could not load image')),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _handleVerification(BuildContext context, WidgetRef ref, String status) async {
    final notesCtrl = TextEditingController();
    final roles = await ref.read(leadershipRepositoryProvider).getAllRoles();
    String? selectedRoleId;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(status == 'approved' ? 'Approve Verification?' : 'Reject Verification?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status == 'approved'
                  ? 'This will mark the user as a verified leader.'
                  : 'The user will be notified of the rejection.'),
              if (status == 'approved' && roles.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Assign Leadership Role', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedRoleId,
                  decoration: InputDecoration(
                    hintText: 'Select role',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: roles.map((r) => DropdownMenuItem(
                    value: r.id,
                    child: Text(r.title, style: const TextStyle(fontSize: 13)),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => selectedRoleId = v),
                ),
                const SizedBox(height: 8),
                Text('Default: ${request.position}', style: const TextStyle(fontSize: 11, color: AppColors.grey3, fontStyle: FontStyle.italic)),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(
                  hintText: 'Admin notes (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, {'confirmed': true, 'roleId': selectedRoleId}),
              child: Text(status == 'approved' ? 'Approve' : 'Reject',
                  style: TextStyle(color: status == 'approved' ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
    if (result == null || result['confirmed'] != true) return;

    try {
      final client = ref.read(supabaseProvider);
      final admin = client.auth.currentUser;
      if (admin == null) return;

      await client.from('verification_requests').update({
        'status': status,
        'admin_notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
        'reviewed_by': admin.id,
        'reviewed_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', request.id);

      if (status == 'approved') {
        final selectedRole = result['roleId'] as String?;
        final roleTitle = selectedRole != null
            ? roles.firstWhere((r) => r.id == selectedRole, orElse: () => roles.first).title
            : request.position;

        await client.from('profiles').update({
          'is_verified_leader': true,
          'leadership_role': roleTitle,
          'represented_class': request.classRepresented,
          'represented_department': request.department,
          'verification_status': 'verified',
        }).eq('id', request.userId);

        if (selectedRole != null) {
          final userProfile = await client.from('profiles').select('university_id').eq('id', request.userId).single();
          await client.from('user_leadership').insert({
            'user_id': request.userId,
            'role_id': selectedRole,
            'university_id': userProfile['university_id'],
            'department': request.department,
            'academic_year': request.academicYear,
            'verified_by': admin.id,
            'verified_at': DateTime.now().toUtc().toIso8601String(),
          });
        }
      } else {
        await client.from('profiles').update({
          'verification_status': 'rejected',
        }).eq('id', request.userId);
      }

      await client.from('verification_log').insert({
        'target_user_id': request.userId,
        'action': status == 'approved' ? 'approved' : 'rejected',
        'performed_by': admin.id,
        'notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      });

      try {
        await client.rpc('create_notification', params: {
          'p_user_id': request.userId,
          'p_type': status == 'approved' ? 'verification_approved' : 'verification_rejected',
          'p_title': status == 'approved' ? 'Verification Approved' : 'Verification Rejected',
          'p_message': status == 'approved'
              ? 'You have been verified as a ${request.position}.'
              : 'Your verification request as ${request.position} was not approved.',
          'p_ref_id': request.id,
          'p_ref_type': 'verification_request',
        });
      } catch (_) {}

      ref.invalidate(_pendingVerificationProvider);
      ref.invalidate(_allVerificationProvider);
      ref.invalidate(_verificationStatsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'approved' ? 'Leader verified!' : 'Request rejected.'),
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
