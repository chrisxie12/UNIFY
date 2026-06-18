import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/services/push_notification_service.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final supabase = Supabase.instance.client;
  return PushNotificationService(supabase);
});
