import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import 'notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _client;
  NotificationRepositoryImpl(this._client);

  @override
  Future<List<NotificationModel>> getNotifications(String userId, {int limit = 20, String? cursor}) async {
    var query = _client
        .from('notifications')
        .select('*')
        .eq('user_id', userId);

    if (cursor != null) {
      query = query.lt('created_at', cursor);
    }

    final response = await query.order('created_at', ascending: false).limit(limit) as List;
    return response.map((j) => NotificationModel.fromJson(j)).toList();
  }

  @override
  Stream<List<NotificationModel>> notificationsStream(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50)
        .map((maps) => maps
            .map((m) => NotificationModel.fromJson(m))
            .toList());
  }

  @override
  Stream<int> unreadCountStream(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) => rows.where((r) => r['is_read'] == false).length);
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final response = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false)
        .limit(500) as List;
    return response.length;
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _client.from('notifications').update({'is_read': true}).eq('id', notificationId);
      return true;
    } catch (e) {
      debugPrint('[NotificationRepositoryImpl] markAsRead error: $e');
      return false;
    }
  }

  @override
  Future<String?> createNotification({
    required String userId,
    required String type,
    required String title,
    String? body,
    String? referenceId,
    String? referenceType,
    Map<String, dynamic>? data,
  }) async {
    try {
      final result = await _client.rpc('create_notification', params: {
        'p_user_id': userId,
        'p_type': type,
        'p_title': title,
        'p_body': body,
        'p_reference_id': referenceId,
        'p_reference_type': referenceType,
        'p_data': data ?? <String, dynamic>{},
      });
      return result?.toString();
    } catch (e) {
      debugPrint('[NotificationRepositoryImpl] createNotification error: $e');
      return null;
    }
  }

  @override
  Future<bool> markAllAsRead(String userId) async {
    try {
      await _client.from('notifications').update({'is_read': true}).eq('user_id', userId).eq('is_read', false);
      return true;
    } catch (e) {
      debugPrint('[NotificationRepositoryImpl] markAllAsRead error: $e');
      return false;
    }
  }

  // ── Preferences ──────────────────────────────────────────────────────

  @override
  Future<NotificationPreferences?> getPreferences(String userId) async {
    try {
      final response = await _client
          .from('notification_preferences')
          .select('*')
          .eq('user_id', userId)
          .single() as Map<String, dynamic>?;
      if (response == null) return null;
      return NotificationPreferences.fromJson(response);
    } catch (e) {
      debugPrint('[NotificationRepositoryImpl] getPreferences error: $e');
      return null;
    }
  }

  @override
  Future<void> updatePreferences(String userId, NotificationPreferences prefs) async {
    await _client.from('notification_preferences').upsert({
      'user_id': userId,
      ...prefs.toJson(),
    });
  }

  // ── Analytics logs ───────────────────────────────────────────────────

  @override
  Future<void> logEvent(String? notificationId, String userId, String type, String channel, String status,
      {String? deviceToken, String? errorMessage}) async {
    try {
      await _client.from('notification_logs').insert({
        if (notificationId != null) 'notification_id': notificationId,
        'user_id': userId,
        'type': type,
        'channel': channel,
        'status': status,
        if (deviceToken != null) 'device_token': deviceToken,
        if (errorMessage != null) 'error_message': errorMessage,
      });
    } catch (e) { debugPrint('[NotificationRepositoryImpl] logEvent error: $e'); }
  }

  @override
  Future<List<NotificationLog>> getAnalytics(String userId, {int days = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final response = await _client
        .from('notification_logs')
        .select('*')
        .eq('user_id', userId)
        .gt('created_at', cutoff)
        .order('created_at', ascending: false)
        .limit(500) as List;
    return response.map((j) => NotificationLog.fromJson(j)).toList();
  }

  // ── Device tokens ────────────────────────────────────────────────────

  @override
  Future<void> registerDeviceToken(String userId, String token, String platform) async {
    try {
      await _client.from('device_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': platform,
        'is_active': true,
      }, onConflict: 'token');
    } catch (e) { debugPrint('[NotificationRepositoryImpl] registerDeviceToken error: $e'); }
  }

  @override
  Future<void> unregisterDeviceToken(String token) async {
    try {
      await _client.from('device_tokens').update({'is_active': false}).eq('token', token);
    } catch (e) { debugPrint('[NotificationRepositoryImpl] unregisterDeviceToken error: $e'); }
  }
}
