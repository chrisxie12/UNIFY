import 'badge_model.dart';

class UserBadgeModel {
  final String userId;
  final BadgeModel badge;
  final String? assignedBy;
  final DateTime assignedAt;

  const UserBadgeModel({
    required this.userId,
    required this.badge,
    this.assignedBy,
    required this.assignedAt,
  });

  factory UserBadgeModel.fromJson(Map<String, dynamic> json, {BadgeModel? badge}) {
    return UserBadgeModel(
      userId: json['user_id'] as String,
      badge: badge ?? BadgeModel.fromJson(json['badges'] as Map<String, dynamic>),
      assignedBy: json['assigned_by'] as String?,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
    );
  }
}

class LeadershipRoleModel {
  final String id;
  final String slug;
  final String title;
  final String? description;
  final bool isElective;
  final int priority;

  const LeadershipRoleModel({
    required this.id,
    required this.slug,
    required this.title,
    this.description,
    this.isElective = false,
    this.priority = 0,
  });

  factory LeadershipRoleModel.fromJson(Map<String, dynamic> json) {
    return LeadershipRoleModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isElective: json['is_elective'] as bool? ?? false,
      priority: json['priority'] as int? ?? 0,
    );
  }
}

class UserLeadershipModel {
  final String id;
  final String userId;
  final LeadershipRoleModel role;
  final String universityId;
  final String? faculty;
  final String? department;
  final String? programme;
  final String? level;
  final String academicYear;
  final String? verifiedBy;
  final DateTime verifiedAt;
  final bool isActive;

  const UserLeadershipModel({
    required this.id,
    required this.userId,
    required this.role,
    required this.universityId,
    this.faculty,
    this.department,
    this.programme,
    this.level,
    required this.academicYear,
    this.verifiedBy,
    required this.verifiedAt,
    this.isActive = true,
  });

  factory UserLeadershipModel.fromJson(Map<String, dynamic> json, {LeadershipRoleModel? role}) {
    return UserLeadershipModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      role: role ?? LeadershipRoleModel.fromJson(json['leadership_roles'] as Map<String, dynamic>),
      universityId: json['university_id'] as String,
      faculty: json['faculty'] as String?,
      department: json['department'] as String?,
      programme: json['programme'] as String?,
      level: json['level'] as String?,
      academicYear: json['academic_year'] as String,
      verifiedBy: json['verified_by'] as String?,
      verifiedAt: DateTime.parse(json['verified_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
