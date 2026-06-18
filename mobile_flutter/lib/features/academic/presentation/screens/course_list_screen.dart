import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/features/academic/data/models/academic_models.dart';
import 'package:unify/features/academic/presentation/providers/academic_provider.dart';

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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No courses available', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Courses will appear when added by your department',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13)),
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
            Text('${course.credits} credits', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            if (course.lecturerName != null) ...[
              Text(' · ${course.lecturerName}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () => context.push('/academic/course/${course.id}'),
      ),
    );
  }
}
