import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import 'package:unify/core/design_system/tokens.dart';
import 'package:unify/core/design_system/typography.dart';
import 'package:unify/core/design_system/components.dart';
import 'package:unify/core/extensions/theme_extensions.dart';
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
              loading: () => const AppLoadingWidget.list(),
              error: (e, _) => AppErrorWidget(e),
              data: (discussions) {
                if (discussions.isEmpty) {
                  return Center(
                    child: UEmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: 'No discussions yet',
                      subtitle: 'Be the first to ask a question!',
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(USpacing.md),
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
              color: context.cardBg,
              padding: const EdgeInsets.symmetric(horizontal: USpacing.base, vertical: USpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.reply, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: USpacing.sm),
                  Text('Replying to a comment', style: UText.caption.copyWith(color: context.textSecondary)),
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
              left: USpacing.base, right: USpacing.base, top: USpacing.sm,
              bottom: MediaQuery.of(context).padding.bottom + USpacing.sm,
            ),
            decoration: BoxDecoration(
              color: context.cardBg,
              border: Border(top: BorderSide(color: context.borderCol)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question or share...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: USpacing.md, vertical: 10),
                      isDense: true,
                    ),
                    maxLines: 3,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _postComment(),
                  ),
                ),
                const SizedBox(width: USpacing.sm),
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
      margin: const EdgeInsets.only(bottom: USpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(USpacing.md),
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
                      ? Text((discussion.userName as String? ?? '?')[0], style: UText.caption)
                      : null,
                ),
                const SizedBox(width: USpacing.sm),
                Text(discussion.userName as String? ?? 'User', style: UText.bodyXS.copyWith(fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(discussion.formattedDate as String, style: TextStyle(fontSize: 11, color: context.textSecondary)),
                if (currentUserId == discussion.userId) ...[
                  const SizedBox(width: USpacing.xs),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.delete_outline, size: 16, color: context.textSecondary),
                  ),
                ],
              ],
            ),
            const SizedBox(height: USpacing.sm),
            Text(discussion.content as String, style: UText.bodyS),
            const SizedBox(height: USpacing.sm),
            GestureDetector(
              onTap: onReply,
              child: Text('Reply', style: UText.caption.copyWith(color: theme.colorScheme.primary)),
            ),
            if (discussion.replies != null && (discussion.replies as List).isNotEmpty) ...[
              const SizedBox(height: USpacing.sm),
              Container(
                margin: const EdgeInsets.only(left: USpacing.base),
                padding: const EdgeInsets.all(USpacing.sm),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: URadius.smAll,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (discussion.replies as List).map((reply) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: USpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(radius: 10, child: Text((reply.userName as String? ?? '?')[0], style: const TextStyle(fontSize: 9))),
                          const SizedBox(width: USpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(reply.userName as String? ?? 'User', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Text(reply.formattedDate as String, style: TextStyle(fontSize: 9, color: context.textSecondary)),
                                ]),
                                Text(reply.content as String, style: UText.caption),
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
