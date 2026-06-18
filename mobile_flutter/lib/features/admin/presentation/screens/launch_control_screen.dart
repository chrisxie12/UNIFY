import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';

/// Launch Control — the operational command center for launching, monitoring,
/// growing and supporting UNIFY at scale. Admin-only entry point that links
/// out to every launch-infrastructure subsystem.
class LaunchControlScreen extends ConsumerWidget {
  const LaunchControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('Launch Control',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Hero readiness CTA
          _HeroCard(
            onTap: () => context.push('/launch/readiness'),
          ),
          const SizedBox(height: 24),

          _section('Monitor'),
          _grid(context, const [
            _Item('Launch Readiness', Icons.rocket_launch_rounded,
                Color(0xFF0066FF), '/launch/readiness'),
            _Item('Usage Analytics', Icons.insights_rounded,
                Color(0xFF7C3AED), '/launch/analytics'),
            _Item('Feature Adoption', Icons.donut_large_rounded,
                Color(0xFF0D9488), '/launch/adoption'),
            _Item('System Health', Icons.favorite_rounded,
                Color(0xFFDC2626), '/launch/health'),
          ]),
          const SizedBox(height: 22),

          _section('Grow'),
          _grid(context, const [
            _Item('Beta Access', Icons.workspaces_rounded,
                Color(0xFFEA580C), '/launch/beta'),
            _Item('Referrals', Icons.share_rounded,
                Color(0xFF059669), '/launch/referrals'),
            _Item('Ambassadors', Icons.school_rounded,
                Color(0xFFBE185D), '/launch/ambassadors'),
            _Item('Announcements', Icons.campaign_rounded,
                Color(0xFF2563EB), '/launch/announcements'),
          ]),
          const SizedBox(height: 22),

          _section('Support'),
          _grid(context, const [
            _Item('Feedback Center', Icons.feedback_rounded,
                Color(0xFFD97706), '/launch/feedback'),
            _Item('Support & Abuse', Icons.support_agent_rounded,
                Color(0xFF0891B2), '/launch/support'),
            _Item('App Versions', Icons.system_update_rounded,
                Color(0xFF4F46E5), '/launch/app-versions'),
          ]),
          const SizedBox(height: 22),

          _section('Moderation'),
          _grid(context, const [
            _Item('Requests & Verification', Icons.verified_user_rounded,
                Color(0xFF16A34A), '/admin'),
          ]),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Text(t.toUpperCase(),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.grey2)),
      );

  Widget _grid(BuildContext context, List<_Item> items) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: items.map((i) => _Tile(item: i)).toList(),
    );
  }
}

class _Item {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _Item(this.label, this.icon, this.color, this.route);
}

class _Tile extends StatelessWidget {
  final _Item item;
  const _Tile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(item.route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(item.icon, color: item.color, size: 21),
            ),
            Text(item.label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark)),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onTap;
  const _HeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.primary, context.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: context.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.rocket_launch_rounded,
                color: Colors.white, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Launch Readiness',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Live view of growth, activity and critical errors',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
