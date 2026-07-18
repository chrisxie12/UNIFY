import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../extensions/theme_extensions.dart';
import '../guards/admin_guard.dart';
import 'offline_banner.dart';
import '../../features/messaging/presentation/providers/messaging_provider.dart'
    as msg;

class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _visible = true;

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    final currentIndex = navigationShell.currentIndex;
    final msgBadge = ref.watch(msg.unreadCountProvider).valueOrNull ?? 0;

    ref.listen<bool>(adminAccessDeniedProvider, (_, denied) {
      if (!denied) return;
      ref.read(adminAccessDeniedProvider.notifier).state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock_outline_rounded,
                  color: Colors.white, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
      body: NotificationListener<UserScrollNotification>(
        onNotification: (n) {
          if (n.direction == ScrollDirection.reverse) {
            if (_visible) setState(() => _visible = false);
          } else if (n.direction == ScrollDirection.forward) {
            if (!_visible) setState(() => _visible = true);
          }
          return false;
        },
        child: OfflineBanner(child: navigationShell),
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _visible ? Offset.zero : const Offset(0, 1),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
            ),
            color: Colors.white,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: currentIndex == 0
                        ? Icons.home_filled
                        : Icons.home_outlined,
                    label: 'Feed',
                    isActive: currentIndex == 0,
                    onTap: () => _onNavTap(0),
                  ),
                  _NavItem(
                    icon: currentIndex == 1
                        ? Icons.hub
                        : Icons.hub_outlined,
                    label: 'Hubs',
                    isActive: currentIndex == 1,
                    onTap: () => _onNavTap(1),
                  ),
                  _NavItemWithBadge(
                    icon: currentIndex == 2
                        ? Icons.send
                        : Icons.send_outlined,
                    label: 'Messages',
                    isActive: currentIndex == 2,
                    badgeCount: msgBadge,
                    onTap: () => _onNavTap(2),
                  ),
                  _NavItem(
                    icon: currentIndex == 3
                        ? Icons.calendar_today
                        : Icons.calendar_today_outlined,
                    label: 'Events',
                    isActive: currentIndex == 3,
                    onTap: () => _onNavTap(3),
                  ),
                  _NavItem(
                    icon: currentIndex == 4
                        ? Icons.menu_book
                        : Icons.menu_book_outlined,
                    label: 'Study',
                    isActive: currentIndex == 4,
                    onTap: () => _onNavTap(4),
                  ),
                  _ProfileNavItem(
                    isActive: currentIndex == 5,
                    onTap: () => _onNavTap(5),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive ? Colors.black : const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.black : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemWithBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItemWithBadge({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? Colors.black : const Color(0xFF9CA3AF),
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -4,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.black : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _ProfileNavItem({
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.red : Colors.transparent,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              'U',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.black : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
