import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _Tab(path: '/app/feed',         icon: Icons.home_outlined,         activeIcon: Icons.home_rounded,          label: 'Feed'),
    _Tab(path: '/app/communities',  icon: Icons.grid_view_outlined,    activeIcon: Icons.grid_view_rounded,     label: 'Hubs'),
    _Tab(path: '/app/messaging',    icon: Icons.chat_bubble_outline,   activeIcon: Icons.chat_bubble_rounded,   label: 'Messages'),
    _Tab(path: '/app/profile',      icon: Icons.person_outline_rounded,activeIcon: Icons.person_rounded,        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final activeIdx = _tabs.indexWhere((t) => location.startsWith(t.path));

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final active = i == activeIdx;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.go(tab.path),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44, height: 32,
                          decoration: BoxDecoration(
                            color: active ? AppColors.primaryLight.withOpacity(0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            active ? tab.activeIcon : tab.icon,
                            size: 22,
                            color: active ? AppColors.primaryLight : AppColors.grey3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                            color: active ? AppColors.primaryLight : AppColors.grey3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _Tab({required this.path, required this.icon, required this.activeIcon, required this.label});
}
