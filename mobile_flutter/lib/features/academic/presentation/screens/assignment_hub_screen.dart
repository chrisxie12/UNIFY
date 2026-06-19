import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/design_system/components.dart';

class AssignmentHubScreen extends ConsumerWidget {
  const AssignmentHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {},
            tooltip: 'Calendar view',
          ),
        ],
      ),
      body: UEmptyState(
        icon: Icons.assignment_outlined,
        title: 'Assignment tracking coming soon',
        subtitle: 'Select a course to view its assignments',
        actionLabel: 'Browse Courses',
        onAction: () => context.push('/academic/courses'),
      ),
    );
  }
}
