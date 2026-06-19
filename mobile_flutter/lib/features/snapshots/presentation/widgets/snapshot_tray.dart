import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../data/models/snapshot_models.dart';
import '../providers/snapshots_provider.dart';
import '../screens/snapshot_composer_screen.dart';
import '../screens/snapshot_viewer_screen.dart';

/// Horizontal tray of active snapshots, shown at the top of the feed.
/// Verified-leader (official) stories appear first with a gold ring + badge.
class SnapshotTray extends ConsumerWidget {
  final String? communityId;
  const SnapshotTray({super.key, this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = communityId == null
        ? ref.watch(snapshotFeedProvider)
        : ref.watch(communitySnapshotsProvider(communityId!));

    return Container(
      color: context.cardBg,
      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      child: SizedBox(
        height: 96,
        child: groupsAsync.when(
          loading: () => _buildRow(context, ref, const []),
          error: (_, __) => _buildRow(context, ref, const []),
          data: (groups) => _buildRow(context, ref, groups),
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    WidgetRef ref,
    List<SnapshotGroup> groups,
  ) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: groups.length + 1,
      separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemBuilder: (context, i) {
        if (i == 0) {
          return _AddSnapshotButton(communityId: communityId);
        }
        final group = groups[i - 1];
        return _SnapshotRing(
          group: group,
          onTap: () => _openViewer(context, ref, groups, i - 1),
        );
      },
    );
  }

  void _openViewer(
    BuildContext context,
    WidgetRef ref,
    List<SnapshotGroup> groups,
    int startIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SnapshotViewerScreen(
          groups: groups,
          startGroupIndex: startIndex,
        ),
      ),
    ).then((_) {
      // Refresh seen-state when the viewer closes.
      if (communityId == null) {
        ref.invalidate(snapshotFeedProvider);
      } else {
        ref.invalidate(communitySnapshotsProvider(communityId!));
      }
    });
  }
}

// ── "Your Snapshot" add button ───────────────────────────────

class _AddSnapshotButton extends StatelessWidget {
  final String? communityId;
  const _AddSnapshotButton({this.communityId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => SnapshotComposerScreen(communityId: communityId),
        ),
      ),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.cardBg,
                border: Border.all(color: context.borderCol, width: 1.5),
              ),
              child: Icon(Icons.add_rounded, color: context.primary, size: 28),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your Snap',
              style: TextStyle(fontSize: 11, color: context.textPrimary, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Author ring ──────────────────────────────────────────────

class _SnapshotRing extends StatelessWidget {
  final SnapshotGroup group;
  final VoidCallback onTap;
  const _SnapshotRing({required this.group, required this.onTap});

  static const _officialRing = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFF8A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const _unseenRing = LinearGradient(
    colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final gradient = group.isOfficial
        ? _officialRing
        : group.hasUnseen
            ? _unseenRing
            : null;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: gradient,
                    color: gradient == null ? AppColors.border : null,
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.cardBg,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(child: _avatar()),
                  ),
                ),
                if (group.isOfficial)
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: context.cardBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.verified_rounded,
                          size: 16, color: context.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              group.authorName?.split(' ').first ?? 'User',
              style: TextStyle(
                fontSize: 11,
                color: context.textPrimary,
                fontWeight: group.hasUnseen ? FontWeight.w600 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    if (group.authorAvatar != null && group.authorAvatar!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: group.authorAvatar!,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
        errorWidget: (_, __, ___) => _initials(),
      );
    }
    return _initials();
  }

  Widget _initials() => Container(
        color: const Color(0xFFDDE8FF),
        alignment: Alignment.center,
        child: Text(
          group.initials,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      );
}
