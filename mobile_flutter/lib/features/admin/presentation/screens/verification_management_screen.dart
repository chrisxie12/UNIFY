import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';

class VerificationManagementScreen extends ConsumerWidget {
  const VerificationManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verification Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'All'),
              Tab(text: 'Badges'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const _VerificationList(status: 'pending'),
            const _VerificationList(),
            _BadgeManagement(),
          ],
        ),
      ),
    );
  }
}

class _VerificationList extends ConsumerWidget {
  final String? status;
  const _VerificationList({this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = status == 'pending'
        ? pendingVerificationRequestsProvider
        : adminVerificationRequestsProvider;
    final asyncData = ref.watch(provider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(provider),
      child: asyncData.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user_rounded, size: 48, color: context.borderCol),
                  SizedBox(height: 12),
                  Text('No verification requests', style: TextStyle(fontSize: 16, color: context.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (_, i) => _VerificationCard(request: requests[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _VerificationCard extends ConsumerWidget {
  final Map<String, dynamic> request;
  const _VerificationCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = request['profiles'] as Map<String, dynamic>?;
    final reqStatus = request['status'] as String? ?? 'pending';

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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: context.primary.withValues(alpha: 0.1),
                  backgroundImage: profile?['avatar_url'] != null
                      ? NetworkImage(profile!['avatar_url'] as String) : null,
                  child: profile?['avatar_url'] == null
                      ? Icon(Icons.person_rounded, color: context.primary) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile?['full_name'] as String? ?? 'Unknown', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                      Text(profile?['programme'] as String? ?? '', style: const TextStyle(fontSize: 12, color: context.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge(reqStatus),
              ],
            ),
          ),
          if (request['evidence_url'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: context.bg, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.link_rounded, size: 16, color: context.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(request['evidence_url'] as String, style: TextStyle(fontSize: 12, color: context.primary), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(timeAgo(DateTime.parse(request['created_at'] as String)), style: const TextStyle(fontSize: 11, color: context.textDisabled)),
          ),
          if (reqStatus == 'pending')
            Container(
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: context.borderCol))),
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
    final notesCtrl = TextEditingController();

    if (status == 'approved') {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Approve Verification?'),
          content: TextField(
            controller: notesCtrl,
            decoration: InputDecoration(
              hintText: 'Admin notes (optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Approve'),
            ),
          ],
        ),
      );
      if (result != true) return;
    }

    final success = status == 'approved'
        ? await repo.approveVerification(request['id'] as String, userId, notes: notesCtrl.text.trim())
        : await repo.rejectVerification(request['id'] as String, userId, notes: notesCtrl.text.trim());

    ref.invalidate(pendingVerificationRequestsProvider);
    ref.invalidate(adminVerificationRequestsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Verification $status' : 'Failed to update'),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _BadgeManagement extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderCol),
          ),
          child: Column(
            children: [
              Icon(Icons.workspace_premium_rounded, size: 48, color: context.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              const Text('Badge Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary)),
              const SizedBox(height: 4),
              const Text('Assign and revoke leadership badges', style: TextStyle(fontSize: 13, color: context.textSecondary)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Badge management coming soon'), behavior: SnackBarBehavior.floating),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Assign Badge'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
