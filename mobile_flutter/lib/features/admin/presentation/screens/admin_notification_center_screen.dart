import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/extensions/theme_extensions.dart';

final _adminNotificationsProvider = FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.read(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  final data = await client
      .from('notifications')
      .select()
      .filter('user_id', 'eq', user.id)
      .order('created_at', ascending: false)
      .limit(50) as List;

  return data
      .map((json) => NotificationModel.fromJson(json))
      .where((n) => n.type == 'admin_new_request' || n.type == 'community_approved' || n.type == 'community_rejected' || n.type == 'community_changes_requested' || n.type == 'verification_approved' || n.type == 'verification_rejected')
      .toList();
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
      .where((n) => ['admin_new_request', 'community_approved', 'community_rejected', 'community_changes_requested', 'verification_approved', 'verification_rejected'].contains(n['type']))
      .length;
});

class AdminNotificationCenterScreen extends ConsumerWidget {
  const AdminNotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(_adminNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              final client = ref.read(supabaseProvider);
              final user = client.auth.currentUser;
              if (user == null) return;
              await client.from('notifications').update({'is_read': true}).filter('user_id', 'eq', user.id);
              ref.invalidate(_adminNotificationsProvider);
              ref.invalidate(_adminUnreadNotificationsProvider);
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_adminNotificationsProvider);
          ref.invalidate(_adminUnreadNotificationsProvider);
        },
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(_adminNotificationsProvider)),
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 64, color: context.borderCol),
                    SizedBox(height: 12),
                    Text('No admin notifications', style: TextStyle(fontSize: 15, color: context.textSecondary, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('New community and verification requests will appear here', style: TextStyle(fontSize: 12, color: context.textDisabled)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return _AdminNotificationTile(
                  notification: n,
                  onTap: () async {
                    if (!n.isRead) {
                      final client = ref.read(supabaseProvider);
                      await client.from('notifications').update({'is_read': true}).filter('id', 'eq', n.id);
                      ref.invalidate(_adminNotificationsProvider);
                      ref.invalidate(_adminUnreadNotificationsProvider);
                    }
                    if (n.type == 'admin_new_request') {
                      context.push('/admin');
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AdminNotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _AdminNotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconData = _icon(notification.type);
    final iconColor = _iconColor(notification.type);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.1),
        child: Icon(iconData, color: iconColor, size: 22),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: notification.body != null
          ? Text(notification.body!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))
          : null,
      trailing: !notification.isRead
          ? Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
            )
          : null,
      onTap: onTap,
    );
  }

  IconData _icon(String type) => switch (type) {
    'admin_new_request' => Icons.group_add_rounded,
    'community_approved' => Icons.check_circle_rounded,
    'community_rejected' => Icons.cancel_rounded,
    'community_changes_requested' => Icons.feedback_rounded,
    'verification_approved' => Icons.verified_rounded,
    'verification_rejected' => Icons.gpp_bad_rounded,
    _ => Icons.notifications_rounded,
  };

  Color _iconColor(String type) => switch (type) {
    'admin_new_request' => const Color(0xFF8B5CF6),
    'community_approved' || 'verification_approved' => AppColors.success,
    'community_rejected' || 'verification_rejected' => AppColors.error,
    'community_changes_requested' => AppColors.warning,
    _ => AppColors.grey2,
  };
}
