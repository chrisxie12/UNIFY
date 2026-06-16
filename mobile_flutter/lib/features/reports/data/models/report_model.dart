class ReportModel {
  final String id;
  final String reporterId;
  final String reportType;
  final String targetId;
  final String? targetOwnerId;
  final String reason;
  final String? description;
  final String status;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? adminNotes;
  final DateTime createdAt;

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.reportType,
    required this.targetId,
    this.targetOwnerId,
    required this.reason,
    this.description,
    this.status = 'open',
    this.resolvedBy,
    this.resolvedAt,
    this.adminNotes,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      reportType: json['report_type'] as String,
      targetId: json['target_id'] as String,
      targetOwnerId: json['target_owner_id'] as String?,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'open',
      resolvedBy: json['resolved_by'] as String?,
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at'] as String) : null,
      adminNotes: json['admin_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'reporter_id': reporterId,
      'report_type': reportType,
      'target_id': targetId,
      'target_owner_id': targetOwnerId,
      'reason': reason,
      'description': description,
    };
  }

  static const Map<String, String> reportTypeLabels = {
    'post': 'Post',
    'comment': 'Comment',
    'user': 'User',
    'community': 'Community',
    'discussion': 'Discussion',
    'resource': 'Resource',
  };

  static const Map<String, String> statusLabels = {
    'open': 'Open',
    'investigating': 'Investigating',
    'resolved': 'Resolved',
    'dismissed': 'Dismissed',
  };
}
