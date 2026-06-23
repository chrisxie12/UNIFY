import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.avatarUrl,
    super.universityId,
    super.programme,
    super.yearOfStudy,
    super.role,
    super.onboardingComplete,
    required super.createdAt,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? json['email_backup'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      universityId: json['university_id'] as String?,
      programme: json['programme'] as String?,
      yearOfStudy: _parseYearOfStudy(json['level'] as String?),
      role: json['role'] as String? ?? 'student',
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static int? _parseYearOfStudy(String? level) {
    if (level == null) return null;
    return int.tryParse(level);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'university_id': universityId,
        'programme': programme,
        'year_of_study': yearOfStudy,
        'role': role,
        'onboarding_complete': onboardingComplete,
        'created_at': createdAt.toIso8601String(),
      };
}
