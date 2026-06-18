import 'package:flutter/material.dart';
import 'package:unify/core/theme/app_colors.dart';

class ConversationModel {
  final String id;
  final String type;
  final String? title;
  final String? avatarUrl;
  final String? communityId;
  final String? createdBy;
  final bool isVerified;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  final int unreadCount;
  final String? lastMessageContent;
  final String? lastMessageSenderName;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderAvatar;
  final List<ConversationParticipant> participants;

  ConversationModel({
    required this.id,
    required this.type,
    this.title,
    this.avatarUrl,
    this.communityId,
    this.createdBy,
    this.isVerified = false,
    required this.lastMessageAt,
    required this.createdAt,
    this.unreadCount = 0,
    this.lastMessageContent,
    this.lastMessageSenderName,
    this.lastMessageTime,
    this.lastMessageSenderAvatar,
    this.participants = const [],
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] as String,
      type: map['type'] as String,
      title: map['title'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      communityId: map['community_id'] as String?,
      createdBy: map['created_by'] as String?,
      isVerified: map['is_verified'] as bool? ?? false,
      lastMessageAt: DateTime.parse(map['last_message_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      unreadCount: map['unread_count'] as int? ?? 0,
      lastMessageContent: map['last_message_content'] as String?,
      lastMessageSenderName: map['last_message_sender_name'] as String?,
      lastMessageTime: map['last_message_time'] != null
          ? DateTime.tryParse(map['last_message_time'] as String)
          : null,
      lastMessageSenderAvatar: map['last_message_sender_avatar'] as String?,
      participants: map['participants'] != null
          ? (map['participants'] as List)
              .map((p) => ConversationParticipant.fromMap(p as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  String get initials {
    if (title != null && title!.isNotEmpty) {
      return title!.split(' ').map((w) => w[0]).take(2).join().toUpperCase();
    }
    if (type == 'direct') {
      final others = participants.where((p) => !p.isCurrentUser).toList();
      if (others.isNotEmpty) {
        final name = others.first.displayName ?? 'U';
        return name.split(' ').map((w) => w[0]).take(2).join().toUpperCase();
      }
    }
    return '?';
  }
}

class ConversationParticipant {
  final String id;
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final String role;
  final DateTime joinedAt;
  final DateTime lastReadAt;
  final bool isMuted;
  final bool isCurrentUser;
  final bool isVerified;

  ConversationParticipant({
    required this.id,
    required this.userId,
    this.displayName,
    this.avatarUrl,
    this.role = 'member',
    required this.joinedAt,
    required this.lastReadAt,
    this.isMuted = false,
    this.isCurrentUser = false,
    this.isVerified = false,
  });

  factory ConversationParticipant.fromMap(Map<String, dynamic> map) {
    return ConversationParticipant(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      displayName: map['display_name'] as String? ?? map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      role: map['role'] as String? ?? 'member',
      joinedAt: DateTime.parse(map['joined_at'] as String),
      lastReadAt: DateTime.parse(map['last_read_at'] as String),
      isMuted: map['is_muted'] as bool? ?? false,
      isCurrentUser: map['is_current_user'] as bool? ?? false,
      isVerified: map['is_verified'] as bool? ?? false,
    );
  }

  Color? get badgeColor {
    if (!isVerified) return null;
    return AppColors.primary;
  }
}
