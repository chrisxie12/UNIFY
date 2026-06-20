import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/announcement_social_provider.dart';
import '../../domain/entities/announcement_comment.dart';
import '../../../../core/extensions/theme_extensions.dart';

/// Instagram-style bottom sheet for viewing and adding comments on an announcement.
class CommentSheet extends ConsumerStatefulWidget {
  const CommentSheet({super.key, required this.announcementId});

  final String announcementId;

  static Future<void> show(BuildContext context, String announcementId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentSheet(announcementId: announcementId),
    );
  }

  @override
  ConsumerState<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<CommentSheet> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final ok = await ref
        .read(announcementCommentsProvider(widget.announcementId).notifier)
        .add(text);
    if (ok) _ctrl.clear();
    if (mounted) setState(() => _sending = false);
  }

  static String _timeLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(announcementCommentsProvider(widget.announcementId));
    final myUid = Supabase.instance.client.auth.currentUser?.id;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // ── Handle ───────────────────────────────────────────────────
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderCol,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Comments',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary),
              ),
            ),
            Divider(height: 1, color: context.borderCol),

            // ── Comment list ─────────────────────────────────────────────
            Expanded(
              child: commentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => Center(
                  child: Text('Failed to load comments', style: TextStyle(color: context.textSecondary)),
                ),
                data: (comments) => comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 40, color: context.textDisabled),
                            const SizedBox(height: 8),
                            Text(
                              'No comments yet',
                              style: TextStyle(fontSize: 14, color: context.textSecondary),
                            ),
                            Text(
                              'Be the first to comment',
                              style: TextStyle(fontSize: 12, color: context.textDisabled),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: comments.length,
                        itemBuilder: (_, i) => _CommentTile(
                          comment: comments[i],
                          isOwn: comments[i].authorId == myUid,
                          timeLabel: _timeLabel(comments[i].createdAt),
                          onDelete: () => ref
                              .read(announcementCommentsProvider(widget.announcementId).notifier)
                              .remove(comments[i].id),
                        ),
                      ),
              ),
            ),

            // ── Input bar ────────────────────────────────────────────────
            Divider(height: 1, color: context.borderCol),
            Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomInset),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Add a comment…',
                        hintStyle: TextStyle(color: context.textSecondary, fontSize: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: context.borderCol),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: context.borderCol),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: context.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        isDense: true,
                      ),
                      style: TextStyle(fontSize: 13, color: context.textPrimary),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sending
                      ? SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(strokeWidth: 2, color: context.primary),
                        )
                      : IconButton(
                          icon: Icon(Icons.send_rounded, color: context.primary, size: 22),
                          onPressed: _send,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.isOwn,
    required this.timeLabel,
    required this.onDelete,
  });

  final AnnouncementComment comment;
  final bool isOwn;
  final String timeLabel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.inputFill,
              border: Border.all(color: context.borderCol, width: 0.5),
            ),
            child: ClipOval(
              child: comment.authorAvatar != null
                  ? CachedNetworkImage(
                      imageUrl: comment.authorAvatar!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _Initial(comment.authorName),
                    )
                  : _Initial(comment.authorName),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${comment.authorName ?? 'User'} ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: comment.body,
                        style: TextStyle(fontSize: 13, color: context.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeLabel,
                  style: TextStyle(fontSize: 11, color: context.textSecondary),
                ),
              ],
            ),
          ),
          if (isOwn)
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Icon(Icons.delete_outline_rounded, size: 16, color: context.textDisabled),
              ),
            ),
        ],
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String? name;
  const _Initial(this.name);

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          name?.isNotEmpty == true ? name![0].toUpperCase() : 'U',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.textPrimary),
        ),
      );
}
