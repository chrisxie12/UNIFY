import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/snapshot_models.dart';

class SnapshotsRepositoryImpl {
  final SupabaseClient _client;
  SnapshotsRepositoryImpl(this._client);

  static const _authorJoin =
      'profiles!snapshots_author_id_fkey(full_name, avatar_url, is_verified_leader, leadership_role, university_id)';

  String get _nowIso => DateTime.now().toUtc().toIso8601String();

  // ── Feed (personal / public stories, grouped by author) ──────

  Future<List<SnapshotGroup>> getFeedGroups({
    String? universityId,
    required String userId,
  }) async {
    final data = await _client
        .from('snapshots')
        .select('*, $_authorJoin, snapshot_poll_options(*)')
        .isFilter('community_id', null)
        .gt('expires_at', _nowIso)
        .order('created_at', ascending: true);

    final muted = await _mutedIds(userId);
    final viewed = await _viewedIds(userId);

    final snaps = (data as List)
        .map((r) => SnapshotModel.fromJson(r as Map<String, dynamic>))
        .where((s) => !muted.contains(s.authorId))
        .toList();

    return _groupByAuthor(snaps, viewed);
  }

  // ── Community story feed ─────────────────────────────────────

  Future<List<SnapshotGroup>> getCommunitySnapshotGroups(
    String communityId, {
    required String userId,
  }) async {
    final data = await _client
        .from('snapshots')
        .select('*, $_authorJoin, snapshot_poll_options(*)')
        .eq('community_id', communityId)
        .gt('expires_at', _nowIso)
        .order('created_at', ascending: true);

    final muted = await _mutedIds(userId);
    final viewed = await _viewedIds(userId);

    final snaps = (data as List)
        .map((r) => SnapshotModel.fromJson(r as Map<String, dynamic>))
        .where((s) => !muted.contains(s.authorId))
        .toList();

    return _groupByAuthor(snaps, viewed);
  }

  // ── Trending (most-viewed active snapshots) ──────────────────

  Future<List<SnapshotModel>> getTrending({int limit = 10}) async {
    final data = await _client
        .from('snapshots')
        .select('*, $_authorJoin, snapshot_poll_options(*)')
        .gt('expires_at', _nowIso)
        .order('view_count', ascending: false)
        .limit(limit);
    return (data as List)
        .map((r) => SnapshotModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ── My snapshots ─────────────────────────────────────────────

  Future<List<SnapshotModel>> getMySnapshots(String userId) async {
    final data = await _client
        .from('snapshots')
        .select('*, $_authorJoin, snapshot_poll_options(*)')
        .eq('author_id', userId)
        .gt('expires_at', _nowIso)
        .order('created_at', ascending: false);
    return (data as List)
        .map((r) => SnapshotModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ── Create ───────────────────────────────────────────────────

  Future<String> uploadMedia(String userId, Uint8List bytes, String ext) async {
    final path =
        '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('snapshots').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('snapshots').getPublicUrl(path);
  }

  Future<void> createTextSnapshot({
    required String authorId,
    required String text,
    required String backgroundColor,
    String audience = 'public',
    String? communityId,
    bool isOfficial = false,
  }) async {
    await _client.from('snapshots').insert({
      'author_id': authorId,
      'type': 'text',
      'text_content': text,
      'background_color': backgroundColor,
      'audience': communityId != null ? 'community' : audience,
      if (communityId != null) 'community_id': communityId,
      'is_official': isOfficial,
    });
  }

  Future<void> createPhotoSnapshot({
    required String authorId,
    required String mediaUrl,
    String? caption,
    String audience = 'public',
    String? communityId,
    bool isOfficial = false,
  }) async {
    await _client.from('snapshots').insert({
      'author_id': authorId,
      'type': 'photo',
      'media_url': mediaUrl,
      if (caption != null && caption.isNotEmpty) 'caption': caption,
      'audience': communityId != null ? 'community' : audience,
      if (communityId != null) 'community_id': communityId,
      'is_official': isOfficial,
    });
  }

  Future<void> createPollSnapshot({
    required String authorId,
    required String question,
    required List<String> options,
    String audience = 'public',
    String? communityId,
    bool isOfficial = false,
  }) async {
    final inserted = await _client
        .from('snapshots')
        .insert({
          'author_id': authorId,
          'type': 'poll',
          'text_content': question,
          'background_color': '#0F172A',
          'audience': communityId != null ? 'community' : audience,
          if (communityId != null) 'community_id': communityId,
          'is_official': isOfficial,
        })
        .select('id')
        .single();

    final snapshotId = inserted['id'] as String;
    final rows = <Map<String, dynamic>>[];
    for (var i = 0; i < options.length; i++) {
      rows.add({
        'snapshot_id': snapshotId,
        'label': options[i],
        'position': i,
      });
    }
    if (rows.isNotEmpty) {
      await _client.from('snapshot_poll_options').insert(rows);
    }
  }

  Future<void> createQuestionSnapshot({
    required String authorId,
    required String prompt,
    String audience = 'public',
    String? communityId,
    bool isOfficial = false,
  }) async {
    await _client.from('snapshots').insert({
      'author_id': authorId,
      'type': 'question',
      'text_content': prompt,
      'background_color': '#7C3AED',
      'audience': communityId != null ? 'community' : audience,
      if (communityId != null) 'community_id': communityId,
      'is_official': isOfficial,
    });
  }

  Future<void> deleteSnapshot(String snapshotId) async {
    await _client.from('snapshots').delete().eq('id', snapshotId);
  }

  // ── Interactions ─────────────────────────────────────────────

  Future<void> recordView(String snapshotId, String viewerId) async {
    // Ignore duplicate (PK conflict) — view already recorded.
    try {
      await _client.from('snapshot_views').insert({
        'snapshot_id': snapshotId,
        'viewer_id': viewerId,
      });
    } catch (_) {
      // already viewed
    }
  }

  /// Toggles a reaction. Returns the resulting emoji, or null if cleared.
  Future<String?> toggleReaction(
    String snapshotId,
    String userId,
    String emoji,
  ) async {
    final existing = await _client
        .from('snapshot_reactions')
        .select('emoji')
        .eq('snapshot_id', snapshotId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null && existing['emoji'] == emoji) {
      await _client
          .from('snapshot_reactions')
          .delete()
          .eq('snapshot_id', snapshotId)
          .eq('user_id', userId);
      return null;
    }

    await _client.from('snapshot_reactions').upsert({
      'snapshot_id': snapshotId,
      'user_id': userId,
      'emoji': emoji,
    });
    return emoji;
  }

  Future<String?> myReaction(String snapshotId, String userId) async {
    final r = await _client
        .from('snapshot_reactions')
        .select('emoji')
        .eq('snapshot_id', snapshotId)
        .eq('user_id', userId)
        .maybeSingle();
    return r?['emoji'] as String?;
  }

  Future<void> sendReply({
    required String snapshotId,
    required String senderId,
    required String recipientId,
    required String body,
  }) async {
    await _client.from('snapshot_replies').insert({
      'snapshot_id': snapshotId,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'body': body,
    });
  }

  Future<void> votePoll({
    required String snapshotId,
    required String optionId,
    required String userId,
  }) async {
    await _client.from('snapshot_poll_votes').insert({
      'snapshot_id': snapshotId,
      'option_id': optionId,
      'user_id': userId,
    });
  }

  Future<String?> myPollVote(String snapshotId, String userId) async {
    final r = await _client
        .from('snapshot_poll_votes')
        .select('option_id')
        .eq('snapshot_id', snapshotId)
        .eq('user_id', userId)
        .maybeSingle();
    return r?['option_id'] as String?;
  }

  // ── Safety ───────────────────────────────────────────────────

  Future<void> reportSnapshot({
    required String snapshotId,
    required String reporterId,
    required String reason,
  }) async {
    await _client.from('snapshot_reports').insert({
      'snapshot_id': snapshotId,
      'reporter_id': reporterId,
      'reason': reason,
    });
  }

  Future<void> muteAuthor(String muterId, String mutedId) async {
    await _client.from('snapshot_mutes').upsert({
      'muter_id': muterId,
      'muted_id': mutedId,
    });
  }

  // ── Analytics ────────────────────────────────────────────────

  Future<SnapshotAnalytics> getAnalytics(String snapshotId) async {
    final snap = await _client
        .from('snapshots')
        .select('view_count, reaction_count, reply_count')
        .eq('id', snapshotId)
        .maybeSingle();

    final viewsData = await _client
        .from('snapshot_views')
        .select('viewer_id, viewed_at, profiles!snapshot_views_viewer_id_fkey(full_name, avatar_url)')
        .eq('snapshot_id', snapshotId)
        .order('viewed_at', ascending: false);

    final reactionsData = await _client
        .from('snapshot_reactions')
        .select('emoji')
        .eq('snapshot_id', snapshotId);

    final byEmoji = <String, int>{};
    for (final r in reactionsData as List) {
      final e = r['emoji'] as String;
      byEmoji[e] = (byEmoji[e] ?? 0) + 1;
    }

    final viewers = (viewsData as List)
        .map((r) => SnapshotViewer.fromJson(r as Map<String, dynamic>))
        .toList();

    return SnapshotAnalytics(
      viewCount: snap?['view_count'] as int? ?? viewers.length,
      reactionCount: snap?['reaction_count'] as int? ?? 0,
      replyCount: snap?['reply_count'] as int? ?? 0,
      reactionsByEmoji: byEmoji,
      viewers: viewers,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  Future<Set<String>> _viewedIds(String userId) async {
    final data = await _client
        .from('snapshot_views')
        .select('snapshot_id')
        .eq('viewer_id', userId);
    return (data as List).map((r) => r['snapshot_id'] as String).toSet();
  }

  Future<Set<String>> _mutedIds(String userId) async {
    final data = await _client
        .from('snapshot_mutes')
        .select('muted_id')
        .eq('muter_id', userId);
    return (data as List).map((r) => r['muted_id'] as String).toSet();
  }

  List<SnapshotGroup> _groupByAuthor(
    List<SnapshotModel> snaps,
    Set<String> viewed,
  ) {
    final byAuthor = <String, List<SnapshotModel>>{};
    for (final s in snaps) {
      byAuthor.putIfAbsent(s.authorId, () => []).add(s);
    }

    final groups = byAuthor.entries.map((e) {
      final list = e.value..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final first = list.first;
      final hasUnseen = list.any((s) => !viewed.contains(s.id));
      return SnapshotGroup(
        authorId: e.key,
        authorName: first.authorName,
        authorAvatar: first.authorAvatar,
        authorIsVerified: first.authorIsVerified,
        authorLeadershipRole: first.authorLeadershipRole,
        snapshots: list,
        hasUnseen: hasUnseen,
      );
    }).toList();

    // Priority order:
    //   1. Verified leaders first (official stories)
    //   2. Unseen before seen
    //   3. Most recent activity
    groups.sort((a, b) {
      if (a.isOfficial != b.isOfficial) return a.isOfficial ? -1 : 1;
      if (a.hasUnseen != b.hasUnseen) return a.hasUnseen ? -1 : 1;
      return b.latestAt.compareTo(a.latestAt);
    });

    return groups;
  }
}
