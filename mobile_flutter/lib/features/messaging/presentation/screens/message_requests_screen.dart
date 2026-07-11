import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/widgets/app_empty_widget.dart';
import 'package:unify/core/widgets/app_error_widget.dart';
import 'package:unify/features/messaging/data/models/message_model.dart';
import 'package:unify/features/messaging/presentation/providers/messaging_provider.dart';
import 'package:unify/core/widgets/app_loading_widget.dart';

class MessageRequestsScreen extends ConsumerWidget {
  const MessageRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(messageRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Message Requests')),
      body: requestsAsync.when(
        loading: () => const AppLoadingWidget.list(itemCount: 3),
        error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(messageRequestsProvider)),
        data: (requests) {
          if (requests.isEmpty) {
            return const AppEmptyWidget(
              icon: Icons.pending_actions_rounded,
              title: 'No pending requests',
            );
          }
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (_, i) => _RequestTile(request: requests[i]),
          );
        },
      ),
    );
  }
}

class _RequestTile extends ConsumerWidget {
  final MessageRequest request;
  const _RequestTile({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          child: Text(
            (request.fromUserName?[0] ?? '?').toUpperCase(),
            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(request.fromUserName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: request.previewContent != null ? Text(request.previewContent!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'Decline',
              onPressed: () async {
                final repo = ref.read(messagingRepositoryProvider);
                await repo.declineRequest(request.id);
                ref.invalidate(messageRequestsProvider);
              },
            ),
            IconButton(
              icon: Icon(Icons.check_circle, color: theme.colorScheme.primary),
              tooltip: 'Accept',
              onPressed: () async {
                final repo = ref.read(messagingRepositoryProvider);
                final convId = request.conversationId ?? request.id;
                await repo.acceptRequest(request.id, convId);
                ref.invalidate(messageRequestsProvider);
                if (context.mounted) {
                  context.push('/messaging/chat/$convId', extra: {
                    'name': request.fromUserName ?? 'Chat',
                    'conversationId': convId,
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
