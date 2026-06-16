import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../extensions/theme_extensions.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const _tabs = [
    _TabItem(icon: CupertinoIcons.house, label: 'Feed'),
    _TabItem(icon: CupertinoIcons.square_grid_2x2, label: 'Hubs'),
    _TabItem(icon: CupertinoIcons.chat_bubble, label: 'Messages'),
    _TabItem(icon: CupertinoIcons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

class _UnifyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _UnifyBottomNav({required this.currentIndex, required this.onTap});

  static const Color _gray400 = Color(0xFFA1A1AA);
  static const Color _gray200 = Color(0xFFE4E4E7);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _gray200, width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: List.generate(
              MainShell._tabs.length,
              (i) => _NavItem(
                tab: MainShell._tabs[i],
                active: currentIndex == i,
                badge: i == 2 ? 3 : 0,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final _TabItem tab;
  final bool active;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.active,
    required this.badge,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;
    const gray400 = _UnifyBottomNav._gray400;

    return Expanded(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 60),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: _isPressed ? 0.6 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dot indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: const Cubic(0.34, 1.56, 0.64, 1),
                  width: 4.5,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: widget.active ? primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  transform: Matrix4.diagonal3Values(widget.active ? 1.0 : 0.0, widget.active ? 1.0 : 0.0, 1.0),
                  transformAlignment: Alignment.center,
                ),

                // Icon with translateY + animated color
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, widget.active ? -1 : 0, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      TweenAnimationBuilder<Color?>(
                        tween: ColorTween(
                          begin: gray400,
                          end: widget.active ? primary : gray400,
                        ),
                        duration: const Duration(milliseconds: 200),
                        builder: (context, color, _) => Icon(
                          widget.tab.icon,
                          color: color,
                          size: 24,
                        ),
                      ),
                      if (widget.badge > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            height: 16,
                            constraints: const BoxConstraints(minWidth: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '${widget.badge}',
                                style: const TextStyle(
                                  color: Colors.white,
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

                const SizedBox(height: 4),

                // Label with animated color + weight
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.active ? primary : gray400,
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
