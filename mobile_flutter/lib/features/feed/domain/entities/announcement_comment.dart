class AnnouncementComment {
  final String id;
  final String announcementId;
  final String authorId;
  final String? authorName;
  final String? authorAvatar;
  final String body;
  final DateTime createdAt;

  const AnnouncementComment({
    required this.id,
    required this.announcementId,
    required this.authorId,
    this.authorName,
    this.authorAvatar,
    required this.body,
    required this.createdAt,
  });

  factory AnnouncementComment.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    return AnnouncementComment(
      id: json['id'] as String,
      announcementId: json['announcement_id'] as String,
      authorId: json['author_id'] as String,
      authorName: p?['full_name'] as String?,
      authorAvatar: p?['avatar_url'] as String?,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
