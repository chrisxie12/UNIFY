import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/announcement_comment.dart';

class AnnouncementSocialRepository {
  final SupabaseClient _client;

  AnnouncementSocialRepository(this._client);

  String? get _uid => _client.auth.currentUser?.id;

  // ── Likes ────────────────────────────────────────────────────────────────

  Future<(bool isLiked, int count)> getLikeStatus(String announcementId) async {
    final uid = _uid;
    if (uid == null) return (false, 0);
    try {
      final results = await Future.wait([
        _client
            .from('announcement_likes')
            .select('id')
            .eq('announcement_id', announcementId)
            .eq('user_id', uid)
            .maybeSingle(),
        _client
            .from('announcements')
            .select('likes_count')
            .eq('id', announcementId)
            .single(),
      ]);
      final likeRow = results[0];
      final ann = results[1] as Map<String, dynamic>;
      return (likeRow != null, ann['likes_count'] as int? ?? 0);
    } catch (e) {
      debugPrint('[AnnouncementSocial] getLikeStatus error: $e');
      return (false, 0);
    }
  }

  /// Toggles like and returns the new (isLiked, count) state.
  Future<(bool, int)> toggleLike(String announcementId) async {
    final uid = _uid;
    if (uid == null) return (false, 0);
    try {
      final existing = await _client
          .from('announcement_likes')
          .select('id')
          .eq('announcement_id', announcementId)
          .eq('user_id', uid)
          .maybeSingle();

      if (existing != null) {
        await _client
            .from('announcement_likes')
            .delete()
            .eq('announcement_id', announcementId)
            .eq('user_id', uid);
      } else {
        await _client.from('announcement_likes').insert({
          'announcement_id': announcementId,
          'user_id': uid,
        });
      }

      final ann = await _client
          .from('announcements')
          .select('likes_count')
          .eq('id', announcementId)
          .single();
      return (existing == null, ann['likes_count'] as int? ?? 0);
    } catch (e) {
      debugPrint('[AnnouncementSocial] toggleLike error: $e');
      rethrow;
    }
  }

  // ── Comments ─────────────────────────────────────────────────────────────

  Future<List<AnnouncementComment>> getComments(String announcementId) async {
    try {
      final data = await _client
          .from('announcement_comments')
          .select('*, profiles!author_id(full_name, avatar_url)')
          .eq('announcement_id', announcementId)
          .order('created_at', ascending: true) as List<dynamic>;
      return data
          .map((e) => AnnouncementComment.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[AnnouncementSocial] getComments error: $e');
      return [];
    }
  }

  Future<AnnouncementComment?> addComment(String announcementId, String body) async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final row = await _client
          .from('announcement_comments')
          .insert({
            'announcement_id': announcementId,
            'author_id': uid,
            'body': body.trim(),
          })
          .select('*, profiles!author_id(full_name, avatar_url)')
          .single();
      return AnnouncementComment.fromJson(row);
    } catch (e) {
      debugPrint('[AnnouncementSocial] addComment error: $e');
      return null;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _client.from('announcement_comments').delete().eq('id', commentId);
    } catch (e) {
      debugPrint('[AnnouncementSocial] deleteComment error: $e');
    }
  }

  // ── Shares ───────────────────────────────────────────────────────────────

  Future<void> recordShare(String announcementId) async {
    try {
      final ann = await _client
          .from('announcements')
          .select('shares_count')
          .eq('id', announcementId)
          .single();
      final current = ann['shares_count'] as int? ?? 0;
      await _client
          .from('announcements')
          .update({'shares_count': current + 1})
          .eq('id', announcementId);
    } catch (e) {
      debugPrint('[AnnouncementSocial] recordShare error: $e');
    }
  }

  // ── Saves ────────────────────────────────────────────────────────────────

  Future<bool> getSaveStatus(String announcementId) async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      final row = await _client
          .from('announcement_saves')
          .select('id')
          .eq('announcement_id', announcementId)
          .eq('user_id', uid)
          .maybeSingle();
      return row != null;
    } catch (e) {
      debugPrint('[AnnouncementSocial] getSaveStatus error: $e');
      return false;
    }
  }

  Future<bool> toggleSave(String announcementId) async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      final existing = await _client
          .from('announcement_saves')
          .select('id')
          .eq('announcement_id', announcementId)
          .eq('user_id', uid)
          .maybeSingle();

      if (existing != null) {
        await _client
            .from('announcement_saves')
            .delete()
            .eq('announcement_id', announcementId)
            .eq('user_id', uid);
        return false;
      } else {
        await _client.from('announcement_saves').insert({
          'announcement_id': announcementId,
          'user_id': uid,
        });
        return true;
      }
    } catch (e) {
      debugPrint('[AnnouncementSocial] toggleSave error: $e');
      rethrow;
    }
  }

  Future<List<String>> getSavedAnnouncementIds() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final rows = await _client
          .from('announcement_saves')
          .select('announcement_id')
          .eq('user_id', uid)
          .order('created_at', ascending: false) as List<dynamic>;
      return rows.map((r) => r['announcement_id'] as String).toList();
    } catch (e) {
      debugPrint('[AnnouncementSocial] getSavedAnnouncementIds error: $e');
      return [];
    }
  }

  // ── Hidden posts ─────────────────────────────────────────────────────────

  Future<List<String>> getHiddenAnnouncementIds() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final rows = await _client
          .from('hidden_posts')
          .select('announcement_id')
          .eq('user_id', uid) as List<dynamic>;
      return rows.map((r) => r['announcement_id'] as String).toList();
    } catch (e) {
      debugPrint('[AnnouncementSocial] getHiddenAnnouncementIds error: $e');
      return [];
    }
  }

  Future<void> hidePost(String announcementId) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _client.from('hidden_posts').insert({
        'announcement_id': announcementId,
        'user_id': uid,
      });
    } catch (e) {
      debugPrint('[AnnouncementSocial] hidePost error: $e');
    }
  }

  // ── Reports ──────────────────────────────────────────────────────────────

  Future<void> reportPost({
    required String announcementId,
    required String reason,
    String? description,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _client.from('reports').insert({
        'reporter_id': uid,
        'report_type': 'announcement',
        'target_id': announcementId,
        'reason': reason,
        'description': description,
      });
    } catch (e) {
      debugPrint('[AnnouncementSocial] reportPost error: $e');
    }
  }
}
