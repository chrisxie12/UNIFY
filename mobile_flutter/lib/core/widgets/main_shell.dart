import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/messaging/presentation/providers/messaging_provider.dart'
    as msg;
import '../design_system/tokens.dart';
import '../extensions/theme_extensions.dart';
import '../guards/admin_guard.dart';
import 'offline_banner.dart';

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
    final msgBadge = ref.watch(msg.unreadCountProvider).valueOrNull ?? 0;
    final userAsync = ref.watch(currentAppUserProvider);
    final user = userAsync.valueOrNull;
    final current = navigationShell.currentIndex;

    ref.listen<bool>(adminAccessDeniedProvider, (_, denied) {
      if (!denied) return;
      ref.read(adminAccessDeniedProvider.notifier).state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Access Denied',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.white)),
                    Text('Admin privileges required for that area.',
                        style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: context.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      extendBody: true,
      bottomNavigationBar: AnimatedSlide(
        duration: UMotion.fast,
        offset: _visible ? Offset.zero : const Offset(0, 1.5),
        child: AnimatedOpacity(
          duration: UMotion.fast,
          opacity: _visible ? 1.0 : 0.0,
          child: Container(
            margin: const EdgeInsets.only(
              left: USpacing.xl,
              right: USpacing.xl,
              bottom: USpacing.md,
            ),
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0xFF1A1D28)
                  : const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(URadius.pill),
              boxShadow: context.shadowMd,
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: USpacing.xs,
                  vertical: USpacing.xs,
                ),
                child: Row(
                  children: [
                    Expanded(child: _NavItem(
                      icon: Iconsax.home_1,
                      activeIcon: Iconsax.home_1_copy,
                      label: 'Home',
                      isActive: current == 0,
                      onTap: () => _onNavTap(0),
                    )),
                    Expanded(child: _NavItem(
                      icon: Iconsax.search_normal_1,
                      activeIcon: Iconsax.search_normal_1_copy,
                      label: 'Explore',
                      isActive: current == 1,
                      onTap: () => _onNavTap(1),
                    )),
                    Expanded(child: _NavItem(
                      icon: Iconsax.calendar_1,
                      activeIcon: Iconsax.calendar_1_copy,
                      label: 'Events',
                      isActive: current == 2,
                      onTap: () => _onNavTap(2),
                    )),
                    Expanded(child: _NavItem(
                      icon: Iconsax.book_1,
                      activeIcon: Iconsax.book_1_copy,
                      label: 'Study',
                      isActive: current == 3,
                      onTap: () => _onNavTap(3),
                    )),
                    Expanded(child: _NavItem(
                      icon: Iconsax.message_2,
                      activeIcon: Iconsax.message_2_copy,
                      label: 'Chat',
                      badge: msgBadge,
                      isActive: current == 4,
                      onTap: () => _onNavTap(4),
                    )),
                    Expanded(child: _ProfileNavItem(
                      isActive: current == 5,
                      avatarUrl: user?.avatarUrl,
                      displayName: user?.displayName,
                      onTap: () => _onNavTap(5),
                    )),
                  ],
                ),
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
  final IconData activeIcon;
  final String label;
  final int badge;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge = 0,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: UIcon.base,
                color: isActive ? context.primary : context.textSecondary,
              ),
              if (badge > 0)
                Positioned(
                  right: -4,
                  top: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? context.primary : context.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProfileNavItem extends StatelessWidget {
  final bool isActive;
  final String? avatarUrl;
  final String? displayName;
  final VoidCallback onTap;

  const _ProfileNavItem({
    required this.isActive,
    this.avatarUrl,
    this.displayName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(color: context.primary, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
            ),
            child: CircleAvatar(
              radius: 9,
              backgroundColor: isActive
                  ? context.primary.withValues(alpha: 0.15)
                  : context.surfaceFill,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      _initials(displayName),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isActive ? context.primary : context.textSecondary,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? context.primary : context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
