import 'package:equatable/equatable.dart';

class AnnouncementEntity extends Equatable {
  final String id;
  final String universityId;
  final String authorId;
  final String title;
  final String body;
  final String category;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnnouncementEntity({
    required this.id,
    required this.universityId,
    required this.authorId,
    required this.title,
    required this.body,
    this.category = 'general',
    this.isPublished = false,
    this.publishedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  @override
  List<Object?> get props => [
        id,
        universityId,
        authorId,
        title,
        body,
        category,
        isPublished,
        publishedAt,
        expiresAt,
        createdAt,
        updatedAt,
      ];
}
