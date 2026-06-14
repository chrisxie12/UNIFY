import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final String? level;
  final String? programme;
  final String? studentId;
  final bool isVerified;
  final String role;
  final String universityId;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileEntity({
    required this.id,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.bio,
    this.level,
    this.programme,
    this.studentId,
    this.isVerified = false,
    this.role = 'student',
    required this.universityId,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isSuperAdmin => role == 'superadmin';

  String get displayName => fullName ?? email?.split('@').first ?? 'Student';

  String get initial => displayName.isNotEmpty
      ? displayName[0].toUpperCase()
      : 'U';

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        avatarUrl,
        bio,
        level,
        programme,
        studentId,
        isVerified,
        role,
        universityId,
        verifiedAt,
        createdAt,
        updatedAt,
      ];
}
