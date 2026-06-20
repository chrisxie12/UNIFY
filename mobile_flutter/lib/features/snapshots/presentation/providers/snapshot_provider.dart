import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/snapshot_models.dart';
import '../../data/repositories/snapshot_repository.dart';

final snapshotRepositoryProvider = Provider<SnapshotRepository>((ref) {
  return SnapshotRepository(Supabase.instance.client);
});

/// All active story groups from the user's university (includes own group).
final storyGroupsProvider = AsyncNotifierProvider.autoDispose<StoryGroupsNotifier, List<SnapshotGroup>>(
  StoryGroupsNotifier.new,
);

class StoryGroupsNotifier extends AutoDisposeAsyncNotifier<List<SnapshotGroup>> {
  @override
  Future<List<SnapshotGroup>> build() async {
    final repo = ref.read(snapshotRepositoryProvider);
    return repo.listActiveGroups();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(snapshotRepositoryProvider).listActiveGroups());
  }

  Future<bool> createTextStory({
    required String text,
    String backgroundColor = '#1E40AF',
    String? caption,
  }) async {
    final repo = ref.read(snapshotRepositoryProvider);
    final story = await repo.createTextStory(
      text: text,
      backgroundColor: backgroundColor,
      caption: caption,
    );
    if (story != null) await refresh();
    return story != null;
  }

  Future<bool> createPhotoStory({required File imageFile, String? caption}) async {
    final repo = ref.read(snapshotRepositoryProvider);
    final story = await repo.createPhotoStory(imageFile: imageFile, caption: caption);
    if (story != null) await refresh();
    return story != null;
  }

  Future<void> markViewed(String snapshotId) async {
    await ref.read(snapshotRepositoryProvider).markViewed(snapshotId);
    // Update hasUnseen flag in local state
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.map((g) {
      final updated = g.snapshots.where((s) => s.id == snapshotId).isNotEmpty;
      if (!updated) return g;
      final stillUnseen = g.snapshots.any((s) => s.id != snapshotId && g.hasUnseen);
      return SnapshotGroup(
        authorId: g.authorId,
        authorName: g.authorName,
        authorAvatar: g.authorAvatar,
        authorIsVerified: g.authorIsVerified,
        authorLeadershipRole: g.authorLeadershipRole,
        snapshots: g.snapshots,
        hasUnseen: stillUnseen,
      );
    }).toList());
  }
}
