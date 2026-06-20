import 'package:flutter/material.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String? channelId;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final bool senderIsVerified;
  final String? content;
  final String? replyToId;
  final MessageModel? replyToMessage;
  final String? forwardedFromId;
  final bool isPinned;
  final bool isSystemMessage;
  final DateTime? editedAt;
  final DateTime createdAt;
  final List<MessageAttachment> attachments;
  final List<MessageReaction> reactions;
  final ChatPoll? poll;
  final bool isSending;
  final bool hasFailed;
  bool _isExpanded;

  MessageModel({
    required this.id,
    required this.conversationId,
    this.channelId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    this.senderIsVerified = false,
    this.content,
    this.replyToId,
    this.replyToMessage,
    this.forwardedFromId,
    this.isPinned = false,
    this.isSystemMessage = false,
    this.editedAt,
    required this.createdAt,
    this.attachments = const [],
    this.reactions = const [],
    this.poll,
    this.isSending = false,
    this.hasFailed = false,
    bool isExpanded = false,
  }) : _isExpanded = isExpanded;

  bool get isExpanded => _isExpanded;
  bool get hasAttachments => attachments.isNotEmpty;
  bool get hasReactions => reactions.isNotEmpty;
  bool get hasPoll => poll != null;
  bool get isEdited => editedAt != null;

  set isExpanded(bool v) => _isExpanded = v;

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      channelId: map['channel_id'] as String?,
      senderId: map['sender_id'] as String,
      senderName: map['sender_name'] as String? ?? map['full_name'] as String?,
      senderAvatar: map['sender_avatar'] as String? ?? map['avatar_url'] as String?,
      senderIsVerified: map['sender_is_verified'] as bool? ?? false,
      content: map['content'] as String?,
      replyToId: map['reply_to'] as String?,
      forwardedFromId: map['forwarded_from'] as String?,
      isPinned: map['is_pinned'] as bool? ?? false,
      isSystemMessage: map['is_system_message'] as bool? ?? false,
      editedAt: map['edited_at'] != null ? DateTime.parse(map['edited_at'] as String) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      attachments: map['attachments'] != null
          ? (map['attachments'] as List).map((a) => MessageAttachment.fromMap(a as Map<String, dynamic>)).toList()
          : [],
      reactions: map['reactions'] != null
          ? (map['reactions'] as List).map((r) => MessageReaction.fromMap(r as Map<String, dynamic>)).toList()
          : [],
      poll: map['poll'] != null ? ChatPoll.fromMap(map['poll'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversation_id': conversationId,
      'channel_id': channelId,
      'sender_id': senderId,
      'content': content,
      'reply_to': replyToId,
      'forwarded_from': forwardedFromId,
      'is_system_message': isSystemMessage,
      if (attachments.isNotEmpty)
        'attachments': attachments.map((a) => {
          'id': a.id,
          'type': a.type,
          'url': a.url,
          if (a.name != null) 'name': a.name,
          if (a.size != null) 'size': a.size,
          if (a.mimeType != null) 'mime_type': a.mimeType,
          if (a.width != null) 'width': a.width,
          if (a.height != null) 'height': a.height,
        }).toList(),
    };
  }
}

class MessageAttachment {
  final String id;
  final String type;
  final String url;
  final String? name;
  final int? size;
  final String? mimeType;
  final int? width;
  final int? height;
  final int? duration;

  MessageAttachment({
    required this.id,
    required this.type,
    required this.url,
    this.name,
    this.size,
    this.mimeType,
    this.width,
    this.height,
    this.duration,
  });

  factory MessageAttachment.fromMap(Map<String, dynamic> map) {
    return MessageAttachment(
      id: map['id'] as String,
      type: map['type'] as String,
      url: map['url'] as String,
      name: map['name'] as String?,
      size: map['size'] as int?,
      mimeType: map['mime_type'] as String?,
      width: map['width'] as int?,
      height: map['height'] as int?,
      duration: map['duration'] as int?,
    );
  }

  IconData get icon {
    switch (type) {
      case 'image': return Icons.image;
      case 'video': return Icons.videocam;
      case 'audio': return Icons.audiotrack;
      case 'voice_note': return Icons.mic;
      case 'document': return Icons.description;
      default: return Icons.insert_drive_file;
    }
  }
}

class MessageReaction {
  final String id;
  final String messageId;
  final String userId;
  final String reaction;
  final DateTime createdAt;
  final String? userName;

  MessageReaction({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.reaction,
    required this.createdAt,
    this.userName,
  });

  factory MessageReaction.fromMap(Map<String, dynamic> map) {
    return MessageReaction(
      id: map['id'] as String,
      messageId: map['message_id'] as String,
      userId: map['user_id'] as String,
      reaction: map['reaction'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      userName: map['user_name'] as String?,
    );
  }
}

class ChatPoll {
  final String id;
  final String messageId;
  final String question;
  final List<String> options;
  final bool isMultipleChoice;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final List<ChatPollVote> votes;

  ChatPoll({
    required this.id,
    required this.messageId,
    required this.question,
    required this.options,
    this.isMultipleChoice = false,
    this.expiresAt,
    required this.createdAt,
    this.votes = const [],
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  int totalVotes() => votes.length;
  int votesForOption(int index) => votes.where((v) => v.optionIndex == index).length;
  double percentageForOption(int index) =>
      totalVotes() == 0 ? 0 : votesForOption(index) / totalVotes();

  factory ChatPoll.fromMap(Map<String, dynamic> map) {
    return ChatPoll(
      id: map['id'] as String,
      messageId: map['message_id'] as String,
      question: map['question'] as String,
      options: (map['options'] as List).cast<String>(),
      isMultipleChoice: map['is_multiple_choice'] as bool? ?? false,
      expiresAt: map['expires_at'] != null ? DateTime.parse(map['expires_at'] as String) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      votes: map['votes'] != null
          ? (map['votes'] as List).map((v) => ChatPollVote.fromMap(v as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

class ChatPollVote {
  final String id;
  final String pollId;
  final String userId;
  final int optionIndex;
  final DateTime createdAt;

  ChatPollVote({
    required this.id,
    required this.pollId,
    required this.userId,
    required this.optionIndex,
    required this.createdAt,
  });

  factory ChatPollVote.fromMap(Map<String, dynamic> map) {
    return ChatPollVote(
      id: map['id'] as String,
      pollId: map['poll_id'] as String,
      userId: map['user_id'] as String,
      optionIndex: map['option_index'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class MessageRequest {
  final String id;
  final String fromUserId;
  final String? fromUserName;
  final String? fromUserAvatar;
  final String toUserId;
  final String? conversationId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? previewContent;

  MessageRequest({
    required this.id,
    required this.fromUserId,
    this.fromUserName,
    this.fromUserAvatar,
    required this.toUserId,
    this.conversationId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.previewContent,
  });

  factory MessageRequest.fromMap(Map<String, dynamic> map) {
    return MessageRequest(
      id: map['id'] as String,
      fromUserId: map['from_user_id'] as String,
      fromUserName: map['from_user_name'] as String?,
      fromUserAvatar: map['from_user_avatar'] as String?,
      toUserId: map['to_user_id'] as String,
      conversationId: map['conversation_id'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      previewContent: map['preview_content'] as String?,
    );
  }
}
