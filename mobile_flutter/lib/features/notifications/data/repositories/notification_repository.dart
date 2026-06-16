import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications(String userId);
  Future<int> getUnreadCount(String userId);
  Future<bool> markAsRead(String notificationId);
  Future<bool> markAllAsRead(String userId);
}
