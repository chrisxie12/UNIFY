import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unify/features/messaging/data/models/conversation_model.dart';
import 'package:unify/features/messaging/data/models/message_model.dart';
import 'package:unify/features/messaging/data/models/channel_model.dart';
import 'package:unify/features/messaging/domain/repositories/messaging_repository.dart';

class MessagingRepositoryImpl implements MessagingRepository {
  final SupabaseClient _client;

  MessagingRepositoryImpl(this._client);

  @override
  Stream<List<ConversationModel>> conversations(String userId) {
    return _client
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('last_message_at', ascending: false)
        .limit(50)
        .map((maps) =>
            maps.map((m) => ConversationModel.fromMap(m)).toList());
  }

  @override
  Stream<List<MessageModel>> messages(String conversationId, {String? channelId}) {
    final now = DateTime.now();
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false)
        .limit(100)
        .map((maps) => maps
            .where((m) {
              final exp = m['expires_at'];
              if (exp == null) return true;
              return DateTime.parse(exp as String).isAfter(now);
            })
            .map((m) => MessageModel.fromMap(m))
            .toList());
  }

  @override
  Stream<List<ChannelModel>> channels(String conversationId) {
    return _client
        .from('channels')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('position', ascending: true)
        .limit(50)
        .map((maps) =>
            maps.map((m) => ChannelModel.fromMap(m)).toList());
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    final map = message.toMap();
    map['id'] = message.id;
    await _client.from('messages').insert(map);
  }

  @override
  Future<void> editMessage(String messageId, String newContent) async {
    await _client
        .from('messages')
        .update({'content': newContent, 'edited_at': DateTime.now().toIso8601String()})
        .eq('id', messageId);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _client.from('messages').delete().eq('id', messageId);
  }

  @override
  Future<void> addReaction(String messageId, String userId, String reaction) async {
    try {
      await _client.from('message_reactions').insert({
        'message_id': messageId,
        'user_id': userId,
        'reaction': reaction,
      });
    } catch (_) {
      await _client
          .from('message_reactions')
          .delete()
          .eq('message_id', messageId)
          .eq('user_id', userId)
          .eq('reaction', reaction);
    }
  }

  @override
  Future<void> removeReaction(String messageId, String userId, String reaction) async {
    await _client
        .from('message_reactions')
        .delete()
        .eq('message_id', messageId)
        .eq('user_id', userId)
        .eq('reaction', reaction);
  }

  @override
  Future<void> pinMessage(String messageId, bool pinned) async {
    await _client
        .from('messages')
        .update({'is_pinned': pinned})
        .eq('id', messageId);
  }

  @override
  Future<void> markAsRead(String conversationId, String userId, String lastMessageId) async {
    await _client.from('message_read_receipts').upsert({
      'user_id': userId,
      'message_id': lastMessageId,
      'conversation_id': conversationId,
      'read_at': DateTime.now().toIso8601String(),
    });
    await _client
        .from('conversation_participants')
        .update({'last_read_at': DateTime.now().toIso8601String()})
        .eq('conversation_id', conversationId)
        .eq('user_id', userId);
  }

  @override
  Future<void> createPoll(String messageId, String question, List<String> options, bool multipleChoice, DateTime? expiresAt) async {
    await _client.from('chat_polls').insert({
      'message_id': messageId,
      'question': question,
      'options': options,
      'is_multiple_choice': multipleChoice,
      'expires_at': expiresAt?.toIso8601String(),
    });
  }

  @override
  Future<void> votePoll(String pollId, String userId, int optionIndex) async {
    try {
      await _client.from('chat_poll_votes').insert({
        'poll_id': pollId,
        'user_id': userId,
        'option_index': optionIndex,
      });
    } catch (_) {
      await _client
          .from('chat_poll_votes')
          .update({'option_index': optionIndex})
          .eq('poll_id', pollId)
          .eq('user_id', userId);
    }
  }

  @override
  Future<void> createConversation(ConversationModel conversation, List<String> participantIds) async {
    final convResult = await _client.from('conversations').insert({
      'type': conversation.type,
      'title': conversation.title,
      'avatar_url': conversation.avatarUrl,
      'community_id': conversation.communityId,
      'created_by': conversation.createdBy,
      'is_verified': conversation.isVerified,
    }).select('id').single();

    final convId = convResult['id'] as String;
    final participants = participantIds.map((uid) => ({
      'conversation_id': convId,
      'user_id': uid,
      'role': uid == conversation.createdBy ? 'admin' : 'member',
    })).toList();

    await _client.from('conversation_participants').insert(participants);
  }

  @override
  Future<String> getOrCreateDirectConversation(String targetUserId) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('Not authenticated');

    // Gather all conversation IDs where the current user participates
    final myRows = await _client
        .from('conversation_participants')
        .select('conversation_id')
        .eq('user_id', currentUserId)
        .limit(500);
    final myIds = (myRows as List).map((e) => e['conversation_id'] as String).toList();

    if (myIds.isNotEmpty) {
      // Among those, find any that are direct-type conversations
      final directRows = await _client
          .from('conversations')
          .select('id')
          .eq('type', 'direct')
          .inFilter('id', myIds)
          .limit(500);
      final directIds = (directRows as List).map((e) => e['id'] as String).toList();

      if (directIds.isNotEmpty) {
        // Check if the target user is also in one of those DMs
        final sharedRows = await _client
            .from('conversation_participants')
            .select('conversation_id')
            .eq('user_id', targetUserId)
            .inFilter('conversation_id', directIds)
            .limit(50);
        if ((sharedRows as List).isNotEmpty) {
          return sharedRows.first['conversation_id'] as String;
        }
      }
    }

    // No existing DM — create one
    final convResult = await _client.from('conversations').insert({
      'type': 'direct',
      'created_by': currentUserId,
    }).select('id').single();
    final convId = convResult['id'] as String;
    await _client.from('conversation_participants').insert([
      {'conversation_id': convId, 'user_id': currentUserId, 'role': 'admin'},
      {'conversation_id': convId, 'user_id': targetUserId, 'role': 'member'},
    ]);
    return convId;
  }

  @override
  Future<void> addParticipants(String conversationId, List<String> userIds) async {
    final participants = userIds.map((uid) => ({
      'conversation_id': conversationId,
      'user_id': uid,
    })).toList();
    await _client.from('conversation_participants').insert(participants);
  }

  @override
  Future<void> removeParticipant(String conversationId, String userId) async {
    await _client
        .from('conversation_participants')
        .delete()
        .eq('conversation_id', conversationId)
        .eq('user_id', userId);
  }

  @override
  Future<void> updateParticipantRole(String conversationId, String userId, String role) async {
    await _client
        .from('conversation_participants')
        .update({'role': role})
        .eq('conversation_id', conversationId)
        .eq('user_id', userId);
  }

  @override
  Future<void> muteConversation(String conversationId, String userId, bool muted) async {
    await _client
        .from('conversation_participants')
        .update({'is_muted': muted})
        .eq('conversation_id', conversationId)
        .eq('user_id', userId);
  }

  @override
  Future<List<MessageRequest>> messageRequests(String userId) async {
    // Fetch requests without PostgREST join (FK may not be in schema cache)
    final data = await _client
        .from('message_requests')
        .select('*')
        .eq('to_user_id', userId)
        .eq('status', 'pending')
        .order('created_at', ascending: false)
        .limit(50);

    final rows = (data as List).cast<Map<String, dynamic>>();

    // Batch-fetch sender profiles separately to enrich the rows
    try {
      final senderIds = rows.map((r) => r['from_user_id'] as String).toSet().toList();
      if (senderIds.isNotEmpty) {
        final profiles = await _client
            .from('profiles')
            .select('id, full_name, avatar_url')
            .inFilter('id', senderIds);
        final profileMap = <String, Map<String, dynamic>>{
          for (final p in (profiles as List).cast<Map<String, dynamic>>())
            p['id'] as String: p,
        };
        for (final row in rows) {
          final profile = profileMap[row['from_user_id']];
          row['from_user_name'] = profile?['full_name'];
          row['from_user_avatar'] = profile?['avatar_url'];
        }
      }
    } catch (_) {
      // Profile enrichment is non-critical; proceed with IDs only
    }

    return rows.map(MessageRequest.fromMap).toList();
  }

  @override
  Future<void> sendMessageRequest(String fromUserId, String toUserId, String? message) async {
    await _client.from('message_requests').insert({
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'preview_content': message,
      'status': 'pending',
    });
  }

  @override
  Future<void> acceptRequest(String requestId, String conversationId) async {
    await _client
        .from('message_requests')
        .update({'status': 'accepted', 'conversation_id': conversationId})
        .eq('id', requestId);
  }

  @override
  Future<void> declineRequest(String requestId) async {
    await _client
        .from('message_requests')
        .update({'status': 'declined'})
        .eq('id', requestId);
  }

  @override
  Future<void> blockUser(String blockerId, String blockedId) async {
    await _client.from('blocked_users').insert({
      'blocker_id': blockerId,
      'blocked_id': blockedId,
    });
  }

  @override
  Future<void> unblockUser(String blockerId, String blockedId) async {
    await _client
        .from('blocked_users')
        .delete()
        .eq('blocker_id', blockerId)
        .eq('blocked_id', blockedId);
  }

  @override
  Future<bool> isBlocked(String userId1, String userId2) async {
    final result = await _client
        .from('blocked_users')
        .select('id')
        .or('and(blocker_id.eq.$userId1,blocked_id.eq.$userId2),and(blocker_id.eq.$userId2,blocked_id.eq.$userId1)')
        .maybeSingle();
    return result != null;
  }

  String _escapeSearch(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_')
        .replaceAll(',', ' ');
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final safe = _escapeSearch(query);
    final data = await _client
        .from('profiles')
        .select('id, full_name, avatar_url, programme, level, department, community_name')
        .or('full_name.ilike.%$safe%,programme.ilike.%$safe%,department.ilike.%$safe%')
        .limit(20);
    return (data as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<int> unreadCount(String userId) async {
    final data = await _client.rpc('get_unread_count', params: {'p_user_id': userId});
    return data as int;
  }

  @override
  Future<Map<String, int>> unreadCounts(String userId) async {
    final data = await _client
        .from('message_read_receipts')
        .select('conversation_id')
        .eq('user_id', userId)
        .eq('is_read', false)
        .limit(100);
    final map = <String, int>{};
    for (final row in (data as List)) {
      final cid = row['conversation_id'] as String;
      map[cid] = (map[cid] ?? 0) + 1;
    }
    return map;
  }

  @override
  Stream<MessageModel> messageUpdates(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false)
        .limit(1)
        .map((maps) {
          if (maps.isEmpty) return null;
          return MessageModel.fromMap(maps.first);
        })
        .where((m) => m != null)
        .cast<MessageModel>();
  }

  @override
  Stream<int> typingStatus(String conversationId) {
    return _client
        .from('conversation_participants')
        .stream(primaryKey: ['id'])
        .map((_) => 0);
  }

  @override
  Future<void> setTyping(String conversationId, String userId, bool isTyping) async {
    await _client
        .from('conversation_participants')
        .update({'is_typing': isTyping})
        .eq('conversation_id', conversationId)
        .eq('user_id', userId);
  }

  @override
  Future<void> reportMessage(String messageId, String reportedBy, String reason) async {
    await _client.from('message_reports').insert({
      'message_id': messageId,
      'reported_by': reportedBy,
      'reason': reason,
    });
  }

  @override
  Future<void> muteNotifications(String conversationId, String userId, Duration duration) async {
    final mutedUntil = DateTime.now().add(duration).toIso8601String();
    await _client
        .from('conversation_participants')
        .update({'muted_until': mutedUntil})
        .eq('conversation_id', conversationId)
        .eq('user_id', userId);
  }

  @override
  Future<String?> uploadChatImage(File imageFile) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return null;
      final ext = imageFile.path.split('.').last.toLowerCase();
      final path = 'chat/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _client.storage.from('chat-images').upload(path, imageFile);
      return _client.storage.from('chat-images').getPublicUrl(path);
    } catch (e) {
      debugPrint('[MessagingRepo] uploadChatImage error: $e');
      return null;
    }
  }
}
