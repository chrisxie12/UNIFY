import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/chat_item.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────

const _primary   = Color(0xFF2563EB);
const _textDark  = Color(0xFF0F172A);
const _textGrey  = Color(0xFF64748B);
const _textMuted = Color(0xFF94A3B8);
const _divider   = Color(0xFFE2E8F0);
const _online    = Color(0xFF22C55E);

TextStyle _sg(double size, FontWeight w, Color c) =>
    GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: w, color: c);

// ── ChatListItem ──────────────────────────────────────────────────────────────

class ChatListItem extends StatelessWidget {
  const ChatListItem({super.key, required this.chat});

  final ChatItem chat;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AvatarStack(chat: chat),
              const SizedBox(width: 12),
              Expanded(child: _ChatContent(chat: chat)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 84),
          child: Divider(height: 0.5, thickness: 0.5, color: _divider),
        ),
      ],
    );
  }
}

// ── Avatar with online dot ────────────────────────────────────────────────────

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.chat});

  final ChatItem chat;

  @override
  Widget build(BuildContext context) {
    final color = Color(kAvatarColors[chat.avatarColorIndex % kAvatarColors.length]);
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: chat.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      chat.avatarUrl!,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) => _InitialLabel(chat.initials),
                    ),
                  )
                : _InitialLabel(chat.initials),
          ),
          if (chat.isOnline)
            Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _online,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InitialLabel extends StatelessWidget {
  const _InitialLabel(this.initials);

  final String initials;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      initials,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );
}

// ── Chat content (name + preview) ─────────────────────────────────────────────

class _ChatContent extends StatelessWidget {
  const _ChatContent({required this.chat});

  final ChatItem chat;

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unreadCount > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name row + timestamp
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (chat.isMuted) ...[
              Icon(Icons.volume_off_outlined, size: 13, color: _textMuted),
              const SizedBox(width: 3),
            ],
            if (chat.isPinned) ...[
              Icon(Icons.push_pin_rounded, size: 13, color: _textMuted),
              const SizedBox(width: 3),
            ],
            Expanded(
              child: Text(
                chat.name,
                style: _sg(15, FontWeight.w600, _textDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              chat.timestamp,
              style: _sg(11, FontWeight.w500, hasUnread ? _primary : _textMuted),
            ),
          ],
        ),
        const SizedBox(height: 3),
        // Message preview row + badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _MessagePreview(chat: chat)),
            const SizedBox(width: 6),
            _TrailingBadge(chat: chat),
          ],
        ),
      ],
    );
  }
}

// ── Message preview ───────────────────────────────────────────────────────────

class _MessagePreview extends StatelessWidget {
  const _MessagePreview({required this.chat});

  final ChatItem chat;

  @override
  Widget build(BuildContext context) {
    if (chat.isTyping) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _TypingDots(),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${chat.typingUser ?? 'Someone'} is typing...',
              style: _sg(13, FontWeight.w400, _primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    final prefixIcon = _prefixIcon();
    final previewText = _previewText();

    if (prefixIcon == null) {
      return Text(
        previewText,
        style: _sg(13, FontWeight.w400, _textGrey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        prefixIcon,
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            previewText,
            style: _sg(13, FontWeight.w400, _textGrey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget? _prefixIcon() {
    if (chat.isForwarded) {
      return Transform(
        transform: Matrix4.rotationY(3.14159),
        alignment: Alignment.center,
        child: const Icon(Icons.reply_rounded, size: 14, color: _textMuted),
      );
    }
    if (chat.hasMedia) {
      final icon = chat.mediaType == 'video'
          ? Icons.videocam_outlined
          : chat.mediaType == 'voice'
              ? Icons.mic_outlined
              : Icons.image_outlined;
      return Icon(icon, size: 14, color: _textMuted);
    }
    return null;
  }

  String _previewText() {
    if (chat.hasMedia) {
      return chat.mediaType == 'video'
          ? 'Video'
          : chat.mediaType == 'voice'
              ? 'Voice message'
              : chat.lastMessage.isEmpty ? 'Photo' : chat.lastMessage;
    }
    return chat.lastMessage;
  }
}

// ── Trailing badge or checkmark ───────────────────────────────────────────────

class _TrailingBadge extends StatelessWidget {
  const _TrailingBadge({required this.chat});

  final ChatItem chat;

  @override
  Widget build(BuildContext context) {
    if (chat.unreadCount > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        constraints: const BoxConstraints(minWidth: 20),
        decoration: BoxDecoration(
          color: chat.isMuted ? _textMuted : _primary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}',
          style: _sg(11, FontWeight.w700, Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (chat.isRead) {
      return const Icon(Icons.done_all_rounded, size: 16, color: _primary);
    }
    return const SizedBox.shrink();
  }
}

// ── Typing dots animation ─────────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i / 3;
          final value = (_ctrl.value - delay).clamp(0.0, 1.0);
          final opacity = (value < 0.5 ? value * 2 : (1 - value) * 2).clamp(0.3, 1.0);
          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Archived chats special row ────────────────────────────────────────────────

class ArchivedChatsRow extends StatelessWidget {
  const ArchivedChatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.archive_outlined, color: Color(0xFF64748B), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Archived Chats', style: _sg(15, FontWeight.w600, _textDark)),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _textMuted),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Campus Housing, Study Group — 3 more',
                      style: _sg(13, FontWeight.w400, _textGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('4', style: _sg(11, FontWeight.w700, Colors.white)),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 84),
          child: Divider(height: 0.5, thickness: 0.5, color: _divider),
        ),
      ],
    );
  }
}
