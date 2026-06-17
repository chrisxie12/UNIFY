class CommunityRequestModel {
  final String id;
  final String requesterId;
  final String universityId;
  final String communityName;
  final String communityType;
  final String? faculty;
  final String? department;
  final String? programme;
  final String? level;
  final String? academicYear;
  final int? estimatedStudentCount;
  final String purpose;
  final String status;
  final String? adminFeedback;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final String? className;

  const CommunityRequestModel({
    required this.id,
    required this.requesterId,
    required this.universityId,
    required this.communityName,
    required this.communityType,
    this.faculty,
    this.department,
    this.programme,
    this.level,
    this.academicYear,
    this.estimatedStudentCount,
    required this.purpose,
    this.status = 'pending',
    this.adminFeedback,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    this.className,
  });

  factory CommunityRequestModel.fromJson(Map<String, dynamic> json) {
    return CommunityRequestModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      universityId: json['university_id'] as String,
      communityName: json['community_name'] as String,
      communityType: json['community_type'] as String,
      faculty: json['faculty'] as String?,
      department: json['department'] as String?,
      programme: json['programme'] as String?,
      level: json['level'] as String?,
      academicYear: json['academic_year'] as String?,
      estimatedStudentCount: json['estimated_student_count'] as int?,
      purpose: json['purpose'] as String,
      status: json['status'] as String? ?? 'pending',
      adminFeedback: json['admin_feedback'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      className: json['class_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requester_id': requesterId,
      'university_id': universityId,
      'community_name': communityName,
      'community_type': communityType,
      'faculty': faculty,
      'department': department,
      'programme': programme,
      'level': level,
      'academic_year': academicYear,
      'estimated_student_count': estimatedStudentCount,
      'purpose': purpose,
      'class_name': className,
    };
  }
}

class CommunityModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String communityType;
  final String universityId;
  final String? faculty;
  final String? department;
  final String? programme;
  final String? level;
  final String? academicYear;
  final String? coverUrl;
  final String? avatarUrl;
  final int memberCount;
  final bool isActive;
  final String? createdBy;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.communityType,
    required this.universityId,
    this.faculty,
    this.department,
    this.programme,
    this.level,
    this.academicYear,
    this.coverUrl,
    this.avatarUrl,
    this.memberCount = 0,
    this.isActive = true,
    this.createdBy,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      communityType: json['community_type'] as String,
      universityId: json['university_id'] as String,
      faculty: json['faculty'] as String?,
      department: json['department'] as String?,
      programme: json['programme'] as String?,
      level: json['level'] as String?,
      academicYear: json['academic_year'] as String?,
      coverUrl: json['cover_url'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      memberCount: json['member_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
    );
  }
}

class CommunityMemberModel {
  final String communityId;
  final String userId;
  final String role;
  final DateTime joinedAt;

  const CommunityMemberModel({
    required this.communityId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      communityId: json['community_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'member',
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }
}
