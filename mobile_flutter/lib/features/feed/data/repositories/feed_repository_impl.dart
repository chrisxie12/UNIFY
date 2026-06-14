import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/feed_repository.dart';
import '../models/announcement_model.dart';

class FeedRepositoryImpl implements FeedRepository {
  final SupabaseClient _client;

  FeedRepositoryImpl(this._client);

  Box<String> get _box => Hive.box<String>(AppConstants.feedCacheBox);
  static const _cacheKey = 'announcements_page1';

  @override
  Future<List<AnnouncementEntity>> getAnnouncements({
    int pageSize = AppConstants.feedPageSize,
    DateTime? after,
  }) async {
    // Return cached data on first page load when available
    if (after == null && _box.containsKey(_cacheKey)) {
      try {
        final raw = _box.get(_cacheKey)!;
        final list = (jsonDecode(raw) as List)
            .cast<Map<String, dynamic>>()
            .map(AnnouncementModel.fromJson)
            .toList();
        if (list.isNotEmpty) {
          // Refresh in background
          _fetchAndCache(pageSize: pageSize);
          return list;
        }
      } catch (_) {
        // Corrupted cache — fall through to network
      }
    }

    return _fetchAndCache(pageSize: pageSize, after: after);
  }

  @override
  Future<List<AnnouncementEntity>> refreshAnnouncements({
    int pageSize = AppConstants.feedPageSize,
  }) =>
      _fetchAndCache(pageSize: pageSize);

  Future<List<AnnouncementEntity>> _fetchAndCache({
    int pageSize = AppConstants.feedPageSize,
    DateTime? after,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    var query = _client
        .from('announcements')
        .select('id, university_id, author_id, title, body, category, is_published, published_at, expires_at, created_at, updated_at')
        .eq('is_published', true)
        .or('expires_at.is.null,expires_at.gt.$now')
        .order('published_at', ascending: false)
        .limit(pageSize);

    if (after != null) {
      query = query.lt('published_at', after.toUtc().toIso8601String());
    }

    final data = await query;
    final models = (data as List)
        .cast<Map<String, dynamic>>()
        .map(AnnouncementModel.fromJson)
        .toList();

    // Cache first page
    if (after == null && models.isNotEmpty) {
      await _box.put(
        _cacheKey,
        jsonEncode(models.map((m) => m.toJson()).toList()),
      );
    }

    return models;
  }

  @override
  Future<AnnouncementEntity> createAnnouncement({
    required String title,
    required String body,
    required String category,
    required String universityId,
    required String authorId,
  }) async {
    final data = await _client.from('announcements').insert({
      'title': title,
      'body': body,
      'category': category,
      'university_id': universityId,
      'author_id': authorId,
      'is_published': false,
    }).select().single();
    return AnnouncementModel.fromJson(data);
  }

  @override
  Future<AnnouncementEntity> updateAnnouncement({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    final data = await _client
        .from('announcements')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return AnnouncementModel.fromJson(data);
  }

  @override
  Future<void> togglePublish(String id, {required bool publish}) async {
    await _client
        .from('announcements')
        .update({'is_published': publish})
        .eq('id', id);
  }

  @override
  Future<void> markAsRead(String announcementId, String userId) async {
    await _client.from('announcement_reads').upsert({
      'announcement_id': announcementId,
      'user_id': userId,
    });
  }
}
