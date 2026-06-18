/// Data models for the SYSTEM module: in-app announcements and app-update
/// gating. Both expose `fromJson` factories mirroring the Supabase schema.

class SystemAnnouncement {
  final String id;
  final String title;
  final String body;
  final String type; // 'feature' | 'maintenance' | 'update' | 'general'
  final String severity; // 'info' | 'warning' | 'critical'
  final String audience; // 'all' | 'university' | 'beta'
  final String? universityId;
  final String? actionLabel;
  final String? actionUrl;
  final bool isActive;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? createdBy;
  final DateTime createdAt;

  const SystemAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.severity,
    required this.audience,
    this.universityId,
    this.actionLabel,
    this.actionUrl,
    required this.isActive,
    required this.startsAt,
    this.endsAt,
    this.createdBy,
    required this.createdAt,
  });

  factory SystemAnnouncement.fromJson(Map<String, dynamic> json) {
    return SystemAnnouncement(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      severity: json['severity'] as String? ?? 'info',
      audience: json['audience'] as String? ?? 'all',
      universityId: json['university_id'] as String?,
      actionLabel: json['action_label'] as String?,
      actionUrl: json['action_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      startsAt: json['starts_at'] != null
          ? DateTime.parse(json['starts_at'] as String)
          : DateTime.now(),
      endsAt: json['ends_at'] != null
          ? DateTime.parse(json['ends_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

class AppVersionInfo {
  final String id;
  final String platform; // 'android' | 'ios' | 'web'
  final String version;
  final int buildNumber;
  final int minSupportedBuild;
  final bool isMandatory;
  final String? releaseNotes;
  final String? downloadUrl;
  final bool isActive;
  final DateTime releasedAt;

  const AppVersionInfo({
    required this.id,
    required this.platform,
    required this.version,
    required this.buildNumber,
    required this.minSupportedBuild,
    required this.isMandatory,
    this.releaseNotes,
    this.downloadUrl,
    required this.isActive,
    required this.releasedAt,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      id: json['id'] as String,
      platform: json['platform'] as String? ?? 'android',
      version: json['version'] as String? ?? '',
      buildNumber: (json['build_number'] as num?)?.toInt() ?? 0,
      minSupportedBuild: (json['min_supported_build'] as num?)?.toInt() ?? 0,
      isMandatory: json['is_mandatory'] as bool? ?? false,
      releaseNotes: json['release_notes'] as String?,
      downloadUrl: json['download_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      releasedAt: json['released_at'] != null
          ? DateTime.parse(json['released_at'] as String)
          : DateTime.now(),
    );
  }
}

/// Computed status describing whether the running build needs an update.
enum AppUpdateLevel { none, optional, required }

class AppUpdateStatus {
  final AppUpdateLevel level;
  final AppVersionInfo? version;

  const AppUpdateStatus({required this.level, this.version});

  factory AppUpdateStatus.none() =>
      const AppUpdateStatus(level: AppUpdateLevel.none);

  bool get isRequired => level == AppUpdateLevel.required;
  bool get isOptional => level == AppUpdateLevel.optional;
}
