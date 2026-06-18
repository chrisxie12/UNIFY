class ModerationItemModel {
  final String id;
  final String reportType;
  final String reportedBy;
  final String targetId;
  final String targetType;
  final String? reason;
  final String status;
  final String? reviewedBy;
  final String? resolution;
  final String? universityId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? reporterName;

  const ModerationItemModel({
    required this.id,
    required this.reportType,
    required this.reportedBy,
    required this.targetId,
    required this.targetType,
    this.reason,
    this.status = 'pending',
    this.reviewedBy,
    this.resolution,
    this.universityId,
    required this.createdAt,
    required this.updatedAt,
    this.reporterName,
  });

  factory ModerationItemModel.fromJson(Map<String, dynamic> json) {
    final profileData = json['profiles'] as Map<String, dynamic>?;
    return ModerationItemModel(
      id: json['id'] as String,
      reportType: json['report_type'] as String,
      reportedBy: json['reported_by'] as String,
      targetId: json['target_id'] as String,
      targetType: json['target_type'] as String,
      reason: json['reason'] as String?,
      status: json['status'] as String? ?? 'pending',
      reviewedBy: json['reviewed_by'] as String?,
      resolution: json['resolution'] as String?,
      universityId: json['university_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      reporterName: profileData?['full_name'] as String?,
    );
  }

  String get reportTypeLabel {
    switch (reportType) {
      case 'user': return 'User';
      case 'post': return 'Post';
      case 'community': return 'Community';
      case 'marketplace': return 'Marketplace';
      case 'event': return 'Event';
      default: return reportType;
    }
  }
}
