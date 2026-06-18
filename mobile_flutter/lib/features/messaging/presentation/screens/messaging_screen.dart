import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/features/messaging/presentation/providers/messaging_provider.dart';

class MessagingScreen extends ConsumerWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UNIFY Chat'),
        actions: [
          IconButton(
            icon: const Badge(
              isLabelVisible: false,
              child: Icon(Icons.person_add_alt_1),
            ),
            onPressed: () => context.push('/messaging/requests'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/messaging/search'),
          ),
        ],
      ),
      body: const ConversationsView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateMenu(context),
        child: const Icon(Icons.edit),
      ),
    );
  }

  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('New Message'),
              onTap: () { Navigator.pop(context); context.push('/messaging/search'); },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('New Group'),
              onTap: () { Navigator.pop(context); context.push('/messaging/create-group'); },
            ),
          ],
        ),
      ),
    );
  }
}

class ConversationsView extends ConsumerWidget {
  const ConversationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convAsync = ref.watch(conversationsProvider);
    final theme = Theme.of(context);

    return convAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (convs) {
        if (convs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No conversations yet', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Tap + to start chatting', style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(conversationsProvider),
          child: ListView.builder(
            itemCount: convs.length,
            itemBuilder: (_, i) => _ConversationTile(
              conversation: convs[i],
              onTap: () {
                ref.read(selectedConversationProvider.notifier).state = convs[i].id;
                context.push('/messaging/chat/${convs[i].id}');
              },
            ),
          ),
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final dynamic conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
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
      title: Text(
        conversation.title ?? 'Unknown',
        style: TextStyle(
          fontWeight: conversation.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
          fontSize: 15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        conversation.lastMessageContent ?? 'No messages yet',
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: conversation.unreadCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }
}
