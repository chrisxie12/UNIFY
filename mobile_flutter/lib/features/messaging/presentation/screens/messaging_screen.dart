import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../providers/messaging_provider.dart';
import '../../data/models/conversation_model.dart';

class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _cancelSearch() => setState(() {
        _isSearching = false;
        _searchQuery = '';
        _searchController.clear();
      });

  void _openFab() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderCol,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: context.primary.withValues(alpha: 0.12),
                child: Icon(Icons.person_add_rounded, color: context.primary),
              ),
              title: Text(
                'New Message',
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Start a direct conversation',
                style: TextStyle(color: context.textSecondary, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/messaging/search');
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: context.primary.withValues(alpha: 0.12),
                child: Icon(Icons.group_add_rounded, color: context.primary),
              ),
              title: Text(
                'New Group',
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Create a group conversation',
                style: TextStyle(color: context.textSecondary, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/messaging/create-group');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showConversationOptions(
    ConversationModel conversation,
    bool isPinned,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderCol,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                conversation.title ?? 'Conversation',
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Divider(height: 1, color: context.borderCol),
            ListTile(
              leading: Icon(
                isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                color: context.primary,
              ),
              title: Text(
                isPinned ? 'Unpin' : 'Pin',
                style: TextStyle(color: context.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(pinnedConversationsProvider.notifier)
                    .toggle(conversation.id);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.volume_off_rounded,
                color: context.textSecondary,
              ),
              title: Text(
                'Mute',
                style: TextStyle(color: context.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Mute ${conversation.id} — not yet implemented');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: context.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: context.error),
              ),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Delete ${conversation.id} — not yet implemented');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(messageRequestsProvider);
    final requestsCount = requestsAsync.asData?.value.length ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: context.appBarBg,
            elevation: 0,
            scrolledUnderElevation: 1,
            surfaceTintColor: Colors.transparent,
            titleSpacing: _isSearching ? 16 : NavigationToolbar.kMiddleSpacing,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(color: context.textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search conversations…',
                      hintStyle: TextStyle(
                        color: context.textSecondary,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) =>
                        setState(() => _searchQuery = v.trim()),
                  )
                : Text(
                    'Messages',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
            actions: [
              if (_isSearching)
                TextButton(
                  onPressed: _cancelSearch,
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: context.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else ...[
                IconButton(
                  icon: Icon(Icons.search_rounded, color: context.textPrimary),
                  onPressed: _startSearch,
                  tooltip: 'Search',
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.person_add_alt_1_rounded,
                        color: context.textPrimary,
                      ),
                      onPressed: () => context.push('/messaging/requests'),
                      tooltip: 'Message requests',
                    ),
                    if (requestsCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IgnorePointer(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: context.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.appBarBg,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                requestsCount > 9
                                    ? '9+'
                                    : requestsCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
              ],
            ],
          ),
          _ConversationsSliver(
            searchQuery: _searchQuery,
            onShowOptions: _showConversationOptions,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openFab,
        backgroundColor: context.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        tooltip: 'New conversation',
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }
}

// ── Conversations Sliver ──────────────────────────────────────────────────────

class _ConversationsSliver extends ConsumerWidget {
  const _ConversationsSliver({
    required this.searchQuery,
    required this.onShowOptions,
  });

  final String searchQuery;
  final void Function(ConversationModel conv, bool isPinned) onShowOptions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final pinnedIds = ref.watch(pinnedConversationsProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return conversationsAsync.when(
      loading: () => const _SkeletonSliver(),
      error: (e, _) => SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: context.error),
              const SizedBox(height: 12),
              Text(
                'Failed to load conversations',
                style: TextStyle(color: context.textSecondary),
              ),
            ],
          ),
        ),
      ),
      data: (conversations) {
        final filtered = searchQuery.isEmpty
            ? conversations
            : conversations
                .where((c) =>
                    (c.title ?? '')
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    (c.lastMessageContent ?? '')
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                .toList();

        if (filtered.isEmpty) {
          return SliverFillRemaining(
            child: _EmptyState(isSearching: searchQuery.isNotEmpty),
          );
        }

        final pinned =
            filtered.where((c) => pinnedIds.contains(c.id)).toList();
        final unpinned =
            filtered.where((c) => !pinnedIds.contains(c.id)).toList();

        return SliverList(
          delegate: SliverChildListDelegate([
            if (pinned.isNotEmpty) ...[
              _SectionHeader(
                label: 'Pinned',
                icon: Icons.push_pin_rounded,
                color: context.primary,
              ),
              for (final conv in pinned)
                _SwipeableTile(
                  key: ValueKey('pinned_${conv.id}'),
                  conversation: conv,
                  isPinned: true,
                  currentUserId: currentUserId,
                  onShowOptions: onShowOptions,
                ),
              _SectionHeader(
                label: 'All Messages',
                icon: Icons.chat_bubble_outline_rounded,
                color: context.textSecondary,
              ),
            ],
            for (final conv in unpinned)
              _SwipeableTile(
                key: ValueKey('conv_${conv.id}'),
                conversation: conv,
                isPinned: false,
                currentUserId: currentUserId,
                onShowOptions: onShowOptions,
              ),
            const SizedBox(height: 80),
          ]),
        );
      },
    );
  }
}

// ── Swipeable Tile ────────────────────────────────────────────────────────────

class _SwipeableTile extends ConsumerWidget {
  const _SwipeableTile({
    super.key,
    required this.conversation,
    required this.isPinned,
    required this.currentUserId,
    required this.onShowOptions,
  });

  final ConversationModel conversation;
  final bool isPinned;
  final String? currentUserId;
  final void Function(ConversationModel, bool) onShowOptions;

  void _navigate(BuildContext context) {
    final type = conversation.type;
    if (type == 'channel' || type == 'announcement') {
      context.push('/messaging/channel-view/${conversation.id}');
    } else {
      context.push('/messaging/chat/${conversation.id}');
    }
  }

  ConversationParticipant? get _otherParticipant {
    try {
      return conversation.participants.firstWhere(
        (p) => !p.isCurrentUser,
      );
    } catch (_) {
      return conversation.participants.isNotEmpty
          ? conversation.participants.first
          : null;
    }
  }

  bool get _isDirect => conversation.type == 'direct';
  bool get _isChannel =>
      conversation.type == 'channel' || conversation.type == 'announcement';

  String get _displayName {
    if (_isDirect) {
      return _otherParticipant?.displayName ?? conversation.title ?? 'Unknown';
    }
    if (_isChannel) {
      return '#${conversation.title ?? ''}';
    }
    return conversation.title ?? 'Group';
  }

  String get _subtitleText {
    if (_isDirect) {
      return conversation.lastMessageContent ?? '';
    }
    final sender = conversation.lastMessageSenderName;
    final content = conversation.lastMessageContent ?? '';
    return sender != null && sender.isNotEmpty
        ? '$sender: $content'
        : content;
  }

  bool get _isMuted {
    if (currentUserId == null) return false;
    try {
      final me = conversation.participants.firstWhere(
        (p) => p.userId == currentUserId,
      );
      return me.isMuted;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final timeStr = _formatTime(conversation.lastMessageAt, now);
    final isUnread = conversation.unreadCount > 0;
    final muted = _isMuted;
    final name = _displayName;
    final subtitle = _subtitleText;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color = _avatarColor(conversation.id);

    return Dismissible(
      key: ValueKey('dismiss_${conversation.id}'),
      background: _SwipeBg(
        alignment: Alignment.centerRight,
        color: context.error,
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
        padding: const EdgeInsets.only(right: 24),
      ),
      secondaryBackground: _SwipeBg(
        alignment: Alignment.centerLeft,
        color: context.primary,
        icon: isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
        label: isPinned ? 'Unpin' : 'Pin',
        padding: const EdgeInsets.only(left: 24),
      ),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          debugPrint('Delete ${conversation.id} — not yet implemented');
        } else {
          ref
              .read(pinnedConversationsProvider.notifier)
              .toggle(conversation.id);
        }
        return false;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigate(context),
              onLongPress: () => onShowOptions(conversation, isPinned),
              child: SizedBox(
                height: 72,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title + subtitle
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (muted)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.volume_off_rounded,
                                      size: 14,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                if (isPinned)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.push_pin_rounded,
                                      size: 14,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: context.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Time + unread badge
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isUnread)
                            _UnreadBadge(
                              count: conversation.unreadCount,
                              muted: muted,
                              primary: context.primary,
                            )
                          else
                            const SizedBox(height: 18),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 76,
            endIndent: 0,
            color: context.borderCol.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

// ── Swipe Background ──────────────────────────────────────────────────────────

class _SwipeBg extends StatelessWidget {
  const _SwipeBg({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
    required this.padding,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Unread Badge ──────────────────────────────────────────────────────────────

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({
    required this.count,
    required this.muted,
    required this.primary,
  });

  final int count;
  final bool muted;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : count.toString();
    final bg = muted ? context.textSecondary.withValues(alpha: 0.4) : primary;
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isSearching ? '\u{1F50D}' : '\u{1F4AC}',
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No results found' : 'No conversations yet',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isSearching
                  ? 'Try a different search term'
                  : 'Tap the pencil icon to start a conversation',
              style: TextStyle(color: context.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading Skeleton ──────────────────────────────────────────────────────────

class _SkeletonSliver extends StatelessWidget {
  const _SkeletonSliver();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final base = isDark ? const Color(0xFF2A2A3A) : const Color(0xFFE0E0E0);
    final highlight =
        isDark ? const Color(0xFF3A3A4A) : const Color(0xFFF5F5F5);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, __) => Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: const _SkeletonTile(),
        ),
        childCount: 5,
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.cardBg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 180,
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 10,
              width: 36,
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatTime(DateTime? dt, DateTime now) {
  if (dt == null) return '';
  final local = dt.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final msgDay = DateTime(local.year, local.month, local.day);
  final diff = today.difference(msgDay).inDays;
  if (diff == 0) {
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  } else if (diff < 7) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[local.weekday - 1];
  } else {
    final d = local.day.toString().padLeft(2, '0');
    final mo = local.month.toString().padLeft(2, '0');
    return '$d/$mo';
  }
}

Color _avatarColor(String id) {
  const palette = [
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFFDC2626),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFF0891B2),
    Color(0xFFDB2777),
    Color(0xFF4F46E5),
  ];
  final hash = id.codeUnits.fold(0, (a, b) => a + b);
  return palette[hash % palette.length];
}
