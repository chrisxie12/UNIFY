class PostCommentModel {
  final String id;
  final String postId;
  final String? parentId;
  final String authorId;
  final String? authorName;
  final String? authorAvatar;
  final bool? authorIsVerifiedLeader;
  final String? authorLeadershipRole;
  final String body;
  final int likesCount;
  final bool? isLikedByMe;
  final bool isBestAnswer;
  final List<PostCommentModel>? replies;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostCommentModel({
    required this.id,
    required this.postId,
    this.parentId,
    required this.authorId,
    this.authorName,
    this.authorAvatar,
    this.authorIsVerifiedLeader,
    this.authorLeadershipRole,
    required this.body,
    this.likesCount = 0,
    this.isLikedByMe,
    this.isBestAnswer = false,
    this.replies,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      parentId: json['parent_id'] as String?,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String? ?? json['display_name'] as String?,
      authorAvatar: json['author_avatar'] as String? ?? json['avatar_url'] as String?,
      authorIsVerifiedLeader: json['author_is_verified_leader'] as bool?,
      authorLeadershipRole: json['author_leadership_role'] as String?,
      body: json['body'] as String,
      likesCount: json['likes_count'] as int? ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool?,
      isBestAnswer: json['is_best_answer'] as bool? ?? false,
      replies: json['replies'] != null
          ? (json['replies'] as List).map((e) => PostCommentModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'post_id': postId,
      'parent_id': parentId,
      'author_id': authorId,
      'body': body,
    };
  }
}
