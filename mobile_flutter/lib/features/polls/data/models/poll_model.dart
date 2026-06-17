import 'poll_option_model.dart';

class PollModel {
  final String id;
  final String communityId;
  final String creatorId;
  final String? creatorName;
  final String? creatorAvatar;
  final String question;
  final String? description;
  final String pollType;
  final bool isAnonymous;
  final bool isLocked;
  final DateTime? expiresAt;
  final int totalVotes;
  final String? myVote;
  final List<PollOptionModel> options;
  final DateTime createdAt;

  const PollModel({
    required this.id,
    required this.communityId,
    required this.creatorId,
    this.creatorName,
    this.creatorAvatar,
    required this.question,
    this.description,
    required this.pollType,
    this.isAnonymous = false,
    this.isLocked = false,
    this.expiresAt,
    this.totalVotes = 0,
    this.myVote,
    this.options = const [],
    required this.createdAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      creatorId: json['creator_id'] as String,
      creatorName: json['creator_name'] as String? ?? json['display_name'] as String?,
      creatorAvatar: json['creator_avatar'] as String? ?? json['avatar_url'] as String?,
      question: json['question'] as String,
      description: json['description'] as String?,
      pollType: json['poll_type'] as String,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      isLocked: json['is_locked'] as bool? ?? false,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      totalVotes: json['total_votes'] as int? ?? 0,
      myVote: json['my_vote'] as String?,
      options: json['options'] != null
          ? (json['options'] as List).map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>)).toList()
          : const [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'community_id': communityId,
      'creator_id': creatorId,
      'question': question,
      'description': description,
      'poll_type': pollType,
      'is_anonymous': isAnonymous,
      'is_locked': isLocked,
      'expires_at': expiresAt?.toIso8601String(),
      'total_votes': totalVotes,
      'options': options.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'community_id': communityId,
      'creator_id': creatorId,
      'question': question,
      if (description != null) 'description': description,
      'poll_type': pollType,
      if (isAnonymous) 'is_anonymous': true,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }
}
