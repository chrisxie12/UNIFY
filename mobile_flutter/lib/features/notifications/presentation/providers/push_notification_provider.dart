import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../domain/services/push_notification_service.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  // Read via supabaseProvider. This provider is only read from app.dart's auth
  // listener, which fires after a session exists — so Supabase is guaranteed
  // initialized by then.
  return PushNotificationService(ref.watch(supabaseProvider));
});

/// Set when the user taps a push notification while the app is in the background.
/// app.dart listens to this and calls router.go() from within the widget tree.
final pendingPushRouteProvider = StateProvider<String?>((ref) => null);
