import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/widgets/app_empty_widget.dart';
import 'package:unify/core/widgets/app_error_widget.dart';
import 'package:unify/core/widgets/app_loading_widget.dart';
import 'package:unify/features/academic/data/models/academic_models.dart';
import 'package:unify/features/academic/presentation/providers/academic_provider.dart';
import 'package:unify/core/extensions/theme_extensions.dart';

class NotesRepositoryScreen extends ConsumerWidget {
  final String? courseId;
  final String? filterType;
  const NotesRepositoryScreen({super.key, this.courseId, this.filterType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resources = courseId != null
        ? ref.watch(resourcesByCourseProvider(courseId!))
        : filterType != null
            ? ref.watch(resourcesByTypeProvider(filterType!))
            : ref.watch(searchResourcesProvider(''));

    return Scaffold(
      appBar: AppBar(
        title: Text(filterType == 'past_question' ? 'Past Questions' : 'Notes Repository'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: resources.when(
        loading: () => const AppLoadingWidget.list(),
        error: (e, _) => AppErrorWidget(e),
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyWidget(
              icon: Icons.menu_book_rounded,
              title: 'No resources yet',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (_, i) => _ResourceListTile(resource: items[i], theme: theme),
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('All Resources'), onTap: () => Navigator.pop(context)),
            const _FilterOption('Notes', 'note'),
            const _FilterOption('Past Questions', 'past_question'),
            const _FilterOption('Study Guides', 'study_guide'),
            const _FilterOption('Flashcards', 'flashcard'),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final String type;
  const _FilterOption(this.label, this.type);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        context.pushReplacement('/academic/resources', extra: {'type': type});
      },
    );
  }
}

class _ResourceListTile extends StatelessWidget {
  final AcademicResourceModel resource;
  final ThemeData theme;
  const _ResourceListTile({required this.resource, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _fileColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_fileIcon, color: _fileColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(resource.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      ),
                      if (resource.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 10, color: Colors.blue[700]),
                              const SizedBox(width: 2),
                              Text('Verified', style: TextStyle(fontSize: 9, color: Colors.blue[700])),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      Text(' ${resource.averageRating.toStringAsFixed(1)}', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                      Text(' · ${resource.downloadCount} downloads', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                      if (resource.lecturer != null) ...[
                        Text(' · ${resource.lecturer}', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.download_outlined, color: theme.colorScheme.primary, size: 20),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Color get _fileColor {
    switch (resource.fileType) {
      case 'pdf': return Colors.red;
      case 'docx': case 'doc': return Colors.blue;
      case 'ppt': case 'pptx': return Colors.orange;
      case 'image': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData get _fileIcon {
    switch (resource.fileType) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'docx': return Icons.description;
      case 'ppt': case 'pptx': return Icons.slideshow;
      case 'image': return Icons.image;
      default: return Icons.insert_drive_file;
    }
  }
}
