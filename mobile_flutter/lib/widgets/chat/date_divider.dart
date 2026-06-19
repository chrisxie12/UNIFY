import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _textMuted = Color(0xFF5A5A6E);
const _divider   = Color(0xFF2A2A3E);

class ChatDateDividerRow extends StatelessWidget {
  const ChatDateDividerRow({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          const Expanded(child: Divider(color: _divider, thickness: 0.5)),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(color: _divider, thickness: 0.5)),
        ],
      ),
    );
  }
}
