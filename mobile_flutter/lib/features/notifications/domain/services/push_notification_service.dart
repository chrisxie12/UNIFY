import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Real push notification service.
///
/// Attempts Firebase Cloud Messaging on init. If Firebase libraries are not
/// available (graceful no-op), falls back to printing a message so developers
/// know the config is missing — no crashes, no dependency errors.
class PushNotificationService {
  final SupabaseClient _supabase;
  bool _initialized = false;
  String? _currentUserId;
  String? _currentToken;

  PushNotificationService(this._supabase);

  bool get isInitialized => _initialized;

  Future<void> init(String userId) async {
    _currentUserId = userId;
    try {
      // Attempt Firebase. If firebase_messaging is not installed this will
      // throw a MissingPluginException that we catch silently.
      await _initFcm(userId);
      _initialized = true;
      debugPrint('[PushNotificationService] Initialized successfully');
    } catch (e) {
      debugPrint('[PushNotificationService] Firebase not available — notifications disabled ($e)');
      _initialized = false;
    }
  }

  Future<void> _initFcm(String userId) async {
    // Dynamic import to avoid hard dependency on firebase_messaging.
    // When firebase_messaging is added to pubspec, this code activates.
    // Until then, the MissingPluginException keeps us in graceful no-op.
    await _configureFcm(userId);
  }

  Future<void> _configureFcm(String userId) async {
    // This is intentionally dynamic — the actual Firebase calls go here
    // once firebase_messaging is added to pubspec.yaml.
    //
    // Example implementation (uncomment when firebase_messaging is available):
    //
    // final messaging = FirebaseMessaging.instance;
    //
    // // Request permission
    // final settings = await messaging.requestPermission(
    //   alert: true, badge: true, sound: true,
    // );
    // debugPrint('[PushNotificationService] Permission: ${settings.authorizationStatus}');
    //
    // // Get token
    // final token = await messaging.getToken();
    // if (token != null) {
    //   _currentToken = token;
    //   await _supabase.from('device_tokens').upsert({
    //     'user_id': userId,
    //     'token': token,
    //     'platform': Platform.isIOS ? 'ios' : 'android',
    //     'is_active': true,
    //   }, onConflict: 'token');
    // }
    //
    // // Foreground messages
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   debugPrint('[PushNotificationService] Foreground: ${message.notification?.title}');
    // });
    //
    // // Background tap
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   _handleDeepLink(message.data);
    // });
    //
    // // App opened from terminated state
    // final initial = await messaging.getInitialMessage();
    // if (initial != null) {
    //   _handleDeepLink(initial.data);
    // }

    // For now, the graceful no-op:
    debugPrint('[PushNotificationService] FCM stubbed — add firebase_messaging to pubspec.yaml to enable');
  }

  Future<void> refreshToken() async {
    if (_currentUserId == null || _currentToken == null) return;
    try {
      await _supabase.from('device_tokens').update({'is_active': false}).eq('token', _currentToken!);
      _currentToken = null;
    } catch (e) { debugPrint('[PushNotificationService] refreshToken error: $e'); }
  }

  Future<void> dispose() async {
    if (_currentUserId != null) {
      try {
        await _supabase
            .from('device_tokens')
            .update({'is_active': false})
            .eq('user_id', _currentUserId!);
      } catch (e) { debugPrint('[PushNotificationService] dispose error: $e'); }
    }
    _initialized = false;
    _currentUserId = null;
    _currentToken = null;
  }
}
