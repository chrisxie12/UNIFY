import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final String? level;
  final String? programme;
  final String? studentId;
  final bool isVerified;
  final String role; // student | admin | superadmin
  final String universityId;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.level,
    this.programme,
    this.studentId,
    this.isVerified = false,
    this.role = 'student',
    required this.universityId,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isSuperAdmin => role == 'superadmin';

  String get displayName => fullName ?? email.split('@').first;

  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        avatarUrl,
        bio,
        level,
        programme,
        studentId,
        isVerified,
        role,
        universityId,
        createdAt,
      ];
}
