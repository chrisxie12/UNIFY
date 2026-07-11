import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_provider.dart';
import '../../data/models/notification_model.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/app_loading_widget.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentAppUserProvider).valueOrNull?.id ?? '';
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadAsync = ref.watch(unreadCountOnceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          unreadAsync.whenOrNull(data: (count) {
            if (count == 0) return null;
            return TextButton(
              onPressed: () async {
                final repo = ref.read(notificationRepositoryProvider);
                await repo.markAllAsRead(userId);
                ref.invalidate(unreadCountProvider);
                ref.invalidate(unreadCountOnceProvider);
                ref.invalidate(notificationsProvider);
              },
              child: Text('Mark all read ($count)'),
            );
          }) ?? const SizedBox.shrink(),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const AppLoadingWidget.list(itemCount: 5),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: context.textDisabled),
              const SizedBox(height: 12),
              Text('Failed to load notifications', style: TextStyle(color: context.textSecondary)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(notificationsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return _emptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => Divider(height: 1, indent: 72, color: context.surfaceDivider),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () async {
                    if (!notification.isRead) {
                      final repo = ref.read(notificationRepositoryProvider);
                      await repo.markAsRead(notification.id);
                      ref.invalidate(unreadCountProvider);
                      ref.invalidate(unreadCountOnceProvider);
                    }
                    if (context.mounted) {
                      _handleNavigation(context, notification);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleNavigation(BuildContext context, NotificationModel notification) {
    final data = notification.data;
    final type = notification.type;

    if (type == 'admin_broadcast' || type == 'community_announcement' || type == 'announcement_posted') {
      context.push('/app/feed');
    } else if (type == 'new_message' && data != null) {
      final convId = data['conversation_id'];
      if (convId != null) context.push('/messaging/chat/$convId');
    } else if (type == 'community_approval' ||
               type == 'community_approved' ||
               type == 'community_join_request' ||
               type == 'community_changes_requested') {
      final communityId = data?['community_id'];
      if (communityId != null) {
        context.push('/community/$communityId');
      } else {
        context.push('/app/communities');
      }
    } else if (type == 'community_rejected') {
      context.push('/app/communities');
    } else if (type == 'event_registration' ||
               type == 'event_reminder' ||
               type == 'event_checkin_confirmation' ||
               type == 'event_approved' ||
               type == 'event_rejected') {
      final eventId = data?['event_id'];
      if (eventId != null) {
        context.push('/event/$eventId');
      } else {
        context.push('/app/events');
      }
    } else if (type == 'announcement_approved') {
      context.push('/app/feed');
    } else if (type == 'announcement_rejected') {
      context.push('/app/profile');
    } else if (type == 'admin_removed') {
      context.push('/app/profile');
    } else if (type == 'academic_resource_upload') {
      context.push('/academic/resources');
    } else if (type == 'verification_approved' || type == 'verification_rejected') {
      context.push('/app/profile');
    } else if (type == 'role_assigned') {
      context.push('/reputation');
    } else if (type == 'admin_request') {
      context.push('/admin');
    } else if (type == 'leadership_request_submitted' ||
               type == 'leadership_rejected') {
      context.push('/app/profile');
    } else if (type == 'leadership_approved') {
      context.push('/reputation');
    } else {
      context.push('/app/profile');
    }
  }

  Widget _emptyState(BuildContext context) {
    return const AppEmptyWidget(
      icon: Icons.notifications_none_rounded,
      title: 'No notifications yet',
      subtitle: 'We\'ll let you know when something happens',
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  IconData _icon() {
    switch (notification.type) {
      case 'new_message':                   return Icons.chat_bubble;
      case 'community_announcement':        return Icons.campaign;
      case 'announcement_posted':           return Icons.article_rounded;
      case 'community_join_request':        return Icons.group_add_rounded;
      case 'community_approval':
      case 'community_approved':            return Icons.check_circle;
      case 'community_rejected':            return Icons.cancel_rounded;
      case 'community_changes_requested':   return Icons.edit_note_rounded;
      case 'marketplace_inquiry':           return Icons.question_answer;
      case 'marketplace_sale':              return Icons.sell;
      case 'event_registration':            return Icons.event;
      case 'event_reminder':                return Icons.alarm;
      case 'event_checkin_confirmation':    return Icons.qr_code_scanner;
      case 'opportunity_deadline_reminder': return Icons.timer;
      case 'scholarship_alert':             return Icons.school;
      case 'academic_resource_upload':      return Icons.upload_file;
      case 'verification_approved':         return Icons.verified;
      case 'verification_rejected':         return Icons.gpp_bad_rounded;
      case 'role_assigned':                 return Icons.military_tech_rounded;
      case 'admin_broadcast':               return Icons.campaign;
      case 'admin_request':                 return Icons.admin_panel_settings_rounded;
      case 'leadership_request_submitted':  return Icons.star_outline_rounded;
      case 'leadership_approved':           return Icons.star_rounded;
      case 'leadership_rejected':           return Icons.star_border_rounded;
      default:                              return Icons.notifications;
    }
  }

  Color? _iconColor(BuildContext context) {
    switch (notification.type) {
      case 'leadership_request_submitted':
      case 'leadership_approved':
      case 'role_assigned':
        return Colors.amber;
      case 'leadership_rejected':
        return Colors.grey;
      default:
        return null; // falls back to primary
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;
    final iconColor = _iconColor(context) ?? primary;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.10),
        child: Icon(_icon(), color: iconColor, size: 22),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
          fontSize: 14,
          color: context.textPrimary,
        ),
      ),
      subtitle: notification.body != null
          ? Text(
              notification.body!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            )
          : null,
      trailing: !notification.isRead
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
