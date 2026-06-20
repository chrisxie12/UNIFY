import 'dart:io';
import 'package:unify/features/messaging/data/models/conversation_model.dart';
import 'package:unify/features/messaging/data/models/message_model.dart';
import 'package:unify/features/messaging/data/models/channel_model.dart';

abstract class MessagingRepository {
  Stream<List<ConversationModel>> conversations(String userId);
  Stream<List<MessageModel>> messages(String conversationId, {String? channelId});
  Stream<List<ChannelModel>> channels(String conversationId);

  Future<void> sendMessage(MessageModel message);
  Future<void> editMessage(String messageId, String newContent);
  Future<void> deleteMessage(String messageId);
  Future<void> addReaction(String messageId, String userId, String reaction);
  Future<void> removeReaction(String messageId, String userId, String reaction);
  Future<void> pinMessage(String messageId, bool pinned);
  Future<void> markAsRead(String conversationId, String userId, String lastMessageId);
  Future<void> createPoll(String messageId, String question, List<String> options, bool multipleChoice, DateTime? expiresAt);
  Future<void> votePoll(String pollId, String userId, int optionIndex);
  Future<void> createConversation(ConversationModel conversation, List<String> participantIds);
  Future<void> addParticipants(String conversationId, List<String> userIds);
  Future<void> removeParticipant(String conversationId, String userId);
  Future<void> updateParticipantRole(String conversationId, String userId, String role);
  Future<void> muteConversation(String conversationId, String userId, bool muted);

  Future<List<MessageRequest>> messageRequests(String userId);
  Future<void> sendMessageRequest(String fromUserId, String toUserId, String? message);
  Future<void> acceptRequest(String requestId, String conversationId);
  Future<void> declineRequest(String requestId);
  Future<void> blockUser(String blockerId, String blockedId);
  Future<void> unblockUser(String blockerId, String blockedId);
  Future<bool> isBlocked(String userId1, String userId2);

  Future<List<Map<String, dynamic>>> searchUsers(String query);
  Future<int> unreadCount(String userId);
  Future<Map<String, int>> unreadCounts(String userId);

  Stream<MessageModel> messageUpdates(String conversationId);
  Stream<int> typingStatus(String conversationId);
  Future<void> setTyping(String conversationId, String userId, bool isTyping);

  Future<void> reportMessage(String messageId, String reportedBy, String reason);
  Future<void> muteNotifications(String conversationId, String userId, Duration duration);

  Future<String?> uploadChatImage(File imageFile);
}
