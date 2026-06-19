import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unify/core/widgets/app_error_widget.dart';
import 'package:unify/features/academic/data/models/academic_models.dart';
import 'package:unify/features/academic/presentation/providers/academic_provider.dart';

class CoursePageScreen extends ConsumerWidget {
  final String courseId;
  const CoursePageScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseProvider(courseId));
    final resourcesAsync = ref.watch(resourcesByCourseProvider(courseId));
    final assignmentsAsync = ref.watch(assignmentsProvider(courseId));
    final theme = Theme.of(context);

    return courseAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: AppErrorWidget(e, onRetry: () => ref.invalidate(courseProvider(courseId)))),
      data: (course) {
        if (course == null) return const Scaffold(body: Center(child: Text('Course not found')));
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.code, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(course.name, style: const TextStyle(fontSize: 15)),
                ],
              ),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(text: 'Notes'), Tab(text: 'Assignments'),
                  Tab(text: 'Past Qs'), Tab(text: 'Info'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _ResourceTab(resources: resourcesAsync, type: 'note'),
                _AssignmentTab(assignments: assignmentsAsync),
                _ResourceTab(resources: resourcesAsync, type: 'past_question'),
                _CourseInfoTab(course: course),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResourceTab extends StatelessWidget {
  final AsyncValue<List<AcademicResourceModel>> resources;
  final String type;
  const _ResourceTab({required this.resources, required this.type});

  @override
  Widget build(BuildContext context) {
    return resources.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AppErrorWidget(e),
      data: (items) {
        final filtered = items.where((r) => r.type == type).toList();
        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_open, size: 48, color: context.textSecondary]),
                const SizedBox(height: 12),
                Text('No ${type}s yet', style: TextStyle(color: context.textSecondary])),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filtered.length,
          itemBuilder: (_, i) => _ResourceItem(resource: filtered[i]),
        );
      },
    );
  }
}

class _ResourceItem extends StatelessWidget {
  final AcademicResourceModel resource;
  const _ResourceItem({required this.resource});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(_resourceIcon, color: theme.colorScheme.primary),
        title: Text(resource.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Row(
          children: [
            if (resource.isVerified)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.verified, size: 12, color: Colors.blue),
              ),
            Text('${resource.downloadCount} downloads', style: TextStyle(fontSize: 11, color: context.textSecondary])),
          ],
        ),
        trailing: const Icon(Icons.download_outlined, size: 20),
        onTap: () {},
      ),
    );
  }

  IconData get _resourceIcon {
    switch (resource.fileType) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'docx': return Icons.description;
      case 'ppt': case 'pptx': return Icons.slideshow;
      case 'image': return Icons.image;
      default: return Icons.insert_drive_file;
    }
  }
}

class _AssignmentTab extends StatelessWidget {
  final AsyncValue<List<AssignmentModel>> assignments;
  const _AssignmentTab({required this.assignments});

  @override
  Widget build(BuildContext context) {
    return assignments.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AppErrorWidget(e),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assignment_outlined, size: 48, color: context.textSecondary]),
                const SizedBox(height: 12),
                Text('No assignments yet', style: TextStyle(color: context.textSecondary])),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (_, i) => _AssignmentItem(assignment: items[i]),
        );
      },
    );
  }
}

class _AssignmentItem extends StatelessWidget {
  final AssignmentModel assignment;
  const _AssignmentItem({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = assignment.isOverdue && !assignment.isSubmitted;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: isOverdue ? Colors.red.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.assignment,
            size: 18,
            color: isOverdue ? Colors.red : theme.colorScheme.primary,
          ),
        ),
        title: Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(
          'Due: ${DateFormat('MMM d, h:mm a').format(assignment.dueDate)}',
          style: TextStyle(
            fontSize: 12,
            color: isOverdue ? Colors.red : Colors.grey[600],
            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: assignment.isSubmitted
            ? Icon(Icons.check_circle, color: Colors.green[400], size: 20)
            : TextButton(
                onPressed: () {},
                child: Text('Submit', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13)),
              ),
      ),
    );
  }
}

class _CourseInfoTab extends StatelessWidget {
  final CourseModel course;
  const _CourseInfoTab({required this.course});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Course Code', value: course.code),
          if (course.lecturerName != null) _InfoRow(label: 'Lecturer', value: course.lecturerName!),
          _InfoRow(label: 'Credits', value: '${course.credits}'),
          if (course.department != null) _InfoRow(label: 'Department', value: course.department!),
          if (course.faculty != null) _InfoRow(label: 'Faculty', value: course.faculty!),
          if (course.level != null) _InfoRow(label: 'Level', value: course.level!),
          if (course.semester != null) _InfoRow(label: 'Semester', value: course.semester!),
          if (course.description != null) ...[
            const SizedBox(height: 16),
            Text('Description', style: TextStyle(fontWeight: FontWeight.w600, color: context.textSecondary])),
            const SizedBox(height: 4),
            Text(course.description!, style: TextStyle(color: context.textSecondary], fontSize: 14)),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: context.textSecondary], fontSize: 14))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
