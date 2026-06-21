import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


// ── Design tokens ─────────────────────────────────────────────────────────────

const _primary   = Color(0xFF2563EB);
const _textDark  = Color(0xFF0F172A);
const _textGrey  = Color(0xFF64748B);
const _textMuted = Color(0xFF94A3B8);
const _divider   = Color(0xFFE2E8F0);

TextStyle _sg(double size, FontWeight w, Color c) =>
    GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: w, color: c);

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
