import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  final SupabaseClient _supabase;
  bool _initialized = false;
  String? _currentUserId;

  PushNotificationService(this._supabase);

  bool get isInitialized => _initialized;

  Future<void> init(String userId) async {
    _currentUserId = userId;
    debugPrint('[PushNotificationService] Firebase not available — notifications disabled');
  }

  Future<void> refreshToken() async {}

  Future<void> dispose() async {
    if (_currentUserId != null) {
      try {
        await _supabase
            .from('device_tokens')
            .update({'is_active': false})
            .eq('user_id', _currentUserId!);
      } catch (_) {}
    }
    _initialized = false;
  }
}
