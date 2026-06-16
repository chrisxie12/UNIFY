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
  });

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName![0].toUpperCase();
    }
    if (email.isNotEmpty) return email[0].toUpperCase();
    return 'U';
  }

  bool get isComplete => displayName != null && programme != null;

  @override
  List<Object?> get props => [id, displayName, avatarUrl];
}
