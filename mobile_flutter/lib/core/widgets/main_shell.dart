import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../extensions/theme_extensions.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const _tabs = [
    _TabItem(icon: CupertinoIcons.house,           label: 'Feed'),
    _TabItem(icon: CupertinoIcons.square_grid_2x2, label: 'Hubs'),
    _TabItem(icon: CupertinoIcons.chat_bubble,     label: 'Messages'),
    _TabItem(icon: CupertinoIcons.calendar,        label: 'Events'),
    _TabItem(icon: CupertinoIcons.book,            label: 'Study'),
    _TabItem(icon: CupertinoIcons.person,          label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _UnifyBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ── Floating pill nav bar ────────────────────────────────────────────────

class _UnifyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _UnifyBottomNav({required this.currentIndex, required this.onTap});

  static const double _pillHeight = 50;
  static const double _pillHPad  = 24;
  static const double _topGap    = 16;
  static const double _bottomGap = 8;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final primary = context.primary;

    return SizedBox(
      height: _topGap + _pillHeight + _bottomGap + safeBottom,
      child: Padding(
        padding: const EdgeInsets.only(top: _topGap),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _pillHPad),
            child: Container(
              height: _pillHeight,
              decoration: BoxDecoration(
                color: context.surfaceCard.withValues(alpha: context.isDark ? 0.95 : 0.97),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: context.borderCol, width: 0.5),
                boxShadow: context.shadowMd,
              ),
              child: Row(
                children: List.generate(
                  MainShell._tabs.length,
                  (i) => _NavItem(
                    tab: MainShell._tabs[i],
                    active: currentIndex == i,
                    badge: i == 2 ? 3 : 0,
                    onTap: () => onTap(i),
                    primaryColor: primary,
                    inactiveColor: context.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Individual nav item ──────────────────────────────────────────────────

class _NavItem extends StatefulWidget {
  final _TabItem tab;
  final bool active;
  final int badge;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color inactiveColor;

  const _NavItem({
    required this.tab,
    required this.active,
    required this.badge,
    required this.onTap,
    required this.primaryColor,
    required this.inactiveColor,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primary = widget.primaryColor;
    final inactive = widget.inactiveColor;

    return Expanded(
      child: Semantics(
        button: true,
        label: widget.tab.label,
        hint: 'Switch to ${widget.tab.label} tab',
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: _isPressed ? 0.55 : 1.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: const Cubic(0.34, 1.56, 0.64, 1),
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: widget.active ? primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  transform: Matrix4.diagonal3Values(
                    widget.active ? 1.0 : 0.0,
                    widget.active ? 1.0 : 0.0,
                    1.0,
                  ),
                  transformAlignment: Alignment.center,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, widget.active ? -0.5 : 0, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      TweenAnimationBuilder<Color?>(
                        tween: ColorTween(
                          begin: inactive,
                          end: widget.active ? primary : inactive,
                        ),
                        duration: const Duration(milliseconds: 200),
                        builder: (context, color, _) => Icon(
                          widget.tab.icon,
                          color: color,
                          size: 22,
                        ),
                      ),
                      if (widget.badge > 0)
                        Positioned(
                          top: -6,
                          right: -5,
                          child: Container(
                            height: 16,
                            constraints: const BoxConstraints(minWidth: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: context.error,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: context.surfaceCard, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '${widget.badge}',
                                style: TextStyle(
                                  color: context.textInverse,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.active ? primary : inactive,
                    fontWeight: widget.active ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(widget.tab.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}
