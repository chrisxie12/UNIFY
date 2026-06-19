import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_provider.dart';
import '../../data/models/notification_model.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollCtrl = ScrollController();
  final List<NotificationModel> _items = [];
  String? _cursor;
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200 && _hasMore && !_loadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    final repo = ref.read(notificationRepositoryProvider);
    final userId = ref.read(currentAppUserProvider).valueOrNull?.id ?? '';
    final next = await repo.getNotifications(userId, cursor: _cursor);
    if (!mounted) return;
    setState(() {
      if (next.length < 20) _hasMore = false;
      if (next.isNotEmpty) _cursor = next.last.createdAt.toIso8601String();
      _items.addAll(next);
      _loadingMore = false;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _cursor = null;
      _hasMore = true;
    });
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentAppUserProvider).valueOrNull?.id ?? '';
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
                setState(() {
                  _items.clear();
                  _cursor = null;
                  _hasMore = true;
                });
                await _loadMore();
              },
              child: Text('Mark all read ($count)'),
            );
          }) ?? const SizedBox.shrink(),
        ],
      ),
      body: _items.isEmpty && !_loadingMore
          ? _emptyState()
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _items.length + (_loadingMore ? 1 : 0),
                separatorBuilder: (_, __) => Divider(height: 1, indent: 72, color: context.surfaceDivider),
                itemBuilder: (context, index) {
                  if (index >= _items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                    );

                  }
                  final notification = _items[index];
                  return _NotificationTile(
                    notification: notification,
                    onTap: () async {
                      if (!notification.isRead) {
                        final repo = ref.read(notificationRepositoryProvider);
                        await repo.markAsRead(notification.id);
                        ref.invalidate(unreadCountProvider);
                        ref.invalidate(unreadCountOnceProvider);
                        setState(() {
                          final idx = _items.indexWhere((n) => n.id == notification.id);
                          if (idx >= 0) _items[idx] = notification.copyWith(isRead: true);
                        });
                      }
                      _handleNavigation(context, notification);
                    },
                  );
                },
              ),
            ),
    );
  }

  void _handleNavigation(BuildContext context, NotificationModel notification) {
    final data = notification.data;
    final type = notification.type;

    if (type == 'admin_broadcast' || type == 'community_announcement') {
      context.push('/launch/announcements');
    } else if (type == 'new_message' && data != null) {
      final convId = data['conversation_id'];
      if (convId != null) context.push('/messages/chat/$convId');
    } else if (type == 'community_approval' || type == 'community_join_request') {
      final communityId = data?['community_id'];
      if (communityId != null) {
        context.push('/app/communities/$communityId');
      } else {
        context.push('/app/communities');
      }
    } else if (type == 'event_registration' || type == 'event_reminder' || type == 'event_checkin_confirmation') {
      final eventId = data?['event_id'];
      if (eventId != null) {
        context.push('/events/$eventId');
      } else {
        context.push('/app/events');
      }
    } else if (type == 'opportunity_deadline_reminder' || type == 'scholarship_alert') {
      context.push('/opportunities');
    } else if (type == 'academic_resource_upload') {
      context.push('/academic/resources');
    } else if (type == 'verification_approved') {
      context.push('/profile');
    } else if (type == 'role_assigned') {
      context.push('/reputation');
    } else if (type == 'marketplace_inquiry' || type == 'marketplace_sale') {
      context.push('/marketplace');
    } else {
      context.push('/profile');
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 64, color: context.textDisabled),
          const SizedBox(height: 12),
          Text('No notifications yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.textPrimary)),
          const SizedBox(height: 4),
          Text('We\'ll let you know when something happens', style: TextStyle(fontSize: 13, color: context.textSecondary)),
        ],
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
      case 'new_message': return Icons.chat_bubble;
      case 'community_announcement': return Icons.campaign;
      case 'community_join_request': return Icons.group_add_rounded;
      case 'community_approval': return Icons.check_circle;
      case 'marketplace_inquiry': return Icons.question_answer;
      case 'marketplace_sale': return Icons.sell;
      case 'event_registration': return Icons.event;
      case 'event_reminder': return Icons.alarm;
      case 'event_checkin_confirmation': return Icons.qr_code_scanner;
      case 'opportunity_deadline_reminder': return Icons.timer;
      case 'scholarship_alert': return Icons.school;
      case 'academic_resource_upload': return Icons.upload_file;
      case 'verification_approved': return Icons.verified;
      case 'role_assigned': return Icons.badge;
      case 'admin_broadcast': return Icons.campaign;
      default: return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: primary.withValues(alpha: 0.10),
        child: Icon(_icon(), color: primary, size: 22),
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
