// Community post (discussion thread)
class CommunityPostModel {
  final String id;
  final String communityId;
  final String authorId;
  final String? title;
  final String body;
  final bool isPinned;
  final int reactionCount;
  final int commentCount;
  final DateTime createdAt;
  // Joined from profiles
  final String? authorName;
  final String? authorAvatar;
  final bool authorIsVerified;
  final String? authorLeadershipRole;

  const CommunityPostModel({
    required this.id,
    required this.communityId,
    required this.authorId,
    this.title,
    required this.body,
    this.isPinned = false,
    this.reactionCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.authorName,
    this.authorAvatar,
    this.authorIsVerified = false,
    this.authorLeadershipRole,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    return CommunityPostModel(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      authorId: json['author_id'] as String,
      title: json['title'] as String?,
      body: json['body'] as String,
      isPinned: json['is_pinned'] as bool? ?? false,
      reactionCount: (json['likes_count'] as int?) ?? (json['reaction_count'] as int?) ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorName: p?['full_name'] as String?,
      authorAvatar: p?['avatar_url'] as String?,
      authorIsVerified: p?['is_verified_leader'] as bool? ?? false,
      authorLeadershipRole: p?['leadership_role'] as String?,
    );
  }
}

// Comment on a post (supports nesting via parent_id)
class CommunityCommentModel {
  final String id;
  final String postId;
  final String? parentId;
  final String authorId;
  final String body;
  final int reactionCount;
  final DateTime createdAt;
  // Joined from profiles
  final String? authorName;
  final String? authorAvatar;
  final bool authorIsVerified;

  const CommunityCommentModel({
    required this.id,
    required this.postId,
    this.parentId,
    required this.authorId,
    required this.body,
    this.reactionCount = 0,
    required this.createdAt,
    this.authorName,
    this.authorAvatar,
    this.authorIsVerified = false,
  });

  factory CommunityCommentModel.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    return CommunityCommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      parentId: json['parent_id'] as String?,
      authorId: json['author_id'] as String,
      body: json['body'] as String,
      reactionCount: (json['likes_count'] as int?) ?? (json['reaction_count'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorName: p?['full_name'] as String?,
      authorAvatar: p?['avatar_url'] as String?,
      authorIsVerified: p?['is_verified_leader'] as bool? ?? false,
    );
  }
}

// Uploaded file resource
class CommunityResourceModel {
  final String id;
  final String communityId;
  final String uploaderId;
  final String title;
  final String? description;
  final String fileUrl;
  final String fileType; // pdf, docx, ppt, image, zip, other
  final int? fileSize;
  final int downloadCount;
  final String category; // lecture_notes, past_questions, assignments, projects, general
  final DateTime createdAt;
  // Joined from profiles
  final String? uploaderName;
  final String? uploaderAvatar;

  const CommunityResourceModel({
    required this.id,
    required this.communityId,
    required this.uploaderId,
    required this.title,
    this.description,
    required this.fileUrl,
    required this.fileType,
    this.fileSize,
    this.downloadCount = 0,
    this.category = 'general',
    required this.createdAt,
    this.uploaderName,
    this.uploaderAvatar,
  });

  factory CommunityResourceModel.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    return CommunityResourceModel(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      uploaderId: json['uploader_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int?,
      downloadCount: json['download_count'] as int? ?? 0,
      category: json['category'] as String? ?? 'general',
      createdAt: DateTime.parse(json['created_at'] as String),
      uploaderName: p?['full_name'] as String?,
      uploaderAvatar: p?['avatar_url'] as String?,
    );
  }

  String get fileSizeLabel {
    if (fileSize == null) return '';
    final kb = fileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  String get fileTypeIcon {
    switch (fileType.toLowerCase()) {
      case 'pdf': return '📄';
      case 'docx': case 'doc': return '📝';
      case 'ppt': case 'pptx': return '📊';
      case 'zip': case 'rar': return '🗜️';
      case 'image': case 'jpg': case 'png': return '🖼️';
      default: return '📎';
    }
  }
}

// Community member with profile data
class CommunityMemberProfile {
  final String userId;
  final String communityId;
  final String role; // owner, moderator, member
  final DateTime joinedAt;
  // Joined from profiles
  final String? fullName;
  final String? avatarUrl;
  final String? programme;
  final String? level;
  final bool isVerifiedLeader;
  final String? leadershipRole;

  const CommunityMemberProfile({
    required this.userId,
    required this.communityId,
    required this.role,
    required this.joinedAt,
    this.fullName,
    this.avatarUrl,
    this.programme,
    this.level,
    this.isVerifiedLeader = false,
    this.leadershipRole,
  });

  factory CommunityMemberProfile.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    return CommunityMemberProfile(
      userId: json['user_id'] as String,
      communityId: json['community_id'] as String,
      role: json['role'] as String? ?? 'member',
      joinedAt: DateTime.parse(json['joined_at'] as String),
      fullName: p?['full_name'] as String?,
      avatarUrl: p?['avatar_url'] as String?,
      programme: p?['programme'] as String?,
      level: p?['level'] as String?,
      isVerifiedLeader: p?['is_verified_leader'] as bool? ?? false,
      leadershipRole: p?['leadership_role'] as String?,
    );
  }

  String get initials {
    if (fullName == null || fullName!.isEmpty) return '?';
    final parts = fullName!.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}
