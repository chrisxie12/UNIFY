import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _primary  = Color(0xFF2563EB);
const _textGrey = Color(0xFF64748B);

// ── Filter tab data ───────────────────────────────────────────────────────────

class _TabData {
  final String label;
  final int? count;
  const _TabData(this.label, [this.count]);
}

const _tabItems = [
  _TabData('All Chats'),
  _TabData('Personal'),
  _TabData('Campus'),
  _TabData('Study Groups'),
];

// ── ChatFilterTabs ────────────────────────────────────────────────────────────

class ChatFilterTabs extends StatelessWidget {
  const ChatFilterTabs({
    super.key,
    required this.activeIndex,
    required this.onSelect,
  });

  final int activeIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: _tabItems.length,
      separatorBuilder: (_, __) => const SizedBox(width: 6),
      itemBuilder: (context, i) => GestureDetector(
        onTap: () => onSelect(i),
        child: _TabChip(
          data: _tabItems[i],
          isActive: activeIndex == i,
        ),
      ),
    );
  }
}

// ── Tab chip ──────────────────────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  const _TabChip({required this.data, required this.isActive});

  final _TabData data;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isActive ? _primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : _textGrey,
            ),
            child: Text(data.label),
          ),
          if (data.count != null) ...[
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.22)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${data.count}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : _textGrey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
