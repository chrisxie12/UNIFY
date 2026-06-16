import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? coverPhotoUrl;
  final String? school;
  final String? programme;
  final int? yearOfStudy;
  final String role;
  final DateTime createdAt;

  // Extended identity
  final String? username;
  final String? bio;
  final String? campus;
  final String? department;
  final String? faculty;
  final int? expectedGraduationYear;

  // Social links
  final String? instagramUrl;
  final String? tiktokUrl;
  final String? snapchatUrl;
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? githubUrl;
  final String? portfolioUrl;

  // Contact
  final String? phone;
  final String? hostel;

  // Metadata
  final List<String> interests;
  final List<String> skills;
  final bool isVerified;
  final int profileViews;
  final String privacyLevel; // 'public' | 'university' | 'friends'

  // Leadership / verification
  final bool isVerifiedLeader;
  final String? leadershipRole;
  final String? representedClass;
  final String? representedDepartment;
  final String verificationStatus; // 'none' | 'pending' | 'verified' | 'rejected'

  const Profile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.coverPhotoUrl,
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
    this.tiktokUrl,
    this.snapchatUrl,
    this.linkedinUrl,
    this.twitterUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.phone,
    this.hostel,
    this.interests = const [],
    this.skills = const [],
    this.isVerified = false,
    this.profileViews = 0,
    this.privacyLevel = 'public',
    this.isVerifiedLeader = false,
    this.leadershipRole,
    this.representedClass,
    this.representedDepartment,
    this.verificationStatus = 'none',
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

  /// Academic year mapped to student status label.
  String get studentStatus {
    switch (yearOfStudy) {
      case 1:
        return 'Freshman';
      case 2:
        return 'Sophomore';
      case 3:
        return 'Junior';
      case 4:
        return 'Senior';
      default:
        if (yearOfStudy != null && yearOfStudy! > 4) return 'Graduate';
        return 'Student';
    }
  }

  /// Profile completion score, 0–100.
  int get completionScore {
    int score = 0;
    if (displayName?.isNotEmpty == true) score += 10;
    if (avatarUrl?.isNotEmpty == true) score += 10;
    if (bio?.isNotEmpty == true) score += 10;
    if (programme?.isNotEmpty == true) score += 10;
    if (school?.isNotEmpty == true) score += 10;
    if (faculty?.isNotEmpty == true) score += 5;
    if (department?.isNotEmpty == true) score += 5;
    if (yearOfStudy != null) score += 5;
    if (campus?.isNotEmpty == true) score += 5;
    if (username?.isNotEmpty == true) score += 5;
    if (interests.length >= 3) score += 10;
    if (skills.isNotEmpty) score += 5;
    final hasSocial = [
      instagramUrl,
      tiktokUrl,
      snapchatUrl,
      linkedinUrl,
      twitterUrl,
      githubUrl,
      portfolioUrl,
    ].any((u) => u?.isNotEmpty == true);
    if (hasSocial) score += 5;
    if (phone?.isNotEmpty == true) score += 5;
    return score.clamp(0, 100);
  }

  /// Gamified engagement score, 0–1000.
  int get unifyScore {
    final base = (completionScore * 8).clamp(0, 800);
    return (base + (isVerified ? 200 : 0)).clamp(0, 1000);
  }

  /// Profile is considered complete when completionScore >= 60.
  bool get isComplete => completionScore >= 60;

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
        coverPhotoUrl,
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
        tiktokUrl,
        snapchatUrl,
        linkedinUrl,
        twitterUrl,
        githubUrl,
        portfolioUrl,
        phone,
        hostel,
        interests,
        skills,
        isVerified,
        profileViews,
        privacyLevel,
        isVerifiedLeader,
        leadershipRole,
        representedClass,
        representedDepartment,
        verificationStatus,
      ];
}
