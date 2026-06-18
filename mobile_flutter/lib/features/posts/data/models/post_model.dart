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
  final int upvoteCount;
  final int downvoteCount;
  final int commentsCount;
  final int sharesCount;
  final int bookmarksCount;
  final String? myVote;
  final bool? isBookmarkedByMe;
  final String? bestAnswerId;
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
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.bookmarksCount = 0,
    this.myVote,
    this.isBookmarkedByMe,
    this.bestAnswerId,
    required this.createdAt,
    required this.updatedAt,
  });

  int get netVoteCount => upvoteCount - downvoteCount;

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
      upvoteCount: json['upvote_count'] as int? ?? 0,
      downvoteCount: json['downvote_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      bookmarksCount: json['bookmarks_count'] as int? ?? 0,
      myVote: json['my_vote'] as String?,
      isBookmarkedByMe: json['is_bookmarked_by_me'] as bool?,
      bestAnswerId: json['best_answer_id'] as String?,
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
      'upvote_count': upvoteCount,
      'downvote_count': downvoteCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'bookmarks_count': bookmarksCount,
      'best_answer_id': bestAnswerId,
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
    String? myVote,
    bool? isBookmarkedByMe,
    int? upvoteCount,
    int? downvoteCount,
    int? commentsCount,
    String? bestAnswerId,
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
      upvoteCount: upvoteCount ?? this.upvoteCount,
      downvoteCount: downvoteCount ?? this.downvoteCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount,
      bookmarksCount: bookmarksCount,
      myVote: myVote ?? this.myVote,
      isBookmarkedByMe: isBookmarkedByMe ?? this.isBookmarkedByMe,
      bestAnswerId: bestAnswerId ?? this.bestAnswerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
