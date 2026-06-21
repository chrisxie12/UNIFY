import '../models/notification_model.dart';

abstract class NotificationRepository {
  /// Fetch notifications with cursor-based pagination.
  Future<List<NotificationModel>> getNotifications(String userId, {int limit, String? cursor});

  /// Realtime stream of notifications (latest 50).
  Stream<List<NotificationModel>> notificationsStream(String userId);

  /// Live unread count via Realtime stream.
  Stream<int> unreadCountStream(String userId);

  Future<int> getUnreadCount(String userId);
  Future<bool> markAsRead(String notificationId);
  Future<bool> markAllAsRead(String userId);

  /// Create a notification via the create_notification DB function.
  /// Returns the new notification UUID, or null if blocked by user preferences.
  Future<String?> createNotification({
    required String userId,
    required String type,
    required String title,
    String? body,
    String? referenceId,
    String? referenceType,
    Map<String, dynamic>? data,
  });

  /// Preferences
  Future<NotificationPreferences?> getPreferences(String userId);
  Future<void> updatePreferences(String userId, NotificationPreferences prefs);

  /// Notification logs (analytics)
  Future<void> logEvent(String? notificationId, String userId, String type, String channel, String status, {String? deviceToken, String? errorMessage});
  Future<List<NotificationLog>> getAnalytics(String userId, {int days = 30});

  /// Device token management for push
  Future<void> registerDeviceToken(String userId, String token, String platform);
  Future<void> unregisterDeviceToken(String token);
}
