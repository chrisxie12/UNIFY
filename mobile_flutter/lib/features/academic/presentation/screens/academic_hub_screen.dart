import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';

class AcademicHubScreen extends ConsumerWidget {
  const AcademicHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/academic/search'),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(USpacing.base),
        mainAxisSpacing: USpacing.md,
        crossAxisSpacing: USpacing.md,
        childAspectRatio: 0.9,
        children: [
          _HubCard(
            icon: Icons.library_books,
            label: 'Notes',
            subtitle: 'Browse course notes',
            color: context.primary,
            onTap: () => context.push('/academic/resources', extra: {'type': 'note'}),
          ),
          _HubCard(
            icon: Icons.quiz_outlined,
            label: 'Past Questions',
            subtitle: 'Exam papers & quizzes',
            color: context.info,
            onTap: () => context.push('/academic/resources', extra: {'type': 'past_question'}),
          ),
          _HubCard(
            icon: Icons.school,
            label: 'Courses',
            subtitle: 'Your enrolled courses',
            color: context.success,
            onTap: () => context.push('/academic/courses'),
          ),
          _HubCard(
            icon: Icons.assignment,
            label: 'Assignments',
            subtitle: 'Track deadlines & submit',
            color: context.warning,
            onTap: () => context.push('/academic/assignments'),
          ),
          _HubCard(
            icon: Icons.event_note,
            label: 'Exam Prep',
            subtitle: 'Timetables & revision',
            color: context.error,
            onTap: () => context.push('/academic/exams'),
          ),
          _HubCard(
            icon: Icons.calculate,
            label: 'GPA Calculator',
            subtitle: 'Semester & CGPA',
            color: context.primary,
            onTap: () => context.push('/academic/gpa'),
          ),
          _HubCard(
            icon: Icons.calendar_month,
            label: 'Study Planner',
            subtitle: 'Plan your revision',
            color: context.info,
            onTap: () => context.push('/academic/planner'),
          ),
          _HubCard(
            icon: Icons.star,
            label: 'Top Resources',
            subtitle: 'Highest rated content',
            color: context.warning,
            onTap: () => context.push('/academic/resources', extra: {'type': null}),
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HubCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardBg,
      borderRadius: URadius.baseAll,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: URadius.baseAll,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: URadius.baseAll,
            border: Border.all(color: context.borderCol),
          ),
          padding: const EdgeInsets.all(USpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: URadius.mdAll,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(label,
                  style: UText.h4.copyWith(color: context.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: UText.caption.copyWith(color: context.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
