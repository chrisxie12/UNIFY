import '../../domain/entities/announcement.dart';

class FeedItemModel extends Announcement {
  final String itemType;
  final String? communityId;

  const FeedItemModel({
    required this.itemType,
    this.communityId,
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
    super.likesCount,
    super.commentsCount,
    super.sharesCount,
    required super.createdAt,
    super.isRead,
    super.hotScore,
  });

  factory FeedItemModel.fromRpcJson(Map<String, dynamic> json) {
    return FeedItemModel(
      itemType: json['item_type'] as String? ?? 'announcement',
      communityId: json['post_community_id'] as String?,
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      authorId: json['author_id'] as String,
      authorName: json['full_name'] as String?,
      authorAvatar: json['avatar_url'] as String?,
      universityId: json['university_id'] as String? ?? '',
      isPinned: json['is_pinned'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      hotScore: (json['score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toCacheJson() => {
    'item_type': itemType,
    'post_community_id': communityId,
    'id': id,
    'title': title,
    'body': body,
    'category': category,
    'author_id': authorId,
    'full_name': authorName,
    'avatar_url': authorAvatar,
    'university_id': universityId,
    'is_pinned': isPinned,
    'image_url': imageUrl,
    'likes_count': likesCount,
    'comments_count': commentsCount,
    'shares_count': sharesCount,
    'created_at': createdAt.toIso8601String(),
    'score': hotScore,
    'is_read': isRead,
  };

  factory FeedItemModel.fromCacheJson(Map<String, dynamic> json) {
    return FeedItemModel(
      itemType: json['item_type'] as String? ?? 'announcement',
      communityId: json['post_community_id'] as String?,
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      authorId: json['author_id'] as String,
      authorName: json['full_name'] as String?,
      authorAvatar: json['avatar_url'] as String?,
      universityId: json['university_id'] as String? ?? '',
      isPinned: json['is_pinned'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      hotScore: (json['score'] as num?)?.toDouble(),
    );
  }

  FeedItemModel copyWithRead() => FeedItemModel(
    itemType: itemType,
    communityId: communityId,
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
    likesCount: likesCount,
    commentsCount: commentsCount,
    sharesCount: sharesCount,
    createdAt: createdAt,
    isRead: true,
    hotScore: hotScore,
  );
}
