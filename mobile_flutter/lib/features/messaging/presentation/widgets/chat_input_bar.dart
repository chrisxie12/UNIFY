import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/extensions/theme_extensions.dart';
import '../providers/messaging_provider.dart';

class ChatInputBar extends ConsumerStatefulWidget {
  final String conversationId;
  final String? channelId;
  final VoidCallback? onAttachmentTap;

  const ChatInputBar({
    super.key,
    required this.conversationId,
    this.channelId,
    this.onAttachmentTap,
  });

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final replyTo = ref.read(replyToMessageProvider(widget.conversationId));

    await ref.read(messagingProvider.notifier).sendMessage(
          conversationId: widget.conversationId,
          channelId: widget.channelId,
          content: text,
          replyToId: replyTo?.id,
        );

    _controller.clear();
    // Clear reply-to after sending
    ref.read(replyToMessageProvider(widget.conversationId).notifier).state = null;
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AttachmentSheet(
        onTap: (_) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coming soon'), duration: Duration(seconds: 2)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          border: Border(
            top: BorderSide(color: context.borderCol, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            IconButton(
              onPressed: _showAttachmentSheet,
              icon: Icon(
                Icons.attach_file_rounded,
                color: context.textSecondary,
              ),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
            // Text field
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: 15,
                  color: context.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(
                    color: context.textSecondary,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Send / mic button
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: _hasText
                  ? IconButton(
                      key: const ValueKey('send'),
                      onPressed: _send,
                      icon: Icon(Icons.send_rounded, color: context.primary),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    )
                  : IconButton(
                      key: const ValueKey('mic'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Voice notes coming soon'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icon(Icons.mic_rounded, color: context.textSecondary),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentSheet extends StatelessWidget {
  final void Function(String type) onTap;

  const _AttachmentSheet({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (_AttachmentOption(icon: Icons.camera_alt_rounded, label: 'Camera', type: 'camera')),
      (_AttachmentOption(icon: Icons.photo_library_rounded, label: 'Gallery', type: 'image')),
      (_AttachmentOption(icon: Icons.description_rounded, label: 'Document', type: 'document')),
      (_AttachmentOption(icon: Icons.mic_rounded, label: 'Voice Note', type: 'voice_note')),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((o) => _AttachmentTile(option: o, onTap: onTap)).toList(),
          ),
        ],
      ),
    );
  }
}

class _AttachmentOption {
  final IconData icon;
  final String label;
  final String type;
  const _AttachmentOption({required this.icon, required this.label, required this.type});
}

class _AttachmentTile extends StatelessWidget {
  final _AttachmentOption option;
  final void Function(String) onTap;

  const _AttachmentTile({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(option.type),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(option.icon, color: context.primary, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            option.label,
            style: TextStyle(fontSize: 12, color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}
