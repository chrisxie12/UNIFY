class AnalyticsSnapshotModel {
  final String id;
  final String? universityId;
  final DateTime snapshotDate;
  final int activeStudents;
  final int dailyActive;
  final int monthlyActive;
  final int communities;
  final int eventsCount;
  final int marketplaceCount;
  final int opportunitiesCount;
  final int postsCount;
  final DateTime createdAt;

  const AnalyticsSnapshotModel({
    required this.id,
    this.universityId,
    required this.snapshotDate,
    this.activeStudents = 0,
    this.dailyActive = 0,
    this.monthlyActive = 0,
    this.communities = 0,
    this.eventsCount = 0,
    this.marketplaceCount = 0,
    this.opportunitiesCount = 0,
    this.postsCount = 0,
    required this.createdAt,
  });

  factory AnalyticsSnapshotModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSnapshotModel(
      id: json['id'] as String,
      universityId: json['university_id'] as String?,
      snapshotDate: DateTime.parse(json['snapshot_date'] as String),
      activeStudents: json['active_students'] as int? ?? 0,
      dailyActive: json['daily_active'] as int? ?? 0,
      monthlyActive: json['monthly_active'] as int? ?? 0,
      communities: json['communities'] as int? ?? 0,
      eventsCount: json['events_count'] as int? ?? 0,
      marketplaceCount: json['marketplace_count'] as int? ?? 0,
      opportunitiesCount: json['opportunities_count'] as int? ?? 0,
      postsCount: json['posts_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
