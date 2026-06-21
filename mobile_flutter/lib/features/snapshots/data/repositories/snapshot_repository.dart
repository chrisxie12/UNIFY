import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/snapshot_models.dart';

class SnapshotRepository {
  final SupabaseClient _client;

  SnapshotRepository(this._client);

  String? get _uid => _client.auth.currentUser?.id;

  /// Returns active (non-expired, public) story groups from the current user's
  /// university, grouped by author and sorted by latest story time.
  Future<List<SnapshotGroup>> listActiveGroups() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      // Fetch snapshots from same university peers (including own)
      final data = await _client
          .from('snapshots')
          .select('*, profiles!author_id(full_name, avatar_url, is_verified_leader, leadership_role), snapshot_poll_options(*)')
          .eq('audience', 'public')
          .gt('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false)
          .limit(200) as List<dynamic>;

      // Fetch which snapshots current user has already viewed
      final Set<String> viewedIds = {};
      if (data.isNotEmpty) {
        final allIds = data.map((e) => (e as Map)['id'] as String).toList();
        final viewed = await _client
            .from('snapshot_views')
            .select('snapshot_id')
            .eq('viewer_id', uid)
            .filter('snapshot_id', 'in', '(${allIds.join(',')})') as List<dynamic>;
        viewedIds.addAll(viewed.map((v) => (v as Map)['snapshot_id'] as String));
      }

      final snapshots = data
          .map((e) => SnapshotModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Group by author
      final Map<String, List<SnapshotModel>> byAuthor = {};
      for (final s in snapshots) {
        byAuthor.putIfAbsent(s.authorId, () => []).add(s);
      }

      // Build groups with unseen status
      final groups = byAuthor.entries.map((entry) {
        final list = entry.value..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        final first = list.first;
        final hasUnseen = list.any((s) => !viewedIds.contains(s.id));
        return SnapshotGroup(
          authorId: entry.key,
          authorName: first.authorName,
          authorAvatar: first.authorAvatar,
          authorIsVerified: first.authorIsVerified,
          authorLeadershipRole: first.authorLeadershipRole,
          snapshots: list,
          hasUnseen: hasUnseen,
        );
      }).toList();

      // Sort: current user's own story first, then by unseen + latest
      groups.sort((a, b) {
        if (a.authorId == uid) return -1;
        if (b.authorId == uid) return 1;
        if (a.hasUnseen != b.hasUnseen) return a.hasUnseen ? -1 : 1;
        return b.latestAt.compareTo(a.latestAt);
      });

      return groups;
    } catch (e) {
      debugPrint('[SnapshotRepository] listActiveGroups error: $e');
      return [];
    }
  }

  /// Returns the current user's own active story, if any.
  Future<SnapshotGroup?> getMyGroup() async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final data = await _client
          .from('snapshots')
          .select('*, profiles!author_id(full_name, avatar_url, is_verified_leader, leadership_role), snapshot_poll_options(*)')
          .eq('author_id', uid)
          .gt('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: true) as List<dynamic>;
      if (data.isEmpty) return null;
      final snapshots = data
          .map((e) => SnapshotModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final first = snapshots.first;
      return SnapshotGroup(
        authorId: uid,
        authorName: first.authorName,
        authorAvatar: first.authorAvatar,
        authorIsVerified: first.authorIsVerified,
        snapshots: snapshots,
        hasUnseen: false, // own stories are always "seen"
      );
    } catch (e) {
      debugPrint('[SnapshotRepository] getMyGroup error: $e');
      return null;
    }
  }

  /// Marks a snapshot as viewed by the current user.
  Future<void> markViewed(String snapshotId) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _client.from('snapshot_views').upsert({
        'snapshot_id': snapshotId,
        'viewer_id': uid,
      });
    } catch (e) {
      debugPrint('[SnapshotRepository] markViewed error: $e');
    }
  }

  /// Creates a text story.
  Future<SnapshotModel?> createTextStory({
    required String text,
    String backgroundColor = '#1E40AF',
    String? caption,
  }) async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final row = await _client
          .from('snapshots')
          .insert({
            'author_id': uid,
            'type': 'text',
            'text_content': text.trim(),
            'background_color': backgroundColor,
            'caption': caption?.trim(),
            'audience': 'public',
          })
          .select('*, profiles!author_id(full_name, avatar_url, is_verified_leader, leadership_role), snapshot_poll_options(*)')
          .single();
      return SnapshotModel.fromJson(row);
    } catch (e) {
      debugPrint('[SnapshotRepository] createTextStory error: $e');
      return null;
    }
  }

  /// Uploads a photo and creates a photo story.
  Future<SnapshotModel?> createPhotoStory({
    required File imageFile,
    String? caption,
  }) async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final ext = imageFile.path.split('.').last.toLowerCase();
      final path = 'stories/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _client.storage.from('stories').upload(path, imageFile);
      final publicUrl = _client.storage.from('stories').getPublicUrl(path);

      final row = await _client
          .from('snapshots')
          .insert({
            'author_id': uid,
            'type': 'photo',
            'media_url': publicUrl,
            'caption': caption?.trim(),
            'audience': 'public',
          })
          .select('*, profiles!author_id(full_name, avatar_url, is_verified_leader, leadership_role), snapshot_poll_options(*)')
          .single();
      return SnapshotModel.fromJson(row);
    } catch (e) {
      debugPrint('[SnapshotRepository] createPhotoStory error: $e');
      return null;
    }
  }

  /// Deletes a story owned by the current user.
  Future<void> deleteStory(String snapshotId) async {
    try {
      await _client.from('snapshots').delete().eq('id', snapshotId);
    } catch (e) {
      debugPrint('[SnapshotRepository] deleteStory error: $e');
    }
  }
}
