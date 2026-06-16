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
        .order('created_at', ascending: false) as List;

    return response
        .where((n) => n['user_id'] == userId)
        .take(50)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final response = await _client
        .from('notifications')
        .select('id')
        .order('created_at', ascending: false) as List;

    return response.where((n) => n['user_id'] == userId && n['is_read'] == false).length;
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
