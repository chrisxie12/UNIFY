import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_provider.dart';

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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (media) {
          if (media.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No media yet', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Photos and videos will appear here after the event.', style: TextStyle(color: Colors.grey[400], fontSize: 13), textAlign: TextAlign.center),
                ],
              ),
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
                  unselectedLabelColor: Colors.grey,
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
      return Center(child: Text('No photos', style: TextStyle(color: Colors.grey[500])));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: photos.length,
      itemBuilder: (_, i) {
        final photo = photos[i];
        return GestureDetector(
          onTap: () => _showPhotoViewer(context, photo),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
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
              borderRadius: BorderRadius.circular(12),
              child: Image.network(photo.url as String, fit: BoxFit.contain),
            ),
            if (photo.caption != null) ...[
              const SizedBox(height: 8),
              Text(photo.caption as String, style: const TextStyle(color: Colors.white, fontSize: 14)),
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
      return Center(child: Text('No videos', style: TextStyle(color: Colors.grey[500])));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: videos.length,
      itemBuilder: (_, i) {
        final video = videos[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
            ),
            title: Text(video.caption as String? ?? 'Video', style: const TextStyle(fontSize: 14)),
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
