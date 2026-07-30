import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/feed/presentation/widgets/expandable_fab.dart';
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
            if (v < 0 && current < 3) _onNavTap(current + 1);
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(URadius.pill),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                margin: const EdgeInsets.only(
                  left: USpacing.xl,
                  right: USpacing.xl,
                  bottom: USpacing.md,
                ),
                decoration: BoxDecoration(
                  color: (context.isDark
                      ? const Color(0xFF1A1D28)
                      : const Color(0xFFF0F2F5)).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(URadius.pill),
                  border: Border.all(
                    color: context.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                          icon: PhosphorIconsBold.compass,
                          activeIcon: PhosphorIconsFill.compass,
                          label: 'Explore',
                          isActive: current == 1,
                          onTap: () => _onNavTap(1),
                        )),
                        Expanded(child: _NavItem(
                          icon: PhosphorIconsBold.chatCircle,
                          activeIcon: PhosphorIconsFill.chatCircle,
                          label: 'Chat',
                          badge: msgBadge,
                          isActive: current == 2,
                          onTap: () => _onNavTap(2),
                        )),
                        Expanded(child: _ProfileNavItem(
                          isActive: current == 3,
                          avatarUrl: user?.avatarUrl,
                          displayName: user?.displayName,
                          onTap: () => _onNavTap(3),
                        )),
                      ],
                    ),
                  ),
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

  Widget? _fabForIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        return const Padding(
          padding: EdgeInsets.only(right: 16),
          child: ExpandableFab(),
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: FloatingActionButton(
            onPressed: _onNewChat,
            backgroundColor: context.primary,
            foregroundColor: context.onPrimary,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(URadius.base),
            ),
            child: const Icon(PhosphorIconsBold.pencilSimple, size: 26),
          ),
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

class _NavItem extends StatefulWidget {
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
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _springCtrl;
  late Animation<double> _springAnim;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _springAnim = Tween<double>(begin: 1, end: 0.85).animate(
      CurvedAnimation(parent: _springCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _springCtrl.forward().then((_) => _springCtrl.reverse());
    }
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _springAnim,
        builder: (_, __) => Transform.scale(
          scale: _springAnim.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    widget.isActive ? widget.activeIcon : widget.icon,
                    size: UIcon.base,
                    color: widget.isActive ? context.primary : context.textSecondary,
                  ),
                  if (widget.badge > 0)
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
                            widget.badge > 9 ? '9+' : '${widget.badge}',
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
                widget.label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isActive ? context.primary : context.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileNavItem extends StatefulWidget {
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
  State<_ProfileNavItem> createState() => _ProfileNavItemState();
}

class _ProfileNavItemState extends State<_ProfileNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _springCtrl;
  late Animation<double> _springAnim;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _springAnim = Tween<double>(begin: 1, end: 0.85).animate(
      CurvedAnimation(parent: _springCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_ProfileNavItem old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _springCtrl.forward().then((_) => _springCtrl.reverse());
    }
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _springAnim,
        builder: (_, __) => Transform.scale(
          scale: _springAnim.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: widget.isActive
                      ? Border.all(color: context.primary, width: 2)
                      : Border.all(color: Colors.transparent, width: 2),
                ),
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: widget.isActive
                      ? context.primary.withValues(alpha: 0.15)
                      : context.surfaceFill,
                  backgroundImage:
                      widget.avatarUrl != null ? NetworkImage(widget.avatarUrl!) : null,
                  child: widget.avatarUrl == null
                      ? Text(
                          _initials(widget.displayName),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: widget.isActive ? context.primary : context.textSecondary,
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
                  fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isActive ? context.primary : context.textSecondary,
                ),
              ),
            ],
          ),
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
