import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    super.fullName,
    super.email,
    super.avatarUrl,
    super.bio,
    super.level,
    super.programme,
    super.studentId,
    super.isVerified,
    super.role,
    required super.universityId,
    super.verifiedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json, {String? email}) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      email: email ?? json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      level: json['level'] as String?,
      programme: json['programme'] as String?,
      studentId: json['student_id'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      role: json['role'] as String? ?? 'student',
      universityId: json['university_id'] as String? ?? '',
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String).toLocal()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
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
        'verified_at': verifiedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
