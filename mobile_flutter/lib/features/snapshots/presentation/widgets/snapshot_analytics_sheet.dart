import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/theme/app_colors.dart';
import '../../data/models/snapshot_models.dart';
import '../providers/snapshots_provider.dart';
import '../../../../core/extensions/theme_extensions.dart';

/// Bottom sheet showing reach, reactions and viewer list for a leader's
/// snapshot. Opened from the viewer's "Insights" action.
class SnapshotAnalyticsSheet extends ConsumerWidget {
  final String snapshotId;
  const SnapshotAnalyticsSheet({super.key, required this.snapshotId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(snapshotAnalyticsProvider(snapshotId));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: async.when(
            loading: () => const Center(
              heightFactor: 6,
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => Center(
              heightFactor: 6,
              child: Text('Could not load insights',
                  style: TextStyle(color: context.textSecondary)),
            ),
            data: (a) => CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(child: _grabber(context)),
                SliverToBoxAdapter(child: _statsRow(context, a)),
                if (a.reactionsByEmoji.isNotEmpty)
                  SliverToBoxAdapter(child: _reactionsRow(context, a)),
                SliverToBoxAdapter(child: _viewersHeader(context, a.viewers.length)),
                if (a.viewers.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text('No views yet',
                            style: TextStyle(color: context.textDisabled)),
                      ),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: a.viewers.length,
                    itemBuilder: (_, i) => _ViewerRow(viewer: a.viewers[i]),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _grabber(BuildContext context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: context.borderCol,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _statsRow(BuildContext context, SnapshotAnalytics a) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          _stat(context, 'Views', a.viewCount, Icons.remove_red_eye_rounded),
          _stat(context, 'Reactions', a.reactionCount, Icons.favorite_rounded),
          _stat(context, 'Replies', a.replyCount, Icons.reply_rounded),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, int value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 6),
            Text('$value',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: context.textPrimary)),
            Text(label, style: TextStyle(fontSize: 12, color: context.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _reactionsRow(BuildContext context, SnapshotAnalytics a) {
    final entries = a.reactionsByEmoji.entries.toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Wrap(
        spacing: 8,
        children: entries
            .map((e) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${e.key} ${e.value}',
                      style: const TextStyle(fontSize: 14)),
                ))
            .toList(),
      ),
    );
  }

  Widget _viewersHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Icon(Icons.visibility_rounded, size: 18, color: context.textSecondary),
          const SizedBox(width: 8),
          Text('Viewed by $count',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
        ],
      ),
    );
  }
}

class _ViewerRow extends StatelessWidget {
  final SnapshotViewer viewer;
  const _ViewerRow({required this.viewer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFDDE8FF),
        backgroundImage:
            viewer.avatar != null && viewer.avatar!.isNotEmpty
                ? CachedNetworkImageProvider(viewer.avatar!)
                : null,
        child: viewer.avatar == null || viewer.avatar!.isEmpty
            ? Text(viewer.initials,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700))
            : null,
      ),
      title: Text(viewer.name ?? 'Student',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: Text(
        timeago.format(viewer.viewedAt),
        style: TextStyle(fontSize: 12, color: context.textDisabled),
      ),
    );
  }
}