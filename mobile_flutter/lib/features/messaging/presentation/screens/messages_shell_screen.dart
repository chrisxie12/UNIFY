import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/features/messaging/presentation/providers/messaging_provider.dart';

class MessagesShellScreen extends ConsumerStatefulWidget {
  const MessagesShellScreen({super.key});

  @override
  ConsumerState<MessagesShellScreen> createState() => _MessagesShellScreenState();
}

class _MessagesShellScreenState extends ConsumerState<MessagesShellScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UNIFY Chat'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Direct'),
            Tab(text: 'Groups'),
            Tab(text: 'Channels'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FilteredConversationsList(filter: (c) => true),
          _FilteredConversationsList(filter: (c) => c.type == 'direct'),
          _FilteredConversationsList(filter: (c) => c.type == 'group' || c.type == 'study_group'),
          _FilteredConversationsList(filter: (c) => c.type == 'channel' || c.type == 'announcement'),
        ],
      ),
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

class _FilteredConversationsList extends ConsumerWidget {
  final bool Function(dynamic) filter;
  const _FilteredConversationsList({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convAsync = ref.watch(conversationsProvider);
    final theme = Theme.of(context);

    return convAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (convs) {
        final filtered = convs.where(filter).toList();
        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('Nothing here yet', style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (_, i) => ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              child: Text(
                filtered[i].initials,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: theme.colorScheme.primary),
              ),
            ),
            title: Text(filtered[i].title ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(filtered[i].lastMessageContent ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            trailing: filtered[i].unreadCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${filtered[i].unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                  )
                : null,
            onTap: () {
              ref.read(selectedConversationProvider.notifier).state = filtered[i].id;
              context.push('/messaging/chat/${filtered[i].id}');
            },
          ),
        );
      },
    );
  }
}
