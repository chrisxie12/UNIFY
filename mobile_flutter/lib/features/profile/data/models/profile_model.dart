import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.email,
    super.displayName,
    super.avatarUrl,
    super.school,
    super.programme,
    super.yearOfStudy,
    super.role,
    required super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      school: json['school'] as String?,
      programme: json['programme'] as String?,
      yearOfStudy: json['year_of_study'] as int?,
      role: json['role'] as String? ?? 'student',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
