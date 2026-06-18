import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unify/features/messaging/data/models/message_model.dart';
import 'package:unify/features/messaging/presentation/providers/messaging_provider.dart';

class MessageRequestsScreen extends ConsumerWidget {
  const MessageRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(messageRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Message Requests')),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mail_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No pending requests', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
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

class _RequestTile extends StatelessWidget {
  final MessageRequest request;
  const _RequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {},
              tooltip: 'Decline',
            ),
            IconButton(
              icon: Icon(Icons.check_circle, color: theme.colorScheme.primary),
              onPressed: () {},
              tooltip: 'Accept',
            ),
          ],
        ),
      ),
    );
  }
}
