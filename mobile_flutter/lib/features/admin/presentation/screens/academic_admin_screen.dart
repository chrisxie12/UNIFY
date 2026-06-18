import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../widgets/admin_widgets.dart';

class AcademicAdminScreen extends StatelessWidget {
  const AcademicAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academic Hub Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdminActionCard(
            title: 'Course Repositories',
            subtitle: 'Manage courses and academic resources',
            icon: Icons.menu_book_rounded,
            color: context.primary,
            onTap: () => _comingSoon(context),
          ),
          const SizedBox(height: 12),
          AdminActionCard(
            title: 'Resource Verification',
            subtitle: 'Approve official academic materials',
            icon: Icons.verified_rounded,
            color: const Color(0xFF10B981),
            onTap: () => _comingSoon(context),
          ),
          const SizedBox(height: 12),
          AdminActionCard(
            title: 'Past Questions',
            subtitle: 'Review and approve past exam papers',
            icon: Icons.quiz_rounded,
            color: AppColors.warning,
            onTap: () => _comingSoon(context),
          ),
          const SizedBox(height: 12),
          AdminActionCard(
            title: 'Flagged Resources',
            subtitle: 'Review and moderate flagged materials',
            icon: Icons.flag_rounded,
            color: AppColors.error,
            onTap: () => _comingSoon(context),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
    );
  }
}
