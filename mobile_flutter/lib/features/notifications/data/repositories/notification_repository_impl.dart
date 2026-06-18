import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import 'notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _client;

  NotificationRepositoryImpl(this._client);

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final response = await _client
        .from('notifications')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50) as List;

    return response
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final response = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false) as List;

    return response.length;
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _client.from('notifications').update({'is_read': true}).filter('id', 'eq', notificationId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> markAllAsRead(String userId) async {
    try {
      await _client.from('notifications').update({'is_read': true}).filter('user_id', 'eq', userId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
