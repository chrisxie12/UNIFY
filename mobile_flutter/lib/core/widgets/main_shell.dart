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

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  bool _visible = true;
  bool _fabOpen = false;
  late AnimationController _fabAnimCtrl;
  late Animation<double> _fabScale;
  late Animation<double> _fabOpacity;

  @override
  void initState() {
    super.initState();
    _fabAnimCtrl = AnimationController(
      vsync: this,
      duration: UMotion.normal,
    );
    _fabScale = CurvedAnimation(parent: _fabAnimCtrl, curve: Curves.easeOutBack);
    _fabOpacity = CurvedAnimation(parent: _fabAnimCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fabAnimCtrl.dispose();
    super.dispose();
  }

  void _toggleFab() {
    HapticFeedback.mediumImpact();
    setState(() {
      _fabOpen = !_fabOpen;
      if (_fabOpen) {
        _fabAnimCtrl.forward();
      } else {
        _fabAnimCtrl.reverse();
      }
    });
  }

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    if (_fabOpen) _toggleFab();
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
      floatingActionButton: _FabDial(
        visible: _visible,
        fabOpen: _fabOpen,
        animCtrl: _fabAnimCtrl,
        fabScale: _fabScale,
        fabOpacity: _fabOpacity,
        onToggle: _toggleFab,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                  horizontal: USpacing.sm,
                  vertical: USpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Iconsax.home_1,
                      activeIcon: Iconsax.home_1_copy,
                      label: 'Home',
                      isActive: navigationShell.currentIndex == 0,
                      onTap: () => _onNavTap(0),
                    ),
                    _NavItem(
                      icon: Iconsax.search_normal_1,
                      activeIcon: Iconsax.search_normal_1_copy,
                      label: 'Explore',
                      isActive: navigationShell.currentIndex == 1,
                      onTap: () => _onNavTap(1),
                    ),
                    const SizedBox(width: UTouch.fab),
                    _NavItem(
                      icon: Iconsax.message_2,
                      activeIcon: Iconsax.message_2_copy,
                      label: 'Messages',
                      badge: msgBadge,
                      isActive: navigationShell.currentIndex == 2,
                      onTap: () => _onNavTap(2),
                    ),
                    _ProfileNavItem(
                      isActive: navigationShell.currentIndex == 3,
                      avatarUrl: user?.avatarUrl,
                      displayName: user?.displayName,
                      onTap: () => _onNavTap(3),
                    ),
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
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: UIcon.lg,
                  color: isActive ? context.primary : context.textSecondary,
                ),
                if (badge > 0)
                  Positioned(
                    right: -4,
                    top: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badge > 9 ? '9+' : '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
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
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? context.primary : context.textSecondary,
              ),
            ),
          ],
        ),
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
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(color: context.primary, width: 2)
                    : Border.all(color: Colors.transparent, width: 2),
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: isActive
                    ? context.primary.withValues(alpha: 0.15)
                    : context.surfaceFill,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(
                        _initials(displayName),
                        style: TextStyle(
                          fontSize: 11,
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
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? context.primary : context.textSecondary,
              ),
            ),
          ],
        ),
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

class _FabDial extends StatelessWidget {
  final bool visible;
  final bool fabOpen;
  final AnimationController animCtrl;
  final Animation<double> fabScale;
  final Animation<double> fabOpacity;
  final VoidCallback onToggle;

  const _FabDial({
    required this.visible,
    required this.fabOpen,
    required this.animCtrl,
    required this.fabScale,
    required this.fabOpacity,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (fabOpen) ...[
          _FabOption(
            animCtrl: animCtrl,
            delay: 0.0,
            icon: Iconsax.add_square,
            label: 'New post',
            color: context.primary,
            onTap: () => _navigateCreate(context, '/post'),
          ),
          const SizedBox(height: 12),
          _FabOption(
            animCtrl: animCtrl,
            delay: 0.06,
            icon: Iconsax.calendar_add,
            label: 'Create event',
            color: context.success,
            onTap: () => _navigateCreate(context, '/events/create'),
          ),
          const SizedBox(height: 12),
          _FabOption(
            animCtrl: animCtrl,
            delay: 0.12,
            icon: Iconsax.book_1,
            label: 'Academic hub',
            color: const Color(0xFF8B5CF6),
            onTap: () => _navigateCreate(context, '/app/academic'),
          ),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          heroTag: 'nav_fab',
          onPressed: onToggle,
          shape: const CircleBorder(),
          backgroundColor: context.primary,
          foregroundColor: context.onPrimary,
          elevation: 4,
          child: AnimatedRotation(
            turns: fabOpen ? 0.125 : 0,
            duration: UMotion.normal,
            child: const Icon(Iconsax.add_circle_copy, size: 32),
          ),
        ),
      ],
    );
  }

  void _navigateCreate(BuildContext context, String route) {
    context.push(route);
  }
}

class _FabOption extends StatelessWidget {
  final AnimationController animCtrl;
  final double delay;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FabOption({
    required this.animCtrl,
    required this.delay,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animCtrl,
      builder: (context, child) {
        final raw = ((animCtrl.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        final t = Curves.easeOutBack.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.scale(
            scale: t,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(URadius.pill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.surfaceCard,
              borderRadius: BorderRadius.circular(URadius.pill),
              boxShadow: context.shadowSm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}