import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/extensions/theme_extensions.dart';
import '../../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isOwn;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onReplyIconTap;
  final Function(String reaction)? onReaction;
  final VoidCallback? onTapReplyPreview;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwn,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.onReplyIconTap,
    this.onReaction,
    this.onTapReplyPreview,
  });

  // Deterministic colour from sender name for group chats
  Color _senderColor(String name) {
    final palette = [
      const Color(0xFF7B61FF),
      const Color(0xFF0084FF),
      const Color(0xFF00A389),
      const Color(0xFFEB5545),
      const Color(0xFFF5A623),
      const Color(0xFF9B59B6),
      const Color(0xFF2ECC71),
      const Color(0xFFE91E8C),
    ];
    return palette[name.codeUnits.fold(0, (a, b) => a + b) % palette.length];
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showContextMenu(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx + box.size.width,
        offset.dy + box.size.height,
      ),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          child: _MenuItem(icon: Icons.reply_rounded, label: 'Reply'),
          onTap: onReplyIconTap,
        ),
        if (message.content != null)
          PopupMenuItem(
            child: _MenuItem(icon: Icons.copy_rounded, label: 'Copy'),
            onTap: () => Clipboard.setData(ClipboardData(text: message.content!)),
          ),
        PopupMenuItem(
          child: _MenuItem(
            icon: message.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
            label: message.isPinned ? 'Unpin' : 'Pin',
          ),
          onTap: onLongPress, // caller handles pin
        ),
        if (isOwn)
          PopupMenuItem(
            child: _MenuItem(icon: Icons.delete_outline_rounded, label: 'Delete', isDestructive: true),
            onTap: () {}, // placeholder
          ),
        if (!isOwn)
          PopupMenuItem(
            child: _MenuItem(icon: Icons.flag_outlined, label: 'Report', isDestructive: true),
            onTap: () {}, // placeholder
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // System messages
    if (message.isSystemMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: context.borderCol.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.content ?? '',
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          ),
        ),
      );
    }

    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    // Bubble border radius — tail on the last bubble in a group
    final radius = isOwn
        ? BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: const Radius.circular(16),
            bottomRight: Radius.circular(isLastInGroup ? 4 : 16),
          )
        : BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isLastInGroup ? 4 : 16),
            bottomRight: const Radius.circular(16),
          );

    final bubbleColor = isOwn ? context.primary : context.cardBg;
    final textColor = isOwn ? Colors.white : context.textPrimary;
    final subtleTextColor = isOwn ? Colors.white70 : context.textSecondary;

    Widget bubble = GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      onDoubleTap: () => onReaction?.call('❤️'),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primary.withValues(alpha: 0.15)
              : bubbleColor,
          borderRadius: radius,
          border: isSelected
              ? Border.all(color: context.primary, width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Reply preview
            if (message.replyToMessage != null)
              _ReplyPreview(
                replyTo: message.replyToMessage!,
                isOwn: isOwn,
                onTap: onTapReplyPreview,
              ),
            // 2. Sender name (group/other only)
            if (!isOwn && isFirstInGroup && message.senderName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  message.senderName!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _senderColor(message.senderName!),
                  ),
                ),
              ),
            // 3. Attachments
            if (message.hasAttachments)
              _AttachmentsSection(
                attachments: message.attachments,
                isOwn: isOwn,
                textColor: textColor,
              ),
            // 4. Text content
            if (message.content != null && message.content!.isNotEmpty)
              Padding(
                padding: message.hasAttachments ? const EdgeInsets.only(top: 4) : EdgeInsets.zero,
                child: Text(
                  message.content!,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),
            // 5. Footer
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (message.isEdited)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      'edited',
                      style: TextStyle(fontSize: 10, color: subtleTextColor),
                    ),
                  ),
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(fontSize: 10, color: subtleTextColor),
                ),
                if (isOwn) ...[
                  const SizedBox(width: 3),
                  _ReadReceipt(message: message),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    // Reactions bar below bubble
    Widget content = Column(
      crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        bubble,
        if (message.hasReactions)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: _ReactionsBar(
              reactions: message.reactions,
              onTap: onReaction,
            ),
          ),
      ],
    );

    // Avatar + name layout for others
    if (!isOwn) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar slot — always 32 wide for alignment
          isFirstInGroup
              ? Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: context.borderCol,
                    backgroundImage: message.senderAvatar != null
                        ? NetworkImage(message.senderAvatar!)
                        : null,
                    child: message.senderAvatar == null
                        ? Text(
                            (message.senderName ?? '?')[0].toUpperCase(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          )
                        : null,
                  ),
                )
              : const SizedBox(width: 38), // 32 + 6 gap
          Flexible(child: content),
        ],
      );
    }

    final verticalPad = isLastInGroup ? 4.0 : 2.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: verticalPad),
      child: Align(
        alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
        child: content,
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _ReplyPreview extends StatelessWidget {
  final MessageModel replyTo;
  final bool isOwn;
  final VoidCallback? onTap;

  const _ReplyPreview({required this.replyTo, required this.isOwn, this.onTap});

  @override
  Widget build(BuildContext context) {
    final accentColor = isOwn ? Colors.white60 : context.primary;
    final bgColor = isOwn
        ? Colors.white.withValues(alpha: 0.15)
        : context.primary.withValues(alpha: 0.07);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: accentColor, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              replyTo.senderName ?? 'Message',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              replyTo.content ?? (replyTo.hasAttachments ? '📎 Attachment' : ''),
              style: TextStyle(
                fontSize: 12,
                color: isOwn ? Colors.white70 : context.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadReceipt extends StatelessWidget {
  final MessageModel message;
  const _ReadReceipt({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isSending) {
      return const Icon(Icons.hourglass_empty_rounded, size: 12, color: Colors.white60);
    }
    if (message.hasFailed) {
      return Icon(Icons.error_outline_rounded, size: 12, color: context.error);
    }
    return const Icon(Icons.done_rounded, size: 12, color: Colors.white70);
  }
}

class _ReactionsBar extends StatelessWidget {
  final List<MessageReaction> reactions;
  final Function(String)? onTap;

  const _ReactionsBar({required this.reactions, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Deduplicate reactions, keeping emoji -> count
    final Map<String, int> grouped = {};
    for (final r in reactions) {
      grouped[r.reaction] = (grouped[r.reaction] ?? 0) + 1;
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: grouped.entries.map((e) {
        return GestureDetector(
          onTap: () => onTap?.call(e.key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: context.cardBg,
              border: Border.all(color: context.borderCol),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${e.key} ${e.value}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AttachmentsSection extends StatelessWidget {
  final List<MessageAttachment> attachments;
  final bool isOwn;
  final Color textColor;

  const _AttachmentsSection({
    required this.attachments,
    required this.isOwn,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final images = attachments.where((a) => a.type == 'image').toList();
    final others = attachments.where((a) => a.type != 'image').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty) _ImageGrid(images: images),
        ...others.map((a) => _FileChip(attachment: a, textColor: textColor)),
      ],
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final List<MessageAttachment> images;
  const _ImageGrid({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.length == 1) {
      return _SingleImage(attachment: images.first);
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 3,
      crossAxisSpacing: 3,
      children: images.take(4).map((a) => _SingleImage(attachment: a)).toList(),
    );
  }
}

class _SingleImage extends StatelessWidget {
  final MessageAttachment attachment;
  const _SingleImage({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _FullScreenImage(url: attachment.url),
        ));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: attachment.url,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (_, __, ___) => Container(
            height: 100,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image_outlined),
          ),
        ),
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String url;
  const _FullScreenImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _FileChip extends StatelessWidget {
  final MessageAttachment attachment;
  final Color textColor;

  const _FileChip({required this.attachment, required this.textColor});

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(attachment.icon, size: 20, color: textColor.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name ?? attachment.type,
                  style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (attachment.size != null)
                  Text(
                    _formatSize(attachment.size),
                    style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.6)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;

  const _MenuItem({required this.icon, required this.label, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? context.error : context.textPrimary;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color, fontSize: 14)),
      ],
    );
  }
}
