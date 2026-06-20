import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../providers/event_provider.dart';
import 'package:unify/core/design_system/tokens.dart';
import 'package:unify/core/design_system/typography.dart';
import 'package:unify/core/design_system/components.dart';
import 'package:unify/core/extensions/theme_extensions.dart';

class EventMediaGalleryScreen extends ConsumerWidget {
  final String eventId;
  const EventMediaGalleryScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaAsync = ref.watch(eventMediaProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Media'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () {
              // Media upload placeholder
            },
          ),
        ],
      ),
      body: mediaAsync.when(
        loading: () => const AppLoadingWidget.list(),
        error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(eventMediaProvider(eventId))),
        data: (media) {
          if (media.isEmpty) {
            return const UEmptyState(
              icon: Icons.photo_library_outlined,
              title: 'No media yet',
              subtitle: 'Photos and videos will appear here after the event.',
            );
          }
          final photos = media.where((m) => m.isPhoto).toList();
          final videos = media.where((m) => m.isVideo).toList();
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'Photos (${photos.length})'),
                    Tab(text: 'Videos (${videos.length})'),
                  ],
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: context.textSecondary,
                  indicatorColor: theme.colorScheme.primary,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _PhotoGrid(photos: photos),
                      _VideoList(videos: videos),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<dynamic> photos;
  const _PhotoGrid({required this.photos});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Center(child: Text('No photos', style: UText.bodyS.copyWith(color: context.textSecondary)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(USpacing.sm),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: USpacing.xs,
        mainAxisSpacing: USpacing.xs,
      ),
      itemCount: photos.length,
      itemBuilder: (_, i) {
        final photo = photos[i];
        return GestureDetector(
          onTap: () => _showPhotoViewer(context, photo),
          child: ClipRRect(
            borderRadius: URadius.smAll,
            child: Image.network(photo.url as String, fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  void _showPhotoViewer(BuildContext context, dynamic photo) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: URadius.mdAll,
              child: Image.network(photo.url as String, fit: BoxFit.contain),
            ),
            if (photo.caption != null) ...[
              const SizedBox(height: USpacing.sm),
              Text(photo.caption as String, style: UText.bodyS.copyWith(color: Colors.white)),
            ],
          ],
        ),
      ),
    );
  }
}

class _VideoList extends StatelessWidget {
  final List<dynamic> videos;
  const _VideoList({required this.videos});

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return Center(child: Text('No videos', style: UText.bodyS.copyWith(color: context.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(USpacing.md),
      itemCount: videos.length,
      itemBuilder: (_, i) {
        final video = videos[i];
        return Card(
          margin: const EdgeInsets.only(bottom: USpacing.sm),
          child: ListTile(
            leading: Container(
              width: UIcon.x4, height: UIcon.x4,
              decoration: BoxDecoration(
                color: context.textSecondary,
                borderRadius: URadius.smAll,
              ),
              child: const Icon(Icons.play_circle_fill, color: Colors.white, size: UIcon.xl),
            ),
            title: Text(video.caption as String? ?? 'Video', style: UText.bodyS),
            trailing: const Icon(Icons.play_arrow),
            onTap: () {
              // Video player placeholder
            },
          ),
        );
      },
    );
  }
}
