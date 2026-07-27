import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/feed_repository.dart';
import '../models/feed_item_model.dart';

class FeedRepositoryImpl implements FeedRepository {
  final SupabaseClient _client;
  static const _boxName = AppConstants.feedBoxName;
  static const _cacheKey = 'feed_page_1';

  FeedRepositoryImpl(this._client);

  @override
  Future<List<Announcement>> getFeed({(double score, DateTime createdAt)? cursor, int limit = 20}) async {
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

  Future<List<FeedItemModel>> _fetchFromNetwork({
    (double score, DateTime createdAt)? cursor,
    int limit = 20,
  }) async {
    final userId = _client.auth.currentUser?.id;

    final data = await _client.rpc('get_personalized_feed', params: {
      'p_user_id': userId,
      'p_lat': null,
      'p_lng': null,
      'p_limit': limit,
      if (cursor != null) 'p_cursor_score': cursor.$1,
      if (cursor != null) 'p_cursor_created_at': cursor.$2.toIso8601String(),
    }) as List<dynamic>;

    final items = data.map((json) {
      return FeedItemModel.fromRpcJson(json as Map<String, dynamic>);
    }).toList();

    if (cursor == null) await _saveCache(items);
    return items;
  }

  Future<List<FeedItemModel>?> _loadCache() async {
    try {
      final box = await Hive.openBox(_boxName);
      final raw = box.get(_cacheKey) as String?;
      if (raw == null) return null;
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => FeedItemModel.fromCacheJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[FeedRepositoryImpl] _loadCache error: $e');
      return null;
    }
  }

  Future<void> _saveCache(List<FeedItemModel> items) async {
    try {
      final box = await Hive.openBox(_boxName);
      final json = items.map((a) => a.toCacheJson()).toList();
      await box.put(_cacheKey, jsonEncode(json));
    } catch (e) {
      debugPrint('[FeedRepositoryImpl] _saveCache error: $e');
    }
  }
}
