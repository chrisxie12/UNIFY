import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../providers/messaging_provider.dart';
import '../../data/models/message_model.dart';
import '../../data/models/conversation_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input_bar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  // Selection mode
  final Set<String> _selectedIds = {};
  bool get _inSelectionMode => _selectedIds.isNotEmpty;

  // Track message count for auto-scroll
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    // Wire the provider so messagesProvider reads from this conversation
    Future.microtask(() {
      ref.read(selectedConversationProvider.notifier).state = widget.conversationId;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleSelection(String messageId) {
    setState(() {
      if (_selectedIds.contains(messageId)) {
        _selectedIds.remove(messageId);
      } else {
        _selectedIds.add(messageId);
      }
    });
    HapticFeedback.selectionClick();
  }

  void _clearSelection() => setState(() => _selectedIds.clear());

  void _copySelectedMessages(List<MessageModel> messages) {
    final selected = messages.where((m) => _selectedIds.contains(m.id));
    final text = selected.map((m) => m.content ?? '').join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 2)),
    );
    _clearSelection();
  }

  Future<void> _markAsReadIfNeeded(List<MessageModel> messages) async {
    if (messages.isEmpty) return;
    final lastId = messages.first.id; // list is reversed (first = newest)
    await ref.read(messagingProvider.notifier).markAsRead(widget.conversationId, lastId);
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final replyTo = ref.watch(replyToMessageProvider(widget.conversationId));
    final typingAsync = ref.watch(typingProvider(widget.conversationId));
    final typingCount = typingAsync.valueOrNull ?? 0;

    // Auto-scroll and mark-as-read when new messages arrive
    ref.listen(messagesProvider, (_, next) {
      next.whenData((msgs) {
        if (msgs.length > _lastMessageCount) {
          _lastMessageCount = msgs.length;
          _scrollToBottom();
          _markAsReadIfNeeded(msgs);
        }
      });
    });

    return Scaffold(
      backgroundColor: context.bg,
      appBar: _inSelectionMode
          ? _buildSelectionAppBar(context, messagesAsync.valueOrNull ?? [])
          : _buildChatAppBar(context, typingCount),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error: $e', style: TextStyle(color: context.textSecondary)),
              ),
              data: (messages) {
                // Mark as read on first load
                if (messages.isNotEmpty && _lastMessageCount == 0) {
                  _lastMessageCount = messages.length;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _markAsReadIfNeeded(messages);
                  });
                }

                if (messages.isEmpty) {
                  return _EmptyState();
                }

                return GestureDetector(
                  onTap: _inSelectionMode ? _clearSelection : null,
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true, // newest at bottom
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    itemCount: messages.length,
                    itemBuilder: (ctx, i) {
                      final msg = messages[i];
                      // i=0 is newest. Previous in time = messages[i+1].
                      final prevMsg = i + 1 < messages.length ? messages[i + 1] : null;
                      final nextMsg = i > 0 ? messages[i - 1] : null;

                      final bool isOwn = msg.senderId == currentUserId;

                      // Group logic: same sender, same day
                      final bool sameGroupAsPrev = prevMsg != null &&
                          prevMsg.senderId == msg.senderId &&
                          !prevMsg.isSystemMessage &&
                          !msg.isSystemMessage &&
                          prevMsg.createdAt.year == msg.createdAt.year &&
                          prevMsg.createdAt.month == msg.createdAt.month &&
                          prevMsg.createdAt.day == msg.createdAt.day;

                      final bool sameGroupAsNext = nextMsg != null &&
                          nextMsg.senderId == msg.senderId &&
                          !nextMsg.isSystemMessage &&
                          !msg.isSystemMessage &&
                          nextMsg.createdAt.year == msg.createdAt.year &&
                          nextMsg.createdAt.month == msg.createdAt.month &&
                          nextMsg.createdAt.day == msg.createdAt.day;

                      // isFirstInGroup = no previous message in same group
                      // In reversed list: "previous in time" = messages[i+1]
                      final bool isFirstInGroup = !sameGroupAsPrev;
                      // isLastInGroup = no next message in same group
                      // In reversed list: "next in time" = messages[i-1]
                      final bool isLastInGroup = !sameGroupAsNext;

                      // Date separator: show when day changes between this and next (older) msg
                      final bool showDateSeparator = prevMsg == null ||
                          prevMsg.createdAt.year != msg.createdAt.year ||
                          prevMsg.createdAt.month != msg.createdAt.month ||
                          prevMsg.createdAt.day != msg.createdAt.day;

                      return Column(
                        children: [
                          // Date separator appears BELOW older group (reversed list)
                          if (showDateSeparator)
                            _DateSeparator(date: msg.createdAt),

                          _SwipeableMessage(
                            key: ValueKey(msg.id),
                            onSwipeActivate: () {
                              ref
                                  .read(replyToMessageProvider(widget.conversationId).notifier)
                                  .state = msg;
                              HapticFeedback.mediumImpact();
                            },
                            child: MessageBubble(
                              message: msg,
                              isOwn: isOwn,
                              isFirstInGroup: isFirstInGroup,
                              isLastInGroup: isLastInGroup,
                              isSelected: _selectedIds.contains(msg.id),
                              onTap: _inSelectionMode
                                  ? () => _toggleSelection(msg.id)
                                  : null,
                              onLongPress: () => _toggleSelection(msg.id),
                              onReplyIconTap: () {
                                ref
                                    .read(replyToMessageProvider(widget.conversationId).notifier)
                                    .state = msg;
                              },
                              onReaction: (emoji) {
                                ref
                                    .read(messagingProvider.notifier)
                                    .toggleReaction(msg.id, emoji);
                              },
                              onTapReplyPreview: () {
                                // Could scroll to replied message; placeholder
                              },
                            ),
                          ),

                          // Selection checkmark overlay
                          if (_selectedIds.contains(msg.id))
                            Align(
                              alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: isOwn ? 0 : 56,
                                  right: isOwn ? 12 : 0,
                                ),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: context.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Typing indicator
          if (typingCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: const TypingIndicator(),
                ),
              ),
            ),

          // Reply preview bar
          if (replyTo != null)
            _ReplyPreviewBar(
              replyTo: replyTo,
              onClose: () {
                ref
                    .read(replyToMessageProvider(widget.conversationId).notifier)
                    .state = null;
              },
            ),

          // Chat input
          ChatInputBar(
            conversationId: widget.conversationId,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildChatAppBar(BuildContext context, int typingCount) {
    return AppBar(
      backgroundColor: context.appBarBg,
      elevation: 0,
      scrolledUnderElevation: 1,
      leadingWidth: 40,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.pop(),
        padding: EdgeInsets.zero,
      ),
      title: _ChatAppBarTitle(conversationId: widget.conversationId, typingCount: typingCount),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () {
            // TODO: in-conversation search
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          color: context.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'pin') {
              ref.read(pinnedConversationsProvider.notifier).toggle(widget.conversationId);
            }
            // 'search' and 'clear' are placeholders
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'pin',
              child: Row(children: [
                const Icon(Icons.push_pin_rounded, size: 18),
                const SizedBox(width: 10),
                Consumer(builder: (ctx, r, __) {
                  final isPinned = r.watch(pinnedConversationsProvider).contains(widget.conversationId);
                  return Text(isPinned ? 'Unpin conversation' : 'Pin conversation');
                }),
              ]),
            ),
            const PopupMenuItem(
              value: 'search',
              child: Row(children: [
                Icon(Icons.search_rounded, size: 18),
                SizedBox(width: 10),
                Text('Search'),
              ]),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(children: [
                Icon(Icons.delete_sweep_rounded, size: 18),
                SizedBox(width: 10),
                Text('Clear chat'),
              ]),
            ),
          ],
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(BuildContext context, List<MessageModel> messages) {
    return AppBar(
      backgroundColor: context.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.white),
        onPressed: _clearSelection,
      ),
      title: Text(
        '${_selectedIds.length} selected',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.copy_rounded, color: Colors.white),
          onPressed: () => _copySelectedMessages(messages),
          tooltip: 'Copy',
        ),
        IconButton(
          icon: const Icon(Icons.forward_rounded, color: Colors.white),
          onPressed: () {
            // TODO: forward placeholder
            _clearSelection();
          },
          tooltip: 'Forward',
        ),
        IconButton(
          icon: const Icon(Icons.push_pin_rounded, color: Colors.white),
          onPressed: () {
            for (final id in _selectedIds) {
              ref.read(messagingProvider.notifier).pinMessage(id, true);
            }
            _clearSelection();
          },
          tooltip: 'Pin',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          onPressed: () {
            // TODO: delete placeholder
            _clearSelection();
          },
          tooltip: 'Delete',
        ),
      ],
    );
  }
}

// ── App Bar Title ─────────────────────────────────────────────────────────────

class _ChatAppBarTitle extends ConsumerWidget {
  final String conversationId;
  final int typingCount;

  const _ChatAppBarTitle({required this.conversationId, required this.typingCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convsAsync = ref.watch(conversationsProvider);

    return convsAsync.when(
      loading: () => Text('Chat', style: TextStyle(color: context.textPrimary)),
      error: (_, __) => Text('Chat', style: TextStyle(color: context.textPrimary)),
      data: (convs) {
        final conv = convs.where((c) => c.id == conversationId).firstOrNull;
        final isDirect = conv?.type == 'direct';
        final memberCount = conv?.participants.length ?? 0;

        final name = conv?.title ?? 'Chat';
        final avatar = conv?.avatarUrl;
        final initials = conv?.initials ?? '?';

        String statusText;
        if (typingCount > 0) {
          statusText = typingCount == 1 ? 'typing...' : '$typingCount people typing...';
        } else if (isDirect) {
          statusText = 'online';
        } else {
          statusText = '$memberCount member${memberCount == 1 ? '' : 's'}';
        }

        return Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: context.borderCol,
              backgroundImage: avatar != null ? NetworkImage(avatar) : null,
              child: avatar == null
                  ? Text(
                      initials,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conv?.isVerified == true)
                        const Padding(
                          padding: EdgeInsets.only(left: 3),
                          child: Icon(Icons.verified_rounded, size: 13, color: AppColors.primary),
                        ),
                    ],
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      color: typingCount > 0 ? context.primary : AppColors.success,
                      fontStyle: typingCount > 0 ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Swipeable message wrapper ─────────────────────────────────────────────────

class _SwipeableMessage extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipeActivate;

  const _SwipeableMessage({
    super.key,
    required this.child,
    required this.onSwipeActivate,
  });

  @override
  State<_SwipeableMessage> createState() => _SwipeableMessageState();
}

class _SwipeableMessageState extends State<_SwipeableMessage>
    with SingleTickerProviderStateMixin {
  double _offset = 0.0;
  bool _activated = false;

  static const _threshold = 60.0;
  static const _maxOffset = 80.0;

  late final AnimationController _snapCtrl;
  late Animation<double> _snapAnim;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  void _onHorizontalUpdate(DragUpdateDetails details) {
    // Only allow right-swipe (positive dx)
    final newOffset = (_offset + details.delta.dx).clamp(0.0, _maxOffset);
    setState(() => _offset = newOffset);

    if (newOffset >= _threshold && !_activated) {
      _activated = true;
      HapticFeedback.lightImpact();
    }
  }

  void _onHorizontalEnd(DragEndDetails _) {
    if (_activated) {
      widget.onSwipeActivate();
    }
    _activated = false;
    // Spring back
    _snapAnim = Tween<double>(begin: _offset, end: 0.0).animate(
      CurvedAnimation(parent: _snapCtrl, curve: Curves.elasticOut),
    )..addListener(() => setState(() => _offset = _snapAnim.value));
    _snapCtrl.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalUpdate,
      onHorizontalDragEnd: _onHorizontalEnd,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: Offset(_offset, 0),
            child: widget.child,
          ),
          if (_offset > 8)
            Positioned(
              left: _offset - 28,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(
                  opacity: (_offset / _threshold).clamp(0.0, 1.0),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.reply_rounded,
                      size: 16,
                      color: context.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Date separator ────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month];
    return '$dayName ${date.day} $monthName';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: context.borderCol.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _label(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reply preview bar (above input) ──────────────────────────────────────────

class _ReplyPreviewBar extends StatelessWidget {
  final MessageModel replyTo;
  final VoidCallback onClose;

  const _ReplyPreviewBar({required this.replyTo, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border(
          top: BorderSide(color: context.borderCol, width: 0.5),
          left: BorderSide(color: context.primary, width: 3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.reply_rounded, size: 16, color: context.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  replyTo.senderName ?? 'Message',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.primary,
                  ),
                ),
                Text(
                  replyTo.content ?? (replyTo.hasAttachments ? '📎 Attachment' : ''),
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 18, color: context.textSecondary),
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.borderCol.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 32,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Send a message to start\nthe conversation',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
