import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_provider.dart';
import '../../data/models/notification_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentAppUserProvider).valueOrNull?.id ?? '';

    final notificationsAsync = ref.watch(notificationsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              final repo = ref.read(notificationRepositoryProvider);
              await repo.markAllAsRead(userId);
              ref.invalidate(notificationsProvider(userId));
              ref.invalidate(unreadCountProvider(userId));
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('No notifications yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[500])),
                  const SizedBox(height: 4),
                  Text('Stay tuned for updates', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(
                notification: notification,
                onTap: () async {
                  if (!notification.isRead) {
                    final repo = ref.read(notificationRepositoryProvider);
                    await repo.markAsRead(notification.id);
                    ref.invalidate(notificationsProvider(userId));
                    ref.invalidate(unreadCountProvider(userId));
                  }
                  if (notification.referenceType == 'community_request' && notification.referenceId != null) {
                    if (notification.type == 'admin_new_request') {
                      context.push('/admin');
                    } else {
                      context.push('/community-request');
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  IconData _icon() {
    switch (notification.type) {
      case 'community_approved': return Icons.check_circle;
      case 'community_rejected': return Icons.cancel;
      case 'community_changes_requested': return Icons.feedback_rounded;
      case 'admin_new_request': return Icons.group_add_rounded;
      case 'announcement_posted': return Icons.campaign;
      case 'discussion_reply': return Icons.reply;
      case 'resource_uploaded': return Icons.upload_file;
      case 'verification_approved': return Icons.verified;
      case 'verification_rejected': return Icons.gpp_bad;
      case 'moderator_action': return Icons.shield;
      case 'report_update': return Icons.flag;
      case 'community_invite': return Icons.group_add;
      case 'new_follower': return Icons.person_add;
      default: return Icons.notifications;
    }
  }

  Color _iconColor() {
    switch (notification.type) {
      case 'community_approved':
      case 'verification_approved':
        return AppColors.primary;
      case 'community_rejected':
      case 'verification_rejected':
        return Colors.red;
      case 'community_changes_requested':
        return const Color(0xFFF59E0B);
      case 'admin_new_request':
        return const Color(0xFF8B5CF6);
      case 'announcement_posted':
        return Colors.orange;
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _iconColor().withValues(alpha: 0.1),
        child: Icon(_icon(), color: _iconColor(), size: 22),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: notification.body != null ? Text(notification.body!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)) : null,
      trailing: !notification.isRead
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
