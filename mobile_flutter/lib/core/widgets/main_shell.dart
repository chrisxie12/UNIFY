import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
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
      extendBody: true,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (n) {
          if (n.direction == ScrollDirection.reverse) {
            if (_visible) setState(() => _visible = false);
          } else if (n.direction == ScrollDirection.forward) {
            if (!_visible) setState(() => _visible = true);
          }
          return false;
        },
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            const threshold = 200.0;
            final v = details.primaryVelocity ?? 0;
            if (v.abs() < threshold) return;
            if (v < 0 && current < 5) _onNavTap(current + 1);
            if (v > 0 && current > 0) _onNavTap(current - 1);
          },
          behavior: HitTestBehavior.translucent,
          child: OfflineBanner(child: navigationShell),
        ),
      ),
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
                      icon: PhosphorIconsBold.house,
                      activeIcon: PhosphorIconsFill.house,
                      label: 'Home',
                      isActive: current == 0,
                      onTap: () => _onNavTap(0),
                    )),
                    Expanded(child: _NavItem(
                      icon: PhosphorIconsBold.magnifyingGlass,
                      activeIcon: PhosphorIconsFill.magnifyingGlass,
                      label: 'Explore',
                      isActive: current == 1,
                      onTap: () => _onNavTap(1),
                    )),
                    Expanded(child: _NavItem(
                      icon: PhosphorIconsBold.calendar,
                      activeIcon: PhosphorIconsFill.calendar,
                      label: 'Events',
                      isActive: current == 2,
                      onTap: () => _onNavTap(2),
                    )),
                    Expanded(child: _NavItem(
                      icon: PhosphorIconsBold.books,
                      activeIcon: PhosphorIconsFill.books,
                      label: 'Study',
                      isActive: current == 3,
                      onTap: () => _onNavTap(3),
                    )),
                    Expanded(child: _NavItem(
                      icon: PhosphorIconsBold.chatCircle,
                      activeIcon: PhosphorIconsFill.chatCircle,
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
      floatingActionButton: _fabForIndex(context, current),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _onCreatePost() {
    final shell = widget.navigationShell;
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: context.textDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _CreateOption(
                icon: PhosphorIconsBold.fileText,
                title: 'Create Post',
                subtitle: 'Share your thoughts with the community',
                color: context.primary,
                onTap: () {
                  Navigator.of(ctx).pop();
                  shell.goBranch(1);
                },
              ),
              const SizedBox(height: 4),
              _CreateOption(
                icon: PhosphorIconsBold.chartBar,
                title: 'Create Poll',
                subtitle: 'Gather opinions and feedback',
                color: context.info,
                onTap: () {
                  Navigator.of(ctx).pop();
                  shell.goBranch(1);
                },
              ),
              const SizedBox(height: 4),
              _CreateOption(
                icon: PhosphorIconsBold.camera,
                title: 'Create Story',
                subtitle: 'Share a moment that disappears in 24h',
                color: context.warning,
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push('/stories/create');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _fabForIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        return FloatingActionButton(
          onPressed: _onCreatePost,
          backgroundColor: context.primary,
          foregroundColor: context.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(URadius.base),
          ),
          child: const Icon(PhosphorIconsBold.plus, size: 28),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () => context.push('/events/create'),
          backgroundColor: context.primary,
          foregroundColor: context.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(URadius.base),
          ),
          child: const Icon(PhosphorIconsBold.calendarPlus, size: 26),
        );
      case 4:
        return FloatingActionButton(
          onPressed: _onNewChat,
          backgroundColor: context.primary,
          foregroundColor: context.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(URadius.base),
          ),
          child: const Icon(PhosphorIconsBold.pencilSimple, size: 26),
        );
      default:
        return null;
    }
  }

  void _onNewChat() {
    HapticFeedback.heavyImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderCol,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: context.primary.withValues(alpha: 0.12),
                child: Icon(PhosphorIconsBold.paperPlaneTilt, color: context.primary),
              ),
              title: Text(
                'New Message',
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Start a direct conversation',
                style: TextStyle(fontSize: 12, color: context.textSecondary),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/messaging/search');
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: context.info.withValues(alpha: 0.12),
                child: Icon(PhosphorIconsBold.usersThree, color: context.info),
              ),
              title: Text(
                'New Group',
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Create a group conversation',
                style: TextStyle(fontSize: 12, color: context.textSecondary),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/messaging/create-group');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(URadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(URadius.md),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(PhosphorIconsBold.caretRight, size: 18, color: context.textDisabled),
            ],
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
