import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/services/push_notification_service.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final supabase = Supabase.instance.client;
  return PushNotificationService(supabase);
});

/// Set when the user taps a push notification while the app is in the background.
/// app.dart listens to this and calls router.go() from within the widget tree.
final pendingPushRouteProvider = StateProvider<String?>((ref) => null);
