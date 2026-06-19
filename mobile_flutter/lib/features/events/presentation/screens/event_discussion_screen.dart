import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/event_provider.dart';

class EventDiscussionScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDiscussionScreen({super.key, required this.eventId});
  @override
  ConsumerState<EventDiscussionScreen> createState() => _EventDiscussionScreenState();
}

class _EventDiscussionScreenState extends ConsumerState<EventDiscussionScreen> {
  final _commentCtrl = TextEditingController();
  String? _replyToId;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final content = _commentCtrl.text.trim();
    if (content.isEmpty) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    await ref.read(eventRepositoryProvider).postDiscussion(
      widget.eventId, userId, content,
      parentId: _replyToId,
    );

    _commentCtrl.clear();
    setState(() => _replyToId = null);
    ref.invalidate(eventDiscussionsProvider(widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discussionsAsync = ref.watch(eventDiscussionsProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Discussion')),
      body: Column(
        children: [
          Expanded(
            child: discussionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppErrorWidget(e),
              data: (discussions) {
                if (discussions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No discussions yet', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Be the first to ask a question!', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: discussions.length,
                  itemBuilder: (_, i) {
                    final d = discussions[i];
                    return _DiscussionCard(
                      discussion: d,
                      theme: theme,
                      onReply: () => setState(() => _replyToId = d.id),
                      onDelete: () {
                        ref.read(eventRepositoryProvider).deleteDiscussion(d.id, d.userId);
                        ref.invalidate(eventDiscussionsProvider(widget.eventId));
                      },
                      currentUserId: ref.read(currentUserIdProvider),
                    );
                  },
                );
              },
            ),
          ),
          if (_replyToId != null)
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.reply, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Replying to a comment', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _replyToId = null),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question or share...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    maxLines: 3,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _postComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: theme.colorScheme.primary),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscussionCard extends StatelessWidget {
  final dynamic discussion;
  final ThemeData theme;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final String? currentUserId;
  const _DiscussionCard({
    required this.discussion, required this.theme, required this.onReply,
    required this.onDelete, required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: discussion.userAvatar != null
                      ? NetworkImage(discussion.userAvatar as String)
                      : null,
                  child: discussion.userAvatar == null
                      ? Text((discussion.userName as String? ?? '?')[0], style: const TextStyle(fontSize: 12))
                      : null,
                ),
                const SizedBox(width: 8),
                Text(discussion.userName as String? ?? 'User', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                const Spacer(),
                Text(discussion.formattedDate as String, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                if (currentUserId == discussion.userId) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.delete_outline, size: 16, color: Colors.grey[400]),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(discussion.content as String, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onReply,
              child: Text('Reply', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
            ),
            if (discussion.replies != null && (discussion.replies as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (discussion.replies as List).map((reply) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(radius: 10, child: Text((reply.userName as String? ?? '?')[0], style: const TextStyle(fontSize: 9))),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(reply.userName as String? ?? 'User', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Text(reply.formattedDate as String, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                                ]),
                                Text(reply.content as String, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
