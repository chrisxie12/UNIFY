import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.avatarUrl,
    super.bio,
    super.level,
    super.programme,
    super.studentId,
    super.isVerified,
    super.role,
    required super.universityId,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? email}) {
    return UserModel(
      id: json['id'] as String,
      email: email ?? json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      level: json['level'] as String?,
      programme: json['programme'] as String?,
      studentId: json['student_id'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      role: json['role'] as String? ?? 'student',
      universityId: json['university_id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'bio': bio,
        'level': level,
        'programme': programme,
        'student_id': studentId,
        'is_verified': isVerified,
        'role': role,
        'university_id': universityId,
        'created_at': createdAt.toIso8601String(),
      };
}
