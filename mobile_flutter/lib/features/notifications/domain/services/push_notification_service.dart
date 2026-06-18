import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  final SupabaseClient _supabase;
  FirebaseMessaging? _messaging;
  FlutterLocalNotificationsPlugin? _localNotifications;
  bool _initialized = false;
  String? _currentUserId;

  PushNotificationService(this._supabase);

  bool get isInitialized => _initialized;

  Future<void> init(String userId) async {
    _currentUserId = userId;

    try {
      _messaging = FirebaseMessaging.instance;
      _localNotifications = FlutterLocalNotificationsPlugin();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _localNotifications!.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      await _requestPermission();
      await _registerToken();
      _setupForegroundHandler();
      _setupBackgroundHandler();

      _initialized = true;
      debugPrint('[PushNotificationService] Initialized for user $userId');
    } catch (e) {
      debugPrint('[PushNotificationService] Firebase not available: $e');
    }
  }

  Future<void> _requestPermission() async {
    if (_messaging == null) return;

    final settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[PushNotificationService] Permission denied');
    }
  }

  Future<void> _registerToken() async {
    if (_messaging == null || _currentUserId == null) return;

    try {
      final token = await _messaging!.getToken();
      if (token != null) {
        String platform;
        if (defaultTargetPlatform == TargetPlatform.android) {
          platform = 'android';
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          platform = 'ios';
        } else {
          platform = 'web';
        }

        await _supabase.from('device_tokens').upsert({
          'user_id': _currentUserId,
          'token': token,
          'platform': platform,
          'is_active': true,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'token');

        debugPrint('[PushNotificationService] Token registered');
      }
    } catch (e) {
      debugPrint('[PushNotificationService] Token registration failed: $e');
    }
  }

  void _setupForegroundHandler() {
    if (_messaging == null) return;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _showLocalNotification(
          id: message.messageId.hashCode,
          title: notification.title ?? '',
          body: notification.body ?? '',
          payload: jsonEncode(message.data),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigationFromData(message.data);
    });
  }

  void _setupBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    debugPrint('[PushNotificationService] Background message: ${message.messageId}');
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (_localNotifications == null) return;

    const androidDetails = AndroidNotificationDetails(
      'unify_notifications',
      'UNIFY Notifications',
      channelDescription: 'Notifications from UNIFY',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await _localNotifications!.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _handleNavigationFromData(data);
    } catch (_) {}
  }

  void _handleNavigationFromData(Map<String, dynamic> data) {
    final referenceType = data['reference_type'] as String?;
    final referenceId = data['reference_id'] as String?;

    if (referenceType != null && referenceId != null) {
      debugPrint('[PushNotificationService] Navigate to $referenceType: $referenceId');
    }
  }

  Future<void> refreshToken() async {
    if (_messaging == null || _currentUserId == null) return;
    await _registerToken();
  }

  Future<void> dispose() async {
    if (_messaging != null && _currentUserId != null) {
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
