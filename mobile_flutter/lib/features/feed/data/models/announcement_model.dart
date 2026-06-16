import '../../domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.body,
    required super.category,
    required super.authorId,
    super.authorName,
    super.authorAvatar,
    super.authorIsVerifiedLeader,
    super.authorLeadershipRole,
    required super.universityId,
    super.isPinned,
    super.isUrgent,
    super.imageUrl,
    super.viewCount,
    required super.createdAt,
    super.isRead,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    final author = json['profiles'] as Map<String, dynamic>?;
    return AnnouncementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      category: json['category'] as String? ?? 'general',
      authorId: json['author_id'] as String,
      authorName: author?['display_name'] as String?,
      authorAvatar: author?['avatar_url'] as String?,
      authorIsVerifiedLeader: author?['is_verified_leader'] as bool? ?? false,
      authorLeadershipRole: author?['leadership_role'] as String?,
      universityId: json['university_id'] as String,
      isPinned: json['is_pinned'] as bool? ?? false,
      isUrgent: json['is_urgent'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      viewCount: json['view_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  AnnouncementModel copyWithRead() => AnnouncementModel(
        id: id,
        title: title,
        body: body,
        category: category,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        authorIsVerifiedLeader: authorIsVerifiedLeader,
        authorLeadershipRole: authorLeadershipRole,
        universityId: universityId,
        isPinned: isPinned,
        isUrgent: isUrgent,
        imageUrl: imageUrl,
        viewCount: viewCount,
        createdAt: createdAt,
        isRead: true,
      );
}
