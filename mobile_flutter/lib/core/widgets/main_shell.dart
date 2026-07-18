import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
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
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: context.borderCol, width: 0.5),
            ),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              HapticFeedback.selectionClick();
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            backgroundColor: context.surfaceCard,
            indicatorColor: context.primary.withValues(alpha: 0.12),
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            destinations: [
            NavigationDestination(
              icon: _BadgeIcon(
                icon: CupertinoIcons.house,
                badge: 0,
              ),
              selectedIcon: _BadgeIcon(
                icon: CupertinoIcons.house_fill,
                badge: 0,
              ),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: _BadgeIcon(
                icon: CupertinoIcons.square_grid_2x2,
                badge: 0,
              ),
              selectedIcon: _BadgeIcon(
                icon: CupertinoIcons.square_grid_2x2_fill,
                badge: 0,
              ),
              label: 'Hubs',
            ),
            NavigationDestination(
              icon: _BadgeIcon(
                icon: CupertinoIcons.chat_bubble,
                badge: msgBadge,
              ),
              selectedIcon: _BadgeIcon(
                icon: CupertinoIcons.chat_bubble_fill,
                badge: msgBadge,
              ),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: _BadgeIcon(
                icon: CupertinoIcons.calendar,
                badge: 0,
              ),
              selectedIcon: _BadgeIcon(
                icon: CupertinoIcons.calendar,
                badge: 0,
              ),
              label: 'Events',
            ),
            NavigationDestination(
              icon: _BadgeIcon(
                icon: CupertinoIcons.book,
                badge: 0,
              ),
              selectedIcon: _BadgeIcon(
                icon: CupertinoIcons.book_fill,
                badge: 0,
              ),
              label: 'Study',
            ),
            NavigationDestination(
              icon: _BadgeIcon(
                icon: CupertinoIcons.person,
                badge: 0,
              ),
              selectedIcon: _BadgeIcon(
                icon: CupertinoIcons.person_fill,
                badge: 0,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int badge;

  const _BadgeIcon({required this.icon, required this.badge});

  @override
  Widget build(BuildContext context) {
    if (badge <= 0) return Icon(icon);
    return Badge(
      isLabelVisible: badge > 0,
      label: Text(badge > 9 ? '9+' : '$badge'),
      child: Icon(icon),
    );
  }
}


