import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:unify/core/theme/app_colors.dart';
import 'package:unify/features/messaging/data/models/conversation_model.dart';
import 'package:unify/features/messaging/presentation/providers/messaging_provider.dart';

class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final requestsAsync = ref.watch(messageRequestsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/messaging/search'),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: requestsAsync.valueOrNull?.isNotEmpty ?? false,
              label: Text('${requestsAsync.valueOrNull?.length ?? 0}'),
              child: const Icon(Icons.person_add_alt_1),
            ),
            onPressed: () => context.push('/messaging/requests'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(conversationsProvider),
        child: conversationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (conversations) {
            if (conversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text('No conversations yet', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.push('/messaging/search'),
                      child: const Text('Start a conversation'),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (_, i) => _ConversationTile(
                conversation: conversations[i],
                onTap: () {
                  ref.read(selectedConversationProvider.notifier).state = conversations[i].id;
                  context.push('/messaging/chat/${conversations[i].id}');
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/messaging/search'),
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = conversation.unreadCount > 0;

    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            child: Text(
              conversation.initials,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          if (conversation.isVerified)
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified, size: 12, color: AppColors.primary),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              conversation.title ?? 'Unknown',
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conversation.isVerified)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.verified, size: 14, color: AppColors.primary),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          if (conversation.lastMessageSenderName != null)
            Text(
              '${conversation.lastMessageSenderName!}: ',
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                fontSize: 13, color: Colors.grey[600],
              ),
            ),
          Flexible(
            child: Text(
              conversation.lastMessageContent ?? (conversation.type == 'channel' ? 'Tap to view' : 'No messages yet'),
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                fontSize: 13, color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.lastMessageTime != null)
            Text(
              DateFormat('h:mm a').format(conversation.lastMessageTime!),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          if (hasUnread)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          if (conversation.type == 'direct')
            Icon(Icons.check, size: 14, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
