import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _bg           = Color(0xFF0A0A0F);
const _surfaceCard  = Color(0xFF16162A);
const _accentPurple = Color(0xFF7C3AED);
const _textPrimary  = Colors.white;
const _textMuted    = Color(0xFF5A5A6E);

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onGamingTap,
    this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onGamingTap;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Camera button
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: _surfaceCard,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_rounded, color: _textPrimary, size: 20),
            ),
            const SizedBox(width: 10),

            // Expandable text field
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: _surfaceCard,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: _textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Send a chat',
                          hintStyle: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: _textMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => onSend?.call(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onSend,
                      child: const Icon(Icons.mic_rounded, color: _textPrimary, size: 20),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Emoji
            const Icon(Icons.emoji_emotions_outlined, color: _textPrimary, size: 24),
            const SizedBox(width: 12),

            // Gallery
            const Icon(Icons.photo_library_outlined, color: _textPrimary, size: 22),
            const SizedBox(width: 12),

            // Gaming button — purple rounded square
            GestureDetector(
              onTap: onGamingTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _accentPurple,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _accentPurple.withValues(alpha: 0.40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.gamepad_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
