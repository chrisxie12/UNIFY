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
    super.username,
    super.bio,
    super.campus,
    super.department,
    super.faculty,
    super.expectedGraduationYear,
    super.instagramUrl,
    super.linkedinUrl,
    super.twitterUrl,
    super.githubUrl,
    super.portfolioUrl,
    super.interests,
    super.isVerified,
    super.profileViews,
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
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      campus: json['campus'] as String?,
      department: json['department'] as String?,
      faculty: json['faculty'] as String?,
      expectedGraduationYear: json['expected_graduation_year'] as int?,
      instagramUrl: json['instagram_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      twitterUrl: json['twitter_url'] as String?,
      githubUrl: json['github_url'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? [],
      isVerified: json['is_verified'] as bool? ?? false,
      profileViews: json['profile_views'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'school': school,
      'programme': programme,
      'year_of_study': yearOfStudy,
      'role': role,
      'username': username,
      'bio': bio,
      'campus': campus,
      'department': department,
      'faculty': faculty,
      'expected_graduation_year': expectedGraduationYear,
      'instagram_url': instagramUrl,
      'linkedin_url': linkedinUrl,
      'twitter_url': twitterUrl,
      'github_url': githubUrl,
      'portfolio_url': portfolioUrl,
      'interests': interests,
      'is_verified': isVerified,
      'profile_views': profileViews,
    };
  }
}
