import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../extensions/theme_extensions.dart';
import '../guards/admin_guard.dart';
import 'offline_banner.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart' as notif;
import '../../features/messaging/presentation/providers/messaging_provider.dart' as msg;

class MainShell extends ConsumerStatefulWidget {
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
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  /// How long the nav stays expanded with no interaction before collapsing.
  static const _autoCollapse = Duration(seconds: 15);

  bool _expanded = true;
  Timer? _idleTimer;
  DateTime? _lastTapDown;

  @override
  void initState() {
    super.initState();
    _restartIdleTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  /// (Re)start the 15s inactivity timer that collapses the nav into one icon.
  void _restartIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_autoCollapse, () {
      if (mounted && _expanded) setState(() => _expanded = false);
    });
  }

  void _expand() {
    if (!_expanded) setState(() => _expanded = true);
    _restartIdleTimer();
  }

  void _collapse() {
    _idleTimer?.cancel();
    if (_expanded) setState(() => _expanded = false);
  }

  void _toggle() => _expanded ? _collapse() : _expand();

  /// Manual double-tap detection via raw pointer events. A [Listener] never
  /// competes in the gesture arena, so it fires even over scrollables/buttons
  /// and adds no tap delay to the page content.
  void _onPointerDown(PointerDownEvent _) {
    final now = DateTime.now();
    if (_lastTapDown != null &&
        now.difference(_lastTapDown!) < const Duration(milliseconds: 300)) {
      _lastTapDown = null;
      _toggle();
    } else {
      _lastTapDown = now;
    }
  }

  bool _onScroll(ScrollNotification n) {
    // Hide while scrolling down through content, reveal when scrolling back up.
    // Uses scrollDelta instead of ScrollDirection to avoid an import-ambiguity
    // on that enum and stay version-proof.
    if (n is ScrollUpdateNotification) {
      final delta = n.scrollDelta ?? 0;
      if (delta > 6) {
        _collapse();
      } else if (delta < -6) {
        _expand();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    final notifBadge = ref.watch(notif.unreadCountProvider).valueOrNull ?? 0;
    final msgBadge = ref.watch(msg.unreadCountProvider).valueOrNull ?? 0;

    // Show branded snackbar when an unauthorized admin-route access was blocked.
    ref.listen<bool>(adminAccessDeniedProvider, (_, denied) {
      if (!denied) return;
      ref.read(adminAccessDeniedProvider.notifier).state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Access Denied',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Admin privileges required for that area.',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: context.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    });

    return Scaffold(
      extendBody: true,
      body: Listener(
        // Double-tap anywhere collapses/expands the nav (raw pointer events,
        // so it works over scrollables without stealing their gestures).
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: OfflineBanner(child: navigationShell),
        ),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: _expanded
            ? _UnifyBottomNav(
                key: const ValueKey('nav-expanded'),
                currentIndex: navigationShell.currentIndex,
                badges: [notifBadge, 0, msgBadge, 0, 0, 0],
                onTap: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                  _expand();
                },
              )
            : _CollapsedNavButton(
                key: const ValueKey('nav-collapsed'),
                icon: MainShell._tabs[navigationShell.currentIndex].icon,
                showDot: notifBadge + msgBadge > 0,
                onTap: _expand,
              ),
      ),
    );
  }
}

// ── Floating pill nav bar ────────────────────────────────────────────────

class _UnifyBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<int> badges;
  final ValueChanged<int> onTap;

  const _UnifyBottomNav({
    super.key,
    required this.currentIndex,
    required this.badges,
    required this.onTap,
  }) : assert(badges.length == MainShell._tabs.length);

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
                    badge: badges[i],
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(i);
                    },
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

// ── Collapsed single-icon pill ───────────────────────────────────────────

class _CollapsedNavButton extends StatelessWidget {
  final IconData icon;
  final bool showDot;
  final VoidCallback onTap;

  const _CollapsedNavButton({
    super.key,
    required this.icon,
    required this.showDot,
    required this.onTap,
  });

  // Keep the same reserved height as the full bar so the body doesn't jump.
  static const double _pillHeight = 50;
  static const double _topGap     = 16;
  static const double _bottomGap  = 8;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return SizedBox(
      height: _topGap + _pillHeight + _bottomGap + safeBottom,
      child: Padding(
        padding: const EdgeInsets.only(top: _topGap),
        child: Align(
          alignment: Alignment.topCenter,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: Container(
              height: _pillHeight,
              width: 70,
              decoration: BoxDecoration(
                color: context.surfaceCard
                    .withValues(alpha: context.isDark ? 0.95 : 0.97),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: context.borderCol, width: 0.5),
                boxShadow: context.shadowMd,
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: context.primary, size: 22),
                      const SizedBox(width: 3),
                      Icon(CupertinoIcons.chevron_up,
                          color: context.textSecondary, size: 12),
                    ],
                  ),
                  if (showDot)
                    Positioned(
                      top: 9,
                      right: 16,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.surfaceCard, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
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
