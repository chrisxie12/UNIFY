import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/extensions/theme_extensions.dart';
import '../../data/models/conversation_model.dart';

/// Formats [dt] relative to [now]:
///  - same day  → "HH:mm"
///  - this week → "Mon", "Tue", …
///  - older     → "dd/MM"
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

/// Returns a deterministic color from [id] for group/channel avatars.
Color _avatarColor(String id) {
  const palette = [
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
    Color(0xFF42A5F5),
    Color(0xFFFF7043),
    Color(0xFF66BB6A),
    Color(0xFFEC407A),
  ];
  final hash = id.codeUnits.fold(0, (a, b) => a + b);
  return palette[hash % palette.length];
}

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.isPinned,
    this.currentUserId,
    required this.onTap,
    this.onLongPress,
  });

  final ConversationModel conversation;
  final bool isPinned;
  final String? currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  // ── helpers ──────────────────────────────────────────────────────────────

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

  String? get _avatarUrl {
    if (_isDirect) return _otherParticipant?.avatarUrl;
    return conversation.avatarUrl;
  }

  String get _initials {
    final name = _isDirect
        ? (_otherParticipant?.displayName ?? conversation.title ?? '?')
        : (conversation.title ?? '?');
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
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

  bool get _hasUnread => conversation.unreadCount > 0;

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = _formatTime(conversation.lastMessageAt, now);
    final isUnread = _hasUnread;
    final muted = _isMuted;

    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final primary = context.primary;

    // Subtitle text
    String subtitleText;
    if (_isDirect) {
      subtitleText = conversation.lastMessageContent ?? '';
    } else {
      final sender = conversation.lastMessageSenderName;
      final content = conversation.lastMessageContent ?? '';
      subtitleText = sender != null && sender.isNotEmpty
          ? '$sender: $content'
          : content;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: SizedBox(
              height: 72,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // ── Avatar ──────────────────────────────────────────
                    _Avatar(
                      avatarUrl: _avatarUrl,
                      initials: _initials,
                      isChannel: _isChannel,
                      colorSeed: _avatarColor(conversation.id),
                      isVerified: conversation.isVerified,
                    ),
                    const SizedBox(width: 12),

                    // ── Body ────────────────────────────────────────────
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title row
                          Row(
                            children: [
                              if (_isChannel) ...[
                                Icon(
                                  Icons.tag_rounded,
                                  size: 14,
                                  color: textSecondary,
                                ),
                                const SizedBox(width: 2),
                              ],
                              Expanded(
                                child: Text(
                                  _displayName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isUnread
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),

                          // Subtitle row
                          Row(
                            children: [
                              if (muted) ...[
                                Icon(
                                  Icons.volume_off_rounded,
                                  size: 13,
                                  color: textSecondary,
                                ),
                                const SizedBox(width: 3),
                              ],
                              Expanded(
                                child: Text(
                                  subtitleText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: muted
                                        ? textSecondary.withValues(alpha: 0.6)
                                        : isUnread
                                            ? textPrimary.withValues(alpha: 0.85)
                                            : textSecondary,
                                    fontWeight: isUnread && !muted
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // ── Trailing ─────────────────────────────────────────
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Time + pin icon
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPinned) ...[
                              Icon(
                                Icons.push_pin_rounded,
                                size: 12,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 3),
                            ],
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 12,
                                color: isUnread ? primary : textSecondary,
                                fontWeight: isUnread
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Unread badge
                        if (isUnread)
                          _UnreadBadge(
                            count: conversation.unreadCount,
                            muted: muted,
                            primary: primary,
                          )
                        else
                          // Keep trailing height consistent
                          const SizedBox(height: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 0.5 px Telegram-style divider
        Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 76,
          endIndent: 0,
          color: context.borderCol.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.avatarUrl,
    required this.initials,
    required this.isChannel,
    required this.colorSeed,
    required this.isVerified,
  });

  final String? avatarUrl;
  final String initials;
  final bool isChannel;
  final Color colorSeed;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          // Main avatar circle
          ClipOval(
            child: avatarUrl != null && avatarUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _FallbackAvatar(
                      initials: initials,
                      color: colorSeed,
                      isChannel: isChannel,
                    ),
                    errorWidget: (_, __, ___) => _FallbackAvatar(
                      initials: initials,
                      color: colorSeed,
                      isChannel: isChannel,
                    ),
                  )
                : _FallbackAvatar(
                    initials: initials,
                    color: colorSeed,
                    isChannel: isChannel,
                  ),
          ),

          // Online indicator (placeholder — real status is future work)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E), // green-500
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.bg,
                  width: 2,
                ),
              ),
            ),
          ),

          // Verification badge overlay
          if (isVerified)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: context.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.bg, width: 1.5),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({
    required this.initials,
    required this.color,
    required this.isChannel,
  });

  final String initials;
  final Color color;
  final bool isChannel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      color: color,
      child: Center(
        child: isChannel
            ? const Icon(Icons.tag_rounded, color: Colors.white, size: 22)
            : Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

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
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
