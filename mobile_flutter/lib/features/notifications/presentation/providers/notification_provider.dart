import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/models/notification_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(Supabase.instance.client);
});

/// Current user ID (convenience)
final _userIdProvider = Provider<String?>((ref) {
  return ref.watch(currentAppUserProvider).valueOrNull?.id;
});

/// Realtime notifications list (latest 50). Automatically updates when new
/// notifications arrive via Supabase Realtime without manual refresh.
final notificationsProvider = StreamProvider.autoDispose<List<NotificationModel>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final userId = ref.watch(_userIdProvider);
  if (userId == null) return Stream.value([]);
  return repo.notificationsStream(userId);
});

/// Live unread count via Realtime subscription.
final unreadCountProvider = StreamProvider.autoDispose<int>((ref) {
  final userId = ref.watch(_userIdProvider);
  final repo = ref.watch(notificationRepositoryProvider);
  if (userId == null) return Stream.value(0);
  return repo.unreadCountStream(userId);
});

/// Single-shot unread count (for one-time reads).
final unreadCountOnceProvider = FutureProvider.autoDispose<int>((ref) async {
  final userId = ref.watch(_userIdProvider);
  if (userId == null) return 0;
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getUnreadCount(userId);
});

/// Notification preferences for the current user.
final notificationPreferencesProvider =
    FutureProvider.autoDispose<NotificationPreferences?>((ref) async {
  final userId = ref.watch(_userIdProvider);
  if (userId == null) return null;
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getPreferences(userId);
});

/// Notification analytics for the current user.
final notificationAnalyticsProvider =
    FutureProvider.autoDispose.family<List<NotificationLog>, int>((ref, days) async {
  final userId = ref.watch(_userIdProvider);
  if (userId == null) return [];
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getAnalytics(userId, days: days);
});
