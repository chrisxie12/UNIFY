class AdministratorModel {
  final String id;
  final String userId;
  final String roleId;
  final String? universityId;
  final String? facultyId;
  final String? departmentId;
  final String? assignedBy;
  final bool isActive;
  final DateTime createdAt;
  final String? roleName;
  final String? userFullName;
  final String? userAvatarUrl;

  const AdministratorModel({
    required this.id,
    required this.userId,
    required this.roleId,
    this.universityId,
    this.facultyId,
    this.departmentId,
    this.assignedBy,
    this.isActive = true,
    required this.createdAt,
    this.roleName,
    this.userFullName,
    this.userAvatarUrl,
  });

  factory AdministratorModel.fromJson(Map<String, dynamic> json) {
    final roleData = json['admin_roles'] as Map<String, dynamic>?;
    final profileData = json['profiles'] as Map<String, dynamic>?;
    return AdministratorModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      roleId: json['role_id'] as String,
      universityId: json['university_id'] as String?,
      facultyId: json['faculty_id'] as String?,
      departmentId: json['department_id'] as String?,
      assignedBy: json['assigned_by'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      roleName: roleData?['role'] as String?,
      userFullName: profileData?['full_name'] as String?,
      userAvatarUrl: profileData?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'role_id': roleId,
    if (universityId != null) 'university_id': universityId,
    if (facultyId != null) 'faculty_id': facultyId,
    if (departmentId != null) 'department_id': departmentId,
    if (assignedBy != null) 'assigned_by': assignedBy,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
  };
}
