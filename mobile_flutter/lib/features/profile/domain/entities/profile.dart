import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? school;
  final String? programme;
  final int? yearOfStudy;
  final String role;
  final DateTime createdAt;

  // Extended identity fields
  final String? username;
  final String? bio;
  final String? campus;
  final String? department;
  final String? faculty;
  final int? expectedGraduationYear;

  // Social links
  final String? instagramUrl;
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? githubUrl;
  final String? portfolioUrl;

  // Contact
  final String? phone;
  final String? hostel;

  // Metadata
  final List<String> interests;
  final bool isVerified;
  final int profileViews;

  const Profile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.school,
    this.programme,
    this.yearOfStudy,
    this.role = 'student',
    required this.createdAt,
    this.username,
    this.bio,
    this.campus,
    this.department,
    this.faculty,
    this.expectedGraduationYear,
    this.instagramUrl,
    this.linkedinUrl,
    this.twitterUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.phone,
    this.hostel,
    this.interests = const [],
    this.isVerified = false,
    this.profileViews = 0,
  });

  /// Two-letter initials from display name; falls back to email initial.
  String get initials {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      final parts = displayName!.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    if (email.isNotEmpty) return email[0].toUpperCase();
    return 'U';
  }

  /// Profile is complete when the core academic fields are present.
  bool get isComplete =>
      displayName != null &&
      displayName!.isNotEmpty &&
      programme != null &&
      programme!.isNotEmpty &&
      school != null &&
      school!.isNotEmpty;

  /// @username if set, else email prefix prefixed with @.
  String get displayUsername {
    if (username != null && username!.isNotEmpty) return '@${username!}';
    return '@${email.split('@').first}';
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        avatarUrl,
        school,
        programme,
        yearOfStudy,
        role,
        createdAt,
        username,
        bio,
        campus,
        department,
        faculty,
        expectedGraduationYear,
        instagramUrl,
        linkedinUrl,
        twitterUrl,
        githubUrl,
        portfolioUrl,
        phone,
        hostel,
        interests,
        isVerified,
        profileViews,
      ];
}
