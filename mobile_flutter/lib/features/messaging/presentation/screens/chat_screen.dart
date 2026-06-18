import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unify/core/theme/app_colors.dart';
import 'package:unify/features/messaging/data/models/message_model.dart';
import 'package:unify/features/messaging/presentation/providers/messaging_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String? _replyToId;
  bool _showAttachmentMenu = false;

  @override
  void initState() {
    super.initState();
    ref.read(selectedConversationProvider.notifier).state = widget.conversationId;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref.read(messagingProvider.notifier).sendMessage(
      conversationId: widget.conversationId,
      content: text,
      replyToId: _replyToId,
    );

    _controller.clear();
    setState(() {
      _replyToId = null;
      _showAttachmentMenu = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _ChatAppBarTitle(conversationId: widget.conversationId),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text('Start a conversation', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => _MessageBubble(
                    message: messages[i],
                    isOwn: messages[i].senderId == ref.watch(currentUserIdProvider),
                    onReply: (id) => setState(() => _replyToId = id),
                    onReact: (id, reaction) =>
                        ref.read(messagingProvider.notifier).toggleReaction(id, reaction),
                  ),
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
                  const Text('Replying', style: TextStyle(fontSize: 13)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _replyToId = null),
                  ),
                ],
              ),
            ),
          _ChatInputBar(
            controller: _controller,
            onSend: _sendMessage,
            showAttachmentMenu: _showAttachmentMenu,
            onToggleAttachments: () => setState(() => _showAttachmentMenu = !_showAttachmentMenu),
            onAttachmentTap: (type) {},
          ),
        ],
      ),
    );
  }
}

class _ChatAppBarTitle extends ConsumerWidget {
  final String conversationId;
  const _ChatAppBarTitle({required this.conversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convAsync = ref.watch(conversationsProvider);
    return convAsync.when(
      loading: () => const Text('Chat'),
      error: (_, __) => const Text('Chat'),
      data: (convs) {
        final conv = convs.where((c) => c.id == conversationId).firstOrNull;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(conv?.title ?? 'Chat', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                if (conv?.isVerified == true)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.verified, size: 14, color: AppColors.primary),
                  ),
              ],
            ),
            if (conv?.type == 'direct')
              Text('Online', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isOwn;
  final void Function(String messageId) onReply;
  final void Function(String messageId, String reaction) onReact;

  const _MessageBubble({
    required this.message,
    required this.isOwn,
    required this.onReply,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = DateFormat('h:mm a').format(message.createdAt);

    if (message.isSystemMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.content ?? '',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.replyToMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 3)),
              ),
              child: Text(
                message.replyToMessage!.content ?? 'Original message',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isOwn && message.senderAvatar != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(message.senderAvatar!),
                  ),
                ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isOwn ? theme.colorScheme.primary : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isOwn ? 18 : 4),
                      bottomRight: Radius.circular(isOwn ? 4 : 18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isOwn && message.senderName != null)
                        Text(
                          message.senderName!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      if (message.content != null)
                        Text(
                          message.content!,
                          style: TextStyle(
                            fontSize: 15,
                            color: isOwn ? Colors.white : Colors.black87,
                          ),
                        ),
                      if (message.hasAttachments)
                        ...message.attachments.map((a) => _AttachmentWidget(attachment: a)),
                      if (message.hasPoll && message.poll != null)
                        _PollWidget(poll: message.poll!, onVote: (i) {}),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 10,
                              color: isOwn ? Colors.white70 : Colors.grey[500],
                            ),
                          ),
                          if (message.isEdited)
                            Text(' (edited)', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (message.hasReactions)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Wrap(
                spacing: 2,
                children: message.reactions.map((r) {
                  final count = message.reactions.where((r2) => r2.reaction == r.reaction).length;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${r.reaction} $count', style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _AttachmentWidget extends StatelessWidget {
  final MessageAttachment attachment;
  const _AttachmentWidget({required this.attachment});

  @override
  Widget build(BuildContext context) {
    if (attachment.type == 'image') {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            attachment.url,
            height: 150,
            width: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 100, color: Colors.grey[200],
              child: const Icon(Icons.broken_image),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(attachment.icon, size: 20),
          const SizedBox(width: 6),
          Text(attachment.name ?? attachment.type, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _PollWidget extends StatefulWidget {
  final ChatPoll poll;
  final void Function(int optionIndex) onVote;
  const _PollWidget({required this.poll, required this.onVote});

  @override
  State<_PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<_PollWidget> {
  int? _selectedOption;
  bool _hasVoted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.poll.totalVotes();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.poll.question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 8),
          ...widget.poll.options.asMap().entries.map((entry) {
            final idx = entry.key;
            final option = entry.value;
            final votes = widget.poll.votesForOption(idx);
            final pct = widget.poll.percentageForOption(idx);

            return GestureDetector(
              onTap: _hasVoted ? null : () {
                setState(() {
                  _selectedOption = idx;
                  _hasVoted = true;
                });
                widget.onVote(idx);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedOption == idx ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedOption == idx ? theme.colorScheme.primary : Colors.grey[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    if (_hasVoted)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(option, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: Colors.grey[200],
                                color: theme.colorScheme.primary,
                                minHeight: 6,
                              ),
                            ),
                            Text('$votes vote${votes == 1 ? '' : 's'} (${(pct * 100).toInt()}%)',
                                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          ],
                        ),
                      )
                    else ...[
                      Icon(
                        widget.poll.isMultipleChoice ? Icons.check_box_outline_blank : Icons.radio_button_off,
                        size: 18, color: Colors.grey[500],
                      ),
                      const SizedBox(width: 8),
                      Text(option, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          Text('$total vote${total == 1 ? '' : 's'}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool showAttachmentMenu;
  final VoidCallback onToggleAttachments;
  final void Function(String type) onAttachmentTap;

  const _ChatInputBar({
    required this.controller,
    required this.onSend,
    required this.showAttachmentMenu,
    required this.onToggleAttachments,
    required this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAttachmentMenu)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AttachmentButton(icon: Icons.image, label: 'Gallery', onTap: () => onAttachmentTap('image')),
                  _AttachmentButton(icon: Icons.camera_alt, label: 'Camera', onTap: () => onAttachmentTap('camera')),
                  _AttachmentButton(icon: Icons.mic, label: 'Voice', onTap: () => onAttachmentTap('voice_note')),
                  _AttachmentButton(icon: Icons.description, label: 'File', onTap: () => onAttachmentTap('document')),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                  onPressed: onToggleAttachments,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: controller,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.send_rounded, color: theme.colorScheme.primary),
                  onPressed: onSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AttachmentButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[100],
            child: Icon(icon, size: 22, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
