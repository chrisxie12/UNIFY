import 'package:flutter/material.dart';

/// A single 24-hour snapshot (story).
class SnapshotModel {
  final String id;
  final String authorId;
  final String? communityId;
  final String type; // photo | video | text | poll | question
  final String? mediaUrl;
  final String? caption;
  final String? textContent;
  final String? backgroundColor; // hex e.g. '#1E40AF'
  final String audience; // public | friends | community
  final bool isOfficial;
  final int viewCount;
  final int reactionCount;
  final int replyCount;
  final DateTime createdAt;
  final DateTime expiresAt;
  // Joined author profile
  final String? authorName;
  final String? authorAvatar;
  final bool authorIsVerified;
  final String? authorLeadershipRole;
  // Joined poll options
  final List<SnapshotPollOption> pollOptions;

  const SnapshotModel({
    required this.id,
    required this.authorId,
    this.communityId,
    required this.type,
    this.mediaUrl,
    this.caption,
    this.textContent,
    this.backgroundColor,
    this.audience = 'public',
    this.isOfficial = false,
    this.viewCount = 0,
    this.reactionCount = 0,
    this.replyCount = 0,
    required this.createdAt,
    required this.expiresAt,
    this.authorName,
    this.authorAvatar,
    this.authorIsVerified = false,
    this.authorLeadershipRole,
    this.pollOptions = const [],
  });

  factory SnapshotModel.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    final opts = (json['snapshot_poll_options'] as List?)
            ?.map((o) => SnapshotPollOption.fromJson(o as Map<String, dynamic>))
            .toList() ??
        const <SnapshotPollOption>[];
    opts.sort((a, b) => a.position.compareTo(b.position));
    return SnapshotModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      communityId: json['community_id'] as String?,
      type: json['type'] as String,
      mediaUrl: json['media_url'] as String?,
      caption: json['caption'] as String?,
      textContent: json['text_content'] as String?,
      backgroundColor: json['background_color'] as String?,
      audience: json['audience'] as String? ?? 'public',
      isOfficial: json['is_official'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      reactionCount: json['reaction_count'] as int? ?? 0,
      replyCount: json['reply_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      authorName: p?['full_name'] as String?,
      authorAvatar: p?['avatar_url'] as String?,
      authorIsVerified: p?['is_verified_leader'] as bool? ?? false,
      authorLeadershipRole: p?['leadership_role'] as String?,
      pollOptions: opts,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPoll => type == 'poll';
  bool get isQuestion => type == 'question';
  bool get isText => type == 'text';
  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;
  int get totalPollVotes =>
      pollOptions.fold(0, (sum, o) => sum + o.voteCount);

  /// Parsed background color, falling back to a brand blue.
  Color get bgColor {
    final hex = backgroundColor;
    if (hex == null || hex.isEmpty) return const Color(0xFF1E40AF);
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return const Color(0xFF1E40AF);
    return Color(cleaned.length <= 6 ? 0xFF000000 | value : value);
  }
}

/// One option in a poll snapshot.
class SnapshotPollOption {
  final String id;
  final String label;
  final int position;
  final int voteCount;

  const SnapshotPollOption({
    required this.id,
    required this.label,
    this.position = 0,
    this.voteCount = 0,
  });

  factory SnapshotPollOption.fromJson(Map<String, dynamic> json) =>
      SnapshotPollOption(
        id: json['id'] as String,
        label: json['label'] as String,
        position: json['position'] as int? ?? 0,
        voteCount: json['vote_count'] as int? ?? 0,
      );
}

/// All snapshots from a single author, grouped for the story tray/viewer.
class SnapshotGroup {
  final String authorId;
  final String? authorName;
  final String? authorAvatar;
  final bool authorIsVerified;
  final String? authorLeadershipRole;
  final List<SnapshotModel> snapshots; // oldest → newest
  final bool hasUnseen;

  const SnapshotGroup({
    required this.authorId,
    this.authorName,
    this.authorAvatar,
    this.authorIsVerified = false,
    this.authorLeadershipRole,
    required this.snapshots,
    this.hasUnseen = true,
  });

  bool get isOfficial => authorIsVerified;
  DateTime get latestAt => snapshots.last.createdAt;

  String get initials {
    final n = authorName;
    if (n == null || n.trim().isEmpty) return '?';
    final parts = n.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}

/// A private reply to a snapshot (delivered to the author as a DM).
class SnapshotReplyModel {
  final String id;
  final String snapshotId;
  final String senderId;
  final String body;
  final DateTime createdAt;
  final String? senderName;
  final String? senderAvatar;

  const SnapshotReplyModel({
    required this.id,
    required this.snapshotId,
    required this.senderId,
    required this.body,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
  });

  factory SnapshotReplyModel.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    return SnapshotReplyModel(
      id: json['id'] as String,
      snapshotId: json['snapshot_id'] as String,
      senderId: json['sender_id'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderName: p?['full_name'] as String?,
      senderAvatar: p?['avatar_url'] as String?,
    );
  }
}

/// A single viewer of a snapshot (for leader analytics).
class SnapshotViewer {
  final String userId;
  final String? name;
  final String? avatar;
  final DateTime viewedAt;

  const SnapshotViewer({
    required this.userId,
    this.name,
    this.avatar,
    required this.viewedAt,
  });

  factory SnapshotViewer.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    return SnapshotViewer(
      userId: json['viewer_id'] as String,
      name: p?['full_name'] as String?,
      avatar: p?['avatar_url'] as String?,
      viewedAt: DateTime.parse(json['viewed_at'] as String),
    );
  }

  String get initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}

/// Aggregated analytics for a leader's snapshot.
class SnapshotAnalytics {
  final int viewCount;
  final int reactionCount;
  final int replyCount;
  final Map<String, int> reactionsByEmoji;
  final List<SnapshotViewer> viewers;

  const SnapshotAnalytics({
    this.viewCount = 0,
    this.reactionCount = 0,
    this.replyCount = 0,
    this.reactionsByEmoji = const {},
    this.viewers = const [],
  });
}
