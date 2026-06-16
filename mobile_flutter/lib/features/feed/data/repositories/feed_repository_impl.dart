import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/feed_repository.dart';
import '../models/announcement_model.dart';

class FeedRepositoryImpl implements FeedRepository {
  final SupabaseClient _client;
  static const _boxName = AppConstants.feedBoxName;
  static const _cacheKey = 'feed_page_1';

  FeedRepositoryImpl(this._client);

  @override
  Future<List<Announcement>> getFeed({String? cursor, int limit = 20}) async {
    // Return cache for first page while network loads
    if (cursor == null) {
      final cached = await _loadCache();
      if (cached != null) return cached;
    }

    return _fetchFromNetwork(cursor: cursor, limit: limit);
  }

  @override
  Future<void> markRead(String announcementId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('announcement_reads').upsert({
      'announcement_id': announcementId,
      'user_id': userId,
    });
  }

  @override
  Future<void> refresh() async {
    final items = await _fetchFromNetwork();
    await _saveCache(items);
  }

  Future<List<AnnouncementModel>> _fetchFromNetwork({
    String? cursor,
    int limit = 20,
  }) async {
    final userId = _client.auth.currentUser?.id;

    var builder = _client
        .from('announcements')
        .select('*, profiles!announcements_author_id_fkey(display_name, avatar_url)');

    if (cursor != null) {
      builder = builder.lt('created_at', cursor);
    }

    final data = await builder
        .order('is_pinned', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit) as List<dynamic>;

    // Batch fetch read status
    Set<String> readIds = {};
    if (userId != null && data.isNotEmpty) {
      final ids = data.map((e) => e['id']).toList();
      final reads = await _client
          .from('announcement_reads')
          .select('announcement_id')
          .eq('user_id', userId)
          .inFilter('announcement_id', ids);
      readIds = (reads as List).map((r) => r['announcement_id'] as String).toSet();
    }

    final items = data.map((json) {
      final m = json as Map<String, dynamic>;
      return AnnouncementModel.fromJson({
        ...m,
        'is_read': readIds.contains(m['id']),
      });
    }).toList();

    if (cursor == null) await _saveCache(items);
    return items;
  }

  Future<List<AnnouncementModel>?> _loadCache() async {
    try {
      final box = await Hive.openBox(_boxName);
      final raw = box.get(_cacheKey) as String?;
      if (raw == null) return null;
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCache(List<AnnouncementModel> items) async {
    try {
      final box = await Hive.openBox(_boxName);
      final json = items.map((a) => {
        'id': a.id,
        'title': a.title,
        'body': a.body,
        'category': a.category,
        'author_id': a.authorId,
        'profiles': {'display_name': a.authorName, 'avatar_url': a.authorAvatar},
        'university_id': a.universityId,
        'is_pinned': a.isPinned,
        'is_urgent': a.isUrgent,
        'image_url': a.imageUrl,
        'view_count': a.viewCount,
        'created_at': a.createdAt.toIso8601String(),
        'is_read': a.isRead,
      }).toList();
      await box.put(_cacheKey, jsonEncode(json));
    } catch (_) {}
  }
}
