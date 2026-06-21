import 'package:flutter/foundation.dart';

@immutable
class UnifyPost {
  final String id;
  final String authorName;
  final String? authorAvatarUrl;
  final String timestampText;
  final String content;
  final int likeCount;
  final bool isPinned;
  final String moduleTag;

  const UnifyPost({
    required this.id,
    required this.authorName,
    this.authorAvatarUrl,
    required this.timestampText,
    required this.content,
    required this.likeCount,
    this.isPinned = false,
    this.moduleTag = 'General',
  });

  factory UnifyPost.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    final rawCreatedAt = json['created_at'] as String?;
    return UnifyPost(
      id: json['id'] as String,
      authorName: p?['full_name'] as String? ?? 'Anonymous Student',
      authorAvatarUrl: p?['avatar_url'] as String?,
      timestampText: rawCreatedAt != null
          ? '${DateTime.now().difference(DateTime.parse(rawCreatedAt)).inDays}d ago'
          : 'Just now',
      content: json['body'] as String? ?? '',
      likeCount: json['likes_count'] as int? ?? 0,
      isPinned: json['is_pinned'] as bool? ?? false,
      moduleTag: json['post_type'] as String? ?? 'General',
    );
  }
}
