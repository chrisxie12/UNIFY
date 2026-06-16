import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(Supabase.instance.client);
});

final notificationsProvider = FutureProvider.family<List<NotificationModel>, String>((ref, userId) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getNotifications(userId);
});

final unreadCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getUnreadCount(userId);
});
