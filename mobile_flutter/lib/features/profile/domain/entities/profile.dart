import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? programme;
  final int? yearOfStudy;
  final String role;
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.programme,
    this.yearOfStudy,
    this.role = 'student',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, displayName, avatarUrl];
}
