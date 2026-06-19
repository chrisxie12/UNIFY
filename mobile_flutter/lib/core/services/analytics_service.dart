import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../providers/supabase_provider.dart';

/// Lightweight client telemetry: screen/feature events, session lifecycle,
/// and error logging. Every call is fire-and-forget and never throws, so it
/// is safe to sprinkle through the app without guarding each call site.
class AnalyticsService {
  AnalyticsService(this._client);

  final SupabaseClient _client;

  String? _sessionId;
  DateTime? _sessionStart;

  static String get platform {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      default:
        return defaultTargetPlatform.name;
    }
  }

  String? get _uid => _client.auth.currentUser?.id;

  /// Opens a session row. Call once when the app reaches the authed shell.
  Future<void> startSession() async {
    if (_uid == null) return;
    try {
      final row = await _client
          .from('user_sessions')
          .insert({
            'user_id': _uid,
            'app_version': AppConstants.appVersion,
            'platform': platform,
          })
          .select('id')
          .single();
      _sessionId = row['id'] as String;
      _sessionStart = DateTime.now();
    } catch (e) { debugPrint('[AnalyticsService] startSession error: $e'); /* telemetry must never break the app */}
  }

  /// Closes the current session, stamping its duration.
  Future<void> endSession() async {
    if (_sessionId == null || _sessionStart == null) return;
    final secs = DateTime.now().difference(_sessionStart!).inSeconds;
    try {
      await _client.from('user_sessions').update({
        'ended_at': DateTime.now().toUtc().toIso8601String(),
        'duration_seconds': secs,
      }).eq('id', _sessionId!);
    } catch (e) { debugPrint('[AnalyticsService] endSession error: $e'); }
    _sessionId = null;
    _sessionStart = null;
  }

  /// Records a usage event. [feature] powers the feature-adoption dashboard.
  Future<void> log(
    String eventName, {
    String? feature,
    Map<String, dynamic>? properties,
  }) async {
    try {
      await _client.from('analytics_events').insert({
        'user_id': _uid,
        'event_name': eventName,
        if (feature != null) 'feature': feature,
        if (properties != null) 'properties': properties,
        if (_sessionId != null) 'session_id': _sessionId,
        'app_version': AppConstants.appVersion,
        'platform': platform,
      });
    } catch (e) { debugPrint('[AnalyticsService] log error: $e'); }
  }

  /// Convenience for screen-view tracking.
  Future<void> screen(String name, {String? feature}) =>
      log('screen_view', feature: feature, properties: {'screen': name});

  /// Appends to the error stream feeding the system-health dashboard.
  Future<void> logError(
    String message, {
    String severity = 'error',
    String source = 'client',
    String? stack,
  }) async {
    try {
      await _client.from('error_logs').insert({
        'user_id': _uid,
        'error_type': 'runtime',
        'source': source,
        'message': message,
        if (stack != null) 'stack': stack,
        'severity': severity,
        'app_version': AppConstants.appVersion,
        'platform': platform,
      });
    } catch (e) { debugPrint('[AnalyticsService] logError error: $e'); }
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(ref.watch(supabaseProvider)),
);
