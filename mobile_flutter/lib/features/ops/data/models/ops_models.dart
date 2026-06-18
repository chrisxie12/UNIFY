// OPS module data models.
//
// These map onto rows returned by analytics RPCs and the error_logs table.
// All numeric fields are parsed defensively because jsonb values may arrive
// as either `int` or `num`.

int _asInt(dynamic v) => (v as num?)?.toInt() ?? 0;

/// A single point in the daily-active-users series.
class DauPoint {
  final String day; // 'YYYY-MM-DD'
  final int active;

  const DauPoint({required this.day, required this.active});

  factory DauPoint.fromJson(Map<String, dynamic> json) {
    return DauPoint(
      day: json['day']?.toString() ?? '',
      active: _asInt(json['active']),
    );
  }
}

/// Adoption metrics for a single product feature.
class FeatureAdoption {
  final String feature;
  final int users;
  final int events;

  const FeatureAdoption({
    required this.feature,
    required this.users,
    required this.events,
  });

  factory FeatureAdoption.fromJson(Map<String, dynamic> json) {
    return FeatureAdoption(
      feature: json['feature']?.toString() ?? '',
      users: _asInt(json['users']),
      events: _asInt(json['events']),
    );
  }
}

/// A row from the error_logs table.
class ErrorLogEntry {
  final String message;
  final String? source;
  final String severity; // warning | error | critical
  final String? platform;
  final String? appVersion;
  final DateTime createdAt;

  const ErrorLogEntry({
    required this.message,
    this.source,
    required this.severity,
    this.platform,
    this.appVersion,
    required this.createdAt,
  });

  factory ErrorLogEntry.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'];
    return ErrorLogEntry(
      message: json['message']?.toString() ?? '',
      source: json['source'] as String?,
      severity: json['severity'] as String? ?? 'error',
      platform: json['platform'] as String?,
      appVersion: json['app_version'] as String?,
      createdAt: created != null
          ? DateTime.parse(created.toString()).toLocal()
          : DateTime.now(),
    );
  }
}
