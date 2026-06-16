class CommunityDetailModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String communityType;
  final String universityId;
  final String? universityName;
  final String? faculty;
  final String? department;
  final String? programme;
  final String? level;
  final String? academicYear;
  final String? coverUrl;
  final String? avatarUrl;
  final int memberCount;
  final bool isActive;
  final String createdBy;
  final String? creatorName;
  final String? creatorAvatar;
  final bool? creatorIsVerifiedLeader;
  final String? creatorLeadershipRole;
  final DateTime createdAt;
  final bool? isMember;
  final String? membershipRole;
  final List<CommunityManagerInfo> managers;

  const CommunityDetailModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.communityType,
    required this.universityId,
    this.universityName,
    this.faculty,
    this.department,
    this.programme,
    this.level,
    this.academicYear,
    this.coverUrl,
    this.avatarUrl,
    this.memberCount = 0,
    this.isActive = true,
    required this.createdBy,
    this.creatorName,
    this.creatorAvatar,
    this.creatorIsVerifiedLeader,
    this.creatorLeadershipRole,
    required this.createdAt,
    this.isMember,
    this.membershipRole,
    this.managers = const [],
  });

  factory CommunityDetailModel.fromJson(Map<String, dynamic> json) {
    return CommunityDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      communityType: json['community_type'] as String,
      universityId: json['university_id'] as String,
      universityName: json['university_name'] as String?,
      faculty: json['faculty'] as String?,
      department: json['department'] as String?,
      programme: json['programme'] as String?,
      level: json['level'] as String?,
      academicYear: json['academic_year'] as String?,
      coverUrl: json['cover_url'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      memberCount: json['member_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by'] as String,
      creatorName: json['creator_name'] as String? ?? json['creator_display_name'] as String?,
      creatorAvatar: json['creator_avatar'] as String? ?? json['creator_avatar_url'] as String?,
      creatorIsVerifiedLeader: json['creator_is_verified_leader'] as bool?,
      creatorLeadershipRole: json['creator_leadership_role'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isMember: json['is_member'] as bool?,
      membershipRole: json['membership_role'] as String?,
      managers: json['managers'] != null
          ? (json['managers'] as List).map((e) => CommunityManagerInfo.fromJson(e as Map<String, dynamic>)).toList()
          : const [],
    );
  }

  String get communityTypeLabel {
    switch (communityType) {
      case 'class': return 'Class';
      case 'level': return 'Level';
      case 'course': return 'Course';
      case 'programme': return 'Programme';
      case 'department': return 'Department';
      case 'faculty': return 'Faculty';
      case 'university': return 'University';
      case 'hostel': return 'Hostel';
      case 'hall': return 'Hall';
      case 'residence': return 'Residence';
      case 'church': return 'Church';
      case 'sports': return 'Sports';
      case 'entrepreneurship': return 'Entrepreneurship';
      case 'technology': return 'Technology';
      case 'gaming': return 'Gaming';
      case 'photography': return 'Photography';
      case 'music': return 'Music';
      case 'campus_jobs': return 'Campus Jobs';
      case 'scholarships': return 'Scholarships';
      case 'club': return 'Club';
      default: return communityType;
    }
  }
}

class CommunityManagerInfo {
  final String id;
  final String userId;
  final String role;
  final String? displayName;
  final String? avatarUrl;
  final bool? isVerifiedLeader;
  final String? leadershipRole;
  final DateTime assignedAt;

  const CommunityManagerInfo({
    required this.id,
    required this.userId,
    required this.role,
    this.displayName,
    this.avatarUrl,
    this.isVerifiedLeader,
    this.leadershipRole,
    required this.assignedAt,
  });

  factory CommunityManagerInfo.fromJson(Map<String, dynamic> json) {
    return CommunityManagerInfo(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isVerifiedLeader: json['is_verified_leader'] as bool?,
      leadershipRole: json['leadership_role'] as String?,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
    );
  }
}
