import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? universityId;
  final String? programme;
  final int? yearOfStudy;
  final String role;
  final bool onboardingComplete;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.universityId,
    this.programme,
    this.yearOfStudy,
    this.role = 'student',
    this.onboardingComplete = false,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin' || role == 'super_admin';

  @override
  List<Object?> get props => [id, email, displayName, avatarUrl, universityId, role];
}
