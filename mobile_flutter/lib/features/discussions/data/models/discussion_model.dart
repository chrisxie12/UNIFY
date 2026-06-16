class DiscussionModel {
  final String id;
  final String communityId;
  final String authorId;
  final String? authorName;
  final String? authorAvatar;
  final bool? authorIsVerifiedLeader;
  final String? authorLeadershipRole;
  final String title;
  final String body;
  final bool isPinned;
  final bool isLocked;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final int viewCount;
  final bool? isLikedByMe;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DiscussionModel({
    required this.id,
    required this.communityId,
    required this.authorId,
    this.authorName,
    this.authorAvatar,
    this.authorIsVerifiedLeader,
    this.authorLeadershipRole,
    required this.title,
    required this.body,
    this.isPinned = false,
    this.isLocked = false,
    this.tags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewCount = 0,
    this.isLikedByMe,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiscussionModel.fromJson(Map<String, dynamic> json) {
    return DiscussionModel(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String? ?? json['display_name'] as String?,
      authorAvatar: json['author_avatar'] as String? ?? json['avatar_url'] as String?,
      authorIsVerifiedLeader: json['author_is_verified_leader'] as bool?,
      authorLeadershipRole: json['author_leadership_role'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      isPinned: json['is_pinned'] as bool? ?? false,
      isLocked: json['is_locked'] as bool? ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : const [],
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'community_id': communityId,
      'author_id': authorId,
      'title': title,
      'body': body,
      'is_pinned': isPinned,
      'is_locked': isLocked,
      'tags': tags,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'community_id': communityId,
      'author_id': authorId,
      'title': title,
      'body': body,
      'tags': tags,
    };
  }

  DiscussionModel copyWith({
    bool? isLikedByMe,
    int? likesCount,
    int? commentsCount,
    int? viewCount,
  }) {
    return DiscussionModel(
      id: id,
      communityId: communityId,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorIsVerifiedLeader: authorIsVerifiedLeader,
      authorLeadershipRole: authorLeadershipRole,
      title: title,
      body: body,
      isPinned: isPinned,
      isLocked: isLocked,
      tags: tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewCount: viewCount ?? this.viewCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class DiscussionCommentModel {
  final String id;
  final String discussionId;
  final String? parentId;
  final String authorId;
  final String? authorName;
  final String? authorAvatar;
  final bool? authorIsVerifiedLeader;
  final String? authorLeadershipRole;
  final String body;
  final int likesCount;
  final bool? isLikedByMe;
  final List<DiscussionCommentModel>? replies;
  final DateTime createdAt;

  const DiscussionCommentModel({
    required this.id,
    required this.discussionId,
    this.parentId,
    required this.authorId,
    this.authorName,
    this.authorAvatar,
    this.authorIsVerifiedLeader,
    this.authorLeadershipRole,
    required this.body,
    this.likesCount = 0,
    this.isLikedByMe,
    this.replies,
    required this.createdAt,
  });

  factory DiscussionCommentModel.fromJson(Map<String, dynamic> json) {
    return DiscussionCommentModel(
      id: json['id'] as String,
      discussionId: json['discussion_id'] as String,
      parentId: json['parent_id'] as String?,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String? ?? json['display_name'] as String?,
      authorAvatar: json['author_avatar'] as String? ?? json['avatar_url'] as String?,
      authorIsVerifiedLeader: json['author_is_verified_leader'] as bool?,
      authorLeadershipRole: json['author_leadership_role'] as String?,
      body: json['body'] as String,
      likesCount: json['likes_count'] as int? ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool?,
      replies: json['replies'] != null
          ? (json['replies'] as List).map((e) => DiscussionCommentModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'discussion_id': discussionId,
      'parent_id': parentId,
      'author_id': authorId,
      'body': body,
    };
  }
}
