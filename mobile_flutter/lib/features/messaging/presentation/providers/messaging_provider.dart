import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unify/core/providers/supabase_provider.dart';
import 'package:unify/features/messaging/data/models/conversation_model.dart';
import 'package:unify/features/messaging/data/models/message_model.dart';
import 'package:unify/features/messaging/data/models/channel_model.dart';
import 'package:unify/features/messaging/data/repositories/messaging_repository_impl.dart';
import 'package:unify/features/messaging/domain/repositories/messaging_repository.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return MessagingRepositoryImpl(supabase);
});

final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(supabaseProvider).auth.currentUser;
  return user?.id;
});

final conversationsProvider = StreamProvider<List<ConversationModel>>((ref) {
  final repo = ref.watch(messagingRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  return repo.conversations(userId);
});

final selectedConversationProvider = StateProvider<String?>((ref) => null);

final selectedChannelProvider = StateProvider<String?>((ref) => null);

final messagesProvider = StreamProvider<List<MessageModel>>((ref) {
  final repo = ref.watch(messagingRepositoryProvider);
  final conversationId = ref.watch(selectedConversationProvider);
  final channelId = ref.watch(selectedChannelProvider);
  if (conversationId == null) return Stream.value([]);
  return repo.messages(conversationId, channelId: channelId);
});

final channelsProvider = StreamProvider.family<List<ChannelModel>, String>((ref, conversationId) {
  final repo = ref.watch(messagingRepositoryProvider);
  return repo.channels(conversationId);
});

final messageRequestsProvider = FutureProvider<List<MessageRequest>>((ref) async {
  final repo = ref.watch(messagingRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return repo.messageRequests(userId);
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(messagingRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0;
  return repo.unreadCount(userId);
});

final searchUsersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.length < 2) return [];
  final repo = ref.watch(messagingRepositoryProvider);
  return repo.searchUsers(query);
});

class MessagingNotifier extends StateNotifier<MessagingState> {
  final MessagingRepository _repo;
  final String? _userId;

  MessagingNotifier(this._repo, this._userId) : super(MessagingState());

  Future<void> sendMessage({
    required String conversationId,
    String? channelId,
    String? content,
    List<Map<String, dynamic>>? attachments,
    String? replyToId,
  }) async {
    if ((content == null || content.isEmpty) && (attachments == null || attachments.isEmpty)) return;
    if (_userId == null) return;

    final msg = MessageModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      conversationId: conversationId,
      channelId: channelId,
      senderId: _userId,
      content: content,
      replyToId: replyToId,
      createdAt: DateTime.now(),
      isSending: false,
    );
    await _repo.sendMessage(msg);
  }

  Future<void> toggleReaction(String messageId, String reaction) async {
    if (_userId == null) return;
    await _repo.addReaction(messageId, _userId, reaction);
  }

  Future<void> pinMessage(String messageId, bool pinned) async {
    await _repo.pinMessage(messageId, pinned);
  }

  Future<void> createConversation({
    required String type,
    String? title,
    String? communityId,
    List<String> participantIds = const [],
  }) async {
    if (_userId == null) return;
    final conv = ConversationModel(
      id: '',
      type: type,
      title: title,
      communityId: communityId,
      createdBy: _userId,
      lastMessageAt: DateTime.now(),
      createdAt: DateTime.now(),
      participants: [],
    );
    final allParticipants = [if (!participantIds.contains(_userId)) _userId, ...participantIds];
    await _repo.createConversation(conv, allParticipants);
  }

  Future<void> markAsRead(String conversationId, String lastMessageId) async {
    if (_userId == null) return;
    await _repo.markAsRead(conversationId, _userId, lastMessageId);
  }

  Future<void> votePoll(String pollId, int optionIndex) async {
    if (_userId == null) return;
    await _repo.votePoll(pollId, _userId, optionIndex);
  }
}

class MessagingState {
  final bool isLoading;
  final String? error;

  MessagingState({this.isLoading = false, this.error});
}

final messagingProvider = StateNotifierProvider<MessagingNotifier, MessagingState>((ref) {
  final repo = ref.watch(messagingRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return MessagingNotifier(repo, userId);
});

// ── Pinned conversations (client-side, session-scoped) ────────────────────
class _PinnedNotifier extends StateNotifier<Set<String>> {
  _PinnedNotifier() : super({});
  void toggle(String id) =>
      state = state.contains(id)
          ? state.where((x) => x != id).toSet()
          : {...state, id};
  bool isPinned(String id) => state.contains(id);
}

final pinnedConversationsProvider =
    StateNotifierProvider<_PinnedNotifier, Set<String>>(
        (_) => _PinnedNotifier());

// ── Per-conversation typing stream ────────────────────────────────────────
final typingProvider =
    StreamProvider.family<int, String>((ref, conversationId) {
  final repo = ref.watch(messagingRepositoryProvider);
  return repo.typingStatus(conversationId);
});

// ── Message search within a conversation ─────────────────────────────────
final chatSearchQueryProvider =
    StateProvider.family<String, String>((ref, _) => '');

// ── Reply-to state (per conversation) ────────────────────────────────────
final replyToMessageProvider =
    StateProvider.family<MessageModel?, String>((ref, _) => null);
