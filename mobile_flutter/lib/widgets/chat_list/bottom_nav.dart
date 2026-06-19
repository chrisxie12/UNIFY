import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _primary  = Color(0xFF2563EB);
const _inactive = Color(0xFF94A3B8);

class ChatBottomNav extends StatelessWidget {
  const ChatBottomNav({
    super.key,
    required this.activeIndex,
    required this.onSelect,
    this.unreadCount = 0,
  });

  final int activeIndex;
  final ValueChanged<int> onSelect;
  final int unreadCount;

  static const _items = [
    _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Chats'),
    _NavItem(icon: Icons.people_outline_rounded,      activeIcon: Icons.people_rounded,      label: 'Contacts'),
    _NavItem(icon: Icons.settings_outlined,           activeIcon: Icons.settings_rounded,    label: 'Settings'),
    _NavItem(icon: Icons.person_outline_rounded,      activeIcon: Icons.person_rounded,      label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_items.length, (i) {
            final active = activeIndex == i;
            final item = _items[i];
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            active ? item.activeIcon : item.icon,
                            key: ValueKey(active),
                            size: 24,
                            color: active ? _primary : _inactive,
                          ),
                        ),
                        if (i == 0 && unreadCount > 0)
                          Positioned(
                            top: -5,
                            right: -8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              constraints: const BoxConstraints(minWidth: 18),
                              decoration: BoxDecoration(
                                color: _primary,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        color: active ? _primary : _inactive,
                      ),
                      child: Text(item.label),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
