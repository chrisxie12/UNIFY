import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Called in a background isolate when the app is terminated/backgrounded.
/// Must be a top-level function annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message received: ${message.messageId}');
}

class PushNotificationService {
  final SupabaseClient _supabase;
  bool _initialized = false;
  String? _currentUserId;

  PushNotificationService(this._supabase);

  bool get isInitialized => _initialized;

  Future<void> init(
    String userId, {
    void Function(Map<String, dynamic> data)? onTap,
  }) async {
    _currentUserId = userId;
    try {
      await _configure(userId, onTap: onTap);
      _initialized = true;
      debugPrint('[PushNotificationService] Initialized');
    } catch (e) {
      debugPrint('[PushNotificationService] Firebase unavailable: $e');
      _initialized = false;
    }
  }

  Future<void> _configure(
    String userId, {
    void Function(Map<String, dynamic>)? onTap,
  }) async {
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[PushNotificationService] Permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // Show notifications while app is in foreground on iOS
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await messaging.getToken();
    if (token != null) await _saveToken(userId, token);

    messaging.onTokenRefresh.listen((newToken) => _saveToken(userId, newToken));

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[PushNotificationService] Foreground: ${message.notification?.title}');
    });

    // App was in background and user tapped the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onTap?.call(message.data);
    });

    // App was fully terminated; user tapped the notification to launch it
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      Future.delayed(const Duration(milliseconds: 600), () {
        onTap?.call(initial.data);
      });
    }
  }

  Future<void> _saveToken(String userId, String token) async {
    try {
      await _supabase.from('device_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'is_active': true,
      }, onConflict: 'token');
      debugPrint('[PushNotificationService] Token saved');
    } catch (e) {
      debugPrint('[PushNotificationService] Token save error: $e');
    }
  }

  Future<void> dispose() async {
    if (_currentUserId != null) {
      try {
        await _supabase
            .from('device_tokens')
            .update({'is_active': false})
            .eq('user_id', _currentUserId!);
      } catch (e) {
        debugPrint('[PushNotificationService] dispose error: $e');
      }
    }
    _initialized = false;
    _currentUserId = null;
  }

  /// Converts FCM `data` payload into the matching in-app route.
  static String? routeFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
      case 'new_message':
        final convId = data['conversation_id'];
        return convId != null ? '/messages/chat/$convId' : '/messages';
      case 'admin_broadcast':
      case 'community_announcement':
      case 'announcement_posted':
        return '/launch/announcements';
      case 'event_registration':
      case 'event_reminder':
      case 'event_checkin_confirmation':
        final eventId = data['event_id'];
        return eventId != null ? '/events/$eventId' : '/app/events';
      case 'community_approval':
      case 'community_approved':
      case 'community_join_request':
      case 'community_changes_requested':
        final communityId = data['community_id'];
        return communityId != null ? '/app/communities/$communityId' : '/app/communities';
      case 'community_rejected':
        return '/app/communities';
      case 'marketplace_inquiry':
      case 'marketplace_sale':
        return '/marketplace';
      case 'opportunity_deadline_reminder':
      case 'scholarship_alert':
        return '/opportunities';
      case 'academic_resource_upload':
        return '/academic/resources';
      case 'verification_approved':
      case 'verification_rejected':
        return '/profile';
      case 'role_assigned':
        return '/reputation';
      case 'admin_request':
        return '/admin';
      default:
        return null;
    }
  }
}
