import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _textMuted = Color(0xFF94A3B8);

class ChatSearchBar extends StatelessWidget {
  const ChatSearchBar({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SizedBox(
        height: 44,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.search_rounded, size: 20, color: _textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: onChanged,
                  style: GoogleFonts.spaceGrotesk(fontSize: 14, color: const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: 'Search Chats',
                    hintStyle: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _textMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
