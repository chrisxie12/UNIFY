import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../widgets/admin_widgets.dart';

class EventsAdminScreen extends StatelessWidget {
  const EventsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events Administration')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdminActionCard(
            title: 'Event Approvals',
            subtitle: 'Review and approve pending events',
            icon: Icons.event_rounded,
            color: const Color(0xFF10B981),
            onTap: () => context.push('/events/admin'),
          ),
          const SizedBox(height: 12),
          AdminActionCard(
            title: 'Featured Events',
            subtitle: 'Manage featured event lineup',
            icon: Icons.star_rounded,
            color: AppColors.warning,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to events management'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          const SizedBox(height: 12),
          AdminActionCard(
            title: 'Attendance Analytics',
            subtitle: 'View event attendance metrics',
            icon: Icons.analytics_rounded,
            color: const Color(0xFF8B5CF6),
            onTap: () => context.push('/admin/analytics'),
          ),
          const SizedBox(height: 12),
          AdminActionCard(
            title: 'Certificate Management',
            subtitle: 'Issue and manage event certificates',
            icon: Icons.card_membership_rounded,
            color: context.primary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Certificate management coming soon'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: context.primary),
                    const SizedBox(width: 8),
                    Text('Quick Info', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Event moderation is handled through the existing events admin panel at /events/admin. Use the link above to approve, feature, or manage events.', style: TextStyle(fontSize: 13, color: context.textPrimary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
