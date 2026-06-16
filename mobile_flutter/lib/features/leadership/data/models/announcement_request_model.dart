class AnnouncementRequestModel {
  final String id;
  final String requesterId;
  final String universityId;
  final String? communityId;
  final String title;
  final String body;
  final String category;
  final bool isUrgent;
  final String? targetAudience;
  final String status;
  final String? adminNotes;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const AnnouncementRequestModel({
    required this.id,
    required this.requesterId,
    required this.universityId,
    this.communityId,
    required this.title,
    required this.body,
    this.category = 'general',
    this.isUrgent = false,
    this.targetAudience,
    this.status = 'pending',
    this.adminNotes,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });

  factory AnnouncementRequestModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementRequestModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      universityId: json['university_id'] as String,
      communityId: json['community_id'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      category: json['category'] as String? ?? 'general',
      isUrgent: json['is_urgent'] as bool? ?? false,
      targetAudience: json['target_audience'] as String?,
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['admin_notes'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'requester_id': requesterId,
      'university_id': universityId,
      'community_id': communityId,
      'title': title,
      'body': body,
      'category': category,
      'is_urgent': isUrgent,
      'target_audience': targetAudience,
    };
  }
}

class CommunityManagerModel {
  final String id;
  final String communityId;
  final String userId;
  final String role;
  final String? assignedBy;
  final DateTime assignedAt;
  final bool isActive;

  const CommunityManagerModel({
    required this.id,
    required this.communityId,
    required this.userId,
    this.role = 'manager',
    this.assignedBy,
    required this.assignedAt,
    this.isActive = true,
  });

  factory CommunityManagerModel.fromJson(Map<String, dynamic> json) {
    return CommunityManagerModel(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'manager',
      assignedBy: json['assigned_by'] as String?,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
