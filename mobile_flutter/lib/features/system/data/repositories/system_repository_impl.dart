import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/system_models.dart';

/// Repository for the SYSTEM module. Wraps Supabase access for in-app
/// announcements (+ per-user dismissals) and app version metadata.
class SystemRepositoryImpl {
  final SupabaseClient _client;

  SystemRepositoryImpl(this._client);

  // ── Announcements (read) ─────────────────────────────────────────────

  /// Active announcements that are currently within their time window.
  /// We fetch only `is_active = true` rows then filter the time window
  /// client-side to keep the query simple.
  Future<List<SystemAnnouncement>> getActiveAnnouncements() async {
    final response = await _client
        .from('system_announcements')
        .select('*')
        .eq('is_active', true)
        .order('starts_at', ascending: false) as List;

    final now = DateTime.now();
    return response
        .map((json) =>
            SystemAnnouncement.fromJson(json as Map<String, dynamic>))
        .where((a) =>
            !a.startsAt.isAfter(now) &&
            (a.endsAt == null || a.endsAt!.isAfter(now)))
        .toList();
  }

  /// Announcement ids the given user has dismissed.
  Future<List<String>> getDismissedIds(String userId) async {
    final response = await _client
        .from('announcement_dismissals')
        .select('announcement_id')
        .eq('user_id', userId) as List;

    return response
        .map((row) => (row as Map<String, dynamic>)['announcement_id'] as String)
        .toList();
  }

  /// Records a dismissal for [announcementId] by [userId].
  Future<void> dismiss(String announcementId, String userId) async {
    await _client.from('announcement_dismissals').insert({
      'announcement_id': announcementId,
      'user_id': userId,
    });
  }

  // ── Announcements (admin) ────────────────────────────────────────────

  Future<List<SystemAnnouncement>> getAllAnnouncements() async {
    final response = await _client
        .from('system_announcements')
        .select('*')
        .limit(100)
        .order('created_at', ascending: false) as List;

    return response
        .map((json) =>
            SystemAnnouncement.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<SystemAnnouncement> createAnnouncement({
    required String title,
    required String body,
    required String type,
    required String severity,
    required String audience,
    String? actionLabel,
    String? actionUrl,
    DateTime? endsAt,
    String? createdBy,
  }) async {
    final row = await _client
        .from('system_announcements')
        .insert({
          'title': title,
          'body': body,
          'type': type,
          'severity': severity,
          'audience': audience,
          if (actionLabel != null && actionLabel.isNotEmpty)
            'action_label': actionLabel,
          if (actionUrl != null && actionUrl.isNotEmpty) 'action_url': actionUrl,
          if (endsAt != null) 'ends_at': endsAt.toUtc().toIso8601String(),
          if (createdBy != null) 'created_by': createdBy,
          'is_active': true,
        })
        .select()
        .single();

    return SystemAnnouncement.fromJson(row);
  }

  Future<void> toggleAnnouncement(String id, bool isActive) async {
    await _client
        .from('system_announcements')
        .update({'is_active': isActive}).eq('id', id);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _client.from('system_announcements').delete().eq('id', id);
  }

  // ── App versions ─────────────────────────────────────────────────────

  Future<List<AppVersionInfo>> getAppVersions() async {
    final response = await _client
        .from('app_versions')
        .select('*')
        .limit(100)
        .order('released_at', ascending: false) as List;

    return response
        .map((json) => AppVersionInfo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Most recent active version for [platform], by build number desc.
  Future<AppVersionInfo?> latestVersion(String platform) async {
    final row = await _client
        .from('app_versions')
        .select('*')
        .eq('platform', platform)
        .eq('is_active', true)
        .order('build_number', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) return null;
    return AppVersionInfo.fromJson(row);
  }

  Future<AppVersionInfo> createAppVersion({
    required String platform,
    required String version,
    required int buildNumber,
    required int minSupportedBuild,
    required bool isMandatory,
    String? releaseNotes,
    String? downloadUrl,
  }) async {
    final row = await _client
        .from('app_versions')
        .insert({
          'platform': platform,
          'version': version,
          'build_number': buildNumber,
          'min_supported_build': minSupportedBuild,
          'is_mandatory': isMandatory,
          if (releaseNotes != null && releaseNotes.isNotEmpty)
            'release_notes': releaseNotes,
          if (downloadUrl != null && downloadUrl.isNotEmpty)
            'download_url': downloadUrl,
          'is_active': true,
        })
        .select()
        .single();

    return AppVersionInfo.fromJson(row);
  }

  Future<void> toggleAppVersion(String id, bool isActive) async {
    await _client
        .from('app_versions')
        .update({'is_active': isActive}).eq('id', id);
  }
}
