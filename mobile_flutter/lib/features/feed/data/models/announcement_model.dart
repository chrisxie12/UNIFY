import '../../domain/entities/announcement_entity.dart';

class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.universityId,
    required super.authorId,
    required super.title,
    required super.body,
    super.category,
    super.isPublished,
    super.publishedAt,
    super.expiresAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String,
      universityId: json['university_id'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      title: json['title'] as String,
      body: json['body'] as String,
      category: json['category'] as String? ?? 'general',
      isPublished: json['is_published'] as bool? ?? false,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String).toLocal()
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String).toLocal()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'university_id': universityId,
        'author_id': authorId,
        'title': title,
        'body': body,
        'category': category,
        'is_published': isPublished,
        'published_at': publishedAt?.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory AnnouncementModel.fromEntity(AnnouncementEntity e) =>
      AnnouncementModel(
        id: e.id,
        universityId: e.universityId,
        authorId: e.authorId,
        title: e.title,
        body: e.body,
        category: e.category,
        isPublished: e.isPublished,
        publishedAt: e.publishedAt,
        expiresAt: e.expiresAt,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );
}
