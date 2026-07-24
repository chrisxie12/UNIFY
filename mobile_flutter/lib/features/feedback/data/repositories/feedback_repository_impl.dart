import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/feedback_models.dart';

class FeedbackRepositoryImpl {
  final SupabaseClient _client;
  FeedbackRepositoryImpl(this._client);

  static const _reporterJoin =
      'profiles!feedback_items_user_id_fkey(full_name, avatar_url)';

  static const _select = '*, $_reporterJoin';

  /// Uploads a screenshot to the public `feedback` bucket and returns its URL.
  Future<String> uploadScreenshot(String userId, Uint8List bytes) async {
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage.from('feedback').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('feedback').getPublicUrl(path);
  }

  Future<FeedbackItem> submit({
    required String userId,
    required String type,
    required String title,
    required String description,
    String? screenshotUrl,
    required String deviceInfo,
    required String appVersion,
    required String platform,
  }) async {
    final data = await _client
        .from('feedback_items')
        .insert({
          'user_id': userId,
          'type': type,
          'title': title,
          'description': description,
          'screenshot_url': screenshotUrl,
          'device_info': deviceInfo,
          'app_version': appVersion,
          'platform': platform,
        })
        .select(_select)
        .single();
    return FeedbackItem.fromJson(data);
  }

  Future<List<FeedbackItem>> getMine(String userId) async {
    final data = await _client
        .from('feedback_items')
        .select(_select)
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);
    return (data as List)
        .map((r) => FeedbackItem.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<FeedbackItem>> getAll({String? status}) async {
    var q = _client.from('feedback_items').select(_select);
    if (status != null) q = q.eq('status', status);
    final data = await q.order('created_at', ascending: false).limit(200);
    return (data as List)
        .map((r) => FeedbackItem.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> setStatus(
    String id,
    String status, {
    String? adminResponse,
    String? resolvedBy,
  }) async {
    final patch = <String, dynamic>{
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (adminResponse != null) patch['admin_response'] = adminResponse;
    if (resolvedBy != null) patch['resolved_by'] = resolvedBy;
    await _client.from('feedback_items').update(patch).eq('id', id);
  }

  Future<Map<String, int>> countsByStatus() async {
    final data = await _client.from('feedback_items').select('status').limit(100);
    final counts = <String, int>{
      for (final s in FeedbackStatus.all) s: 0,
    };
    for (final row in (data as List)) {
      final s = (row as Map<String, dynamic>)['status'] as String? ?? '';
      counts[s] = (counts[s] ?? 0) + 1;
    }
    return counts;
  }
}
