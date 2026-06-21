import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/message.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────

const _surfaceDark = Color(0xFF1A1A2E);
const _accentBlue  = Color(0xFF00D4FF);
const _textPrimary = Colors.white;
const _textMuted   = Color(0xFF5A5A6E);
const _bubbleMe    = Color(0xFF1E1E35);  // slightly lighter than surfaceDark for "me" bubbles

TextStyle _sg(double size, FontWeight w, Color c, {double? height, double? ls}) =>
    GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: w,
      color: c,
      height: height,
      letterSpacing: ls,
    );

// ── MessageBubble ─────────────────────────────────────────────────────────────

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isFirstInGroup,
    required this.isLastInGroup,
  });

  final Message message;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? 12 : 2,
        bottom: isLastInGroup ? 4 : 0,
        left: 16,
        right: 16,
      ),
      child: message.isMe ? _MeBubble(message: message) : _TheirBubble(message: message, showAvatar: isFirstInGroup, showName: isFirstInGroup),
    );
  }
}

// ── Their message (left side) ─────────────────────────────────────────────────

class _TheirBubble extends StatelessWidget {
  const _TheirBubble({
    required this.message,
    required this.showAvatar,
    required this.showName,
  });

  final Message message;
  final bool showAvatar;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Avatar column — always allocate space for alignment
        SizedBox(
          width: 36,
          child: showAvatar
              ? _ContactAvatar(name: message.senderName)
              : null,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showName)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(
                    message.senderName.toUpperCase(),
                    style: _sg(10, FontWeight.w700, _accentBlue, ls: 1.2),
                  ),
                ),
              // Bubble with left accent bar
              IntrinsicWidth(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left accent bar
                    Container(
                      width: 3,
                      decoration: const BoxDecoration(
                        color: _accentBlue,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                    ),
                    // Bubble body
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                        decoration: const BoxDecoration(
                          color: _surfaceDark,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          message.text,
                          style: _sg(15, FontWeight.w400, _textPrimary, height: 1.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Spacer to prevent bubbles from stretching full width
        const SizedBox(width: 48),
      ],
    );
  }
}

// ── My message (right side) ───────────────────────────────────────────────────

class _MeBubble extends StatelessWidget {
  const _MeBubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Status icon
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 6),
          child: _StatusIcon(status: message.status),
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            decoration: const BoxDecoration(
              color: _bubbleMe,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              message.text,
              style: _sg(15, FontWeight.w400, _textPrimary, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Contact avatar ─────────────────────────────────────────────────────────────

class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({required this.name});

  final String name;

  static const _colors = [
    Color(0xFF7C3AED),
    Color(0xFF00D4FF),
    Color(0xFF2563EB),
    Color(0xFF10B981),
  ];

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color = _colors[name.length % _colors.length];
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Center(
        child: Text(
          initial,
          style: _sg(13, FontWeight.w700, Colors.white),
        ),
      ),
    );
  }
}

// ── Message status icon ───────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sent:
        return const Icon(Icons.check_rounded, size: 14, color: _textMuted);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all_rounded, size: 14, color: _textMuted);
      case MessageStatus.read:
        return const Icon(Icons.done_all_rounded, size: 14, color: _accentBlue);
    }
  }
}
