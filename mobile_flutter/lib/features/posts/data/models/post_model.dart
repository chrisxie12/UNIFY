class PostModel {
  final String id;
  final String communityId;
  final String authorId;
  final String? authorName;
  final String? authorAvatar;
  final bool? authorIsVerifiedLeader;
  final String? authorLeadershipRole;
  final String? title;
  final String body;
  final String postType;
  final String? mediaUrl;
  final String? linkUrl;
  final bool isPinned;
  final bool isAnnouncement;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int bookmarksCount;
  final bool? isLikedByMe;
  final bool? isBookmarkedByMe;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostModel({
    required this.id,
    required this.communityId,
    required this.authorId,
    this.authorName,
    this.authorAvatar,
    this.authorIsVerifiedLeader,
    this.authorLeadershipRole,
    this.title,
    required this.body,
    required this.postType,
    this.mediaUrl,
    this.linkUrl,
    this.isPinned = false,
    this.isAnnouncement = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.bookmarksCount = 0,
    this.isLikedByMe,
    this.isBookmarkedByMe,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String? ?? json['display_name'] as String?,
      authorAvatar: json['author_avatar'] as String? ?? json['avatar_url'] as String?,
      authorIsVerifiedLeader: json['author_is_verified_leader'] as bool?,
      authorLeadershipRole: json['author_leadership_role'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String,
      postType: json['post_type'] as String,
      mediaUrl: json['media_url'] as String?,
      linkUrl: json['link_url'] as String?,
      isPinned: json['is_pinned'] as bool? ?? false,
      isAnnouncement: json['is_announcement'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      bookmarksCount: json['bookmarks_count'] as int? ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool?,
      isBookmarkedByMe: json['is_bookmarked_by_me'] as bool?,
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
      'post_type': postType,
      'media_url': mediaUrl,
      'link_url': linkUrl,
      'is_pinned': isPinned,
      'is_announcement': isAnnouncement,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'bookmarks_count': bookmarksCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'community_id': communityId,
      'author_id': authorId,
      if (title != null) 'title': title,
      'body': body,
      'post_type': postType,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (linkUrl != null) 'link_url': linkUrl,
    };
  }

  PostModel copyWith({
    bool? isLikedByMe,
    bool? isBookmarkedByMe,
    int? likesCount,
    int? commentsCount,
  }) {
    return PostModel(
      id: id,
      communityId: communityId,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorIsVerifiedLeader: authorIsVerifiedLeader,
      authorLeadershipRole: authorLeadershipRole,
      title: title,
      body: body,
      postType: postType,
      mediaUrl: mediaUrl,
      linkUrl: linkUrl,
      isPinned: isPinned,
      isAnnouncement: isAnnouncement,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount,
      bookmarksCount: bookmarksCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isBookmarkedByMe: isBookmarkedByMe ?? this.isBookmarkedByMe,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
