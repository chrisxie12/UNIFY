import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/widgets/app_error_widget.dart';
import 'package:unify/core/widgets/app_loading_widget.dart';
import 'package:unify/features/academic/data/models/academic_models.dart';
import 'package:unify/features/academic/presentation/providers/academic_provider.dart';
import '../../../../core/extensions/theme_extensions.dart';

class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/academic/search'),
          ),
        ],
      ),
      body: coursesAsync.when(
        loading: () => const AppLoadingWidget.list(),
        error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(coursesProvider)),
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: context.borderCol),
                  const SizedBox(height: 16),
                  Text('No courses available', style: TextStyle(color: context.textSecondary, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Courses will appear when added by your department',
                      style: TextStyle(color: context.textSecondary, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: courses.length,
            itemBuilder: (_, i) => _CourseTile(course: courses[i], theme: theme),
          );
        },
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  final CourseModel course;
  final ThemeData theme;
  const _CourseTile({required this.course, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              course.code.substring(0, math.min(course.code.length, 4)).toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text('${course.code} - ${course.name}',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Row(
          children: [
            Text('${course.credits} credits', style: TextStyle(fontSize: 12, color: context.textSecondary)),
            if (course.lecturerName != null) ...[
              Text(' · ${course.lecturerName}', style: TextStyle(fontSize: 12, color: context.textSecondary)),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () => context.push('/academic/course/${course.id}'),
      ),
    );
  }
}
