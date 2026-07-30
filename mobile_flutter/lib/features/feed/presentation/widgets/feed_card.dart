import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/announcement.dart';
import '../providers/announcement_social_provider.dart';
import '../screens/feed_screen.dart';
import 'comment_sheet.dart';
import 'post_options_sheet.dart';

class FeedCard extends ConsumerStatefulWidget {
  final Announcement post;

  const FeedCard({super.key, required this.post});

  @override
  ConsumerState<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends ConsumerState<FeedCard>
    with TickerProviderStateMixin {
  late AnimationController _heartAnimCtrl;
  late Animation<double> _heartScale;
  late Animation<double> _heartFade;
  bool _showFullBody = false;

  @override
  void initState() {
    super.initState();
    _heartAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _heartScale = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _heartAnimCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );
    _heartFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _heartAnimCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _heartAnimCtrl.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    final post = widget.post;
    final likeState = ref.read(
      announcementLikeProvider((id: post.id, initialCount: post.likesCount)),
    );
    if (!likeState.isLiked) {
      HapticFeedback.heavyImpact();
      ref.read(announcementLikeProvider((
        id: post.id,
        initialCount: post.likesCount,
      )).notifier).toggle();
    }
    _heartAnimCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final cs = Theme.of(context).colorScheme;
    final likeState = ref.watch(
      announcementLikeProvider((id: post.id, initialCount: post.likesCount)),
    );
    final saveState = ref.watch(announcementSaveProvider(post.id));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(post: post, cs: cs),
          if (post.imageUrl != null)
            _PostMedia(
              post: post,
              cs: cs,
              onDoubleTap: _onDoubleTap,
              heartAnimCtrl: _heartAnimCtrl,
              heartScale: _heartScale,
              heartFade: _heartFade,
            ),
          if (post.imageUrl == null && post.body.isNotEmpty)
            _PostBody(
              body: post.body,
              cs: cs,
              showFull: _showFullBody,
              onToggle: () => setState(() => _showFullBody = !_showFullBody),
            ),
          _PostActions(
            cs: cs,
            likeState: likeState,
            saveState: saveState,
            post: post,
            onLike: () {
              HapticFeedback.lightImpact();
              ref.read(announcementLikeProvider((
                id: post.id,
                initialCount: post.likesCount,
              )).notifier).toggle();
            },
            onComment: () => CommentSheet.show(context, post.id),
            onShare: () async {
              await Share.share('${post.title}\n\n${post.body}', subject: post.title);
              ref.read(announcementSocialRepoProvider).recordShare(post.id);
            },
            onSave: () => ref.read(announcementSaveProvider(post.id).notifier).toggle(),
          ),
          if (likeState.count > 0 || post.commentsCount > 0)
            _PostMeta(
              likeCount: likeState.count,
              commentCount: post.commentsCount,
              cs: cs,
              onCommentTap: () => CommentSheet.show(context, post.id),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────

class _PostHeader extends StatelessWidget {
  final Announcement post;
  final ColorScheme cs;

  const _PostHeader({required this.post, required this.cs});

  @override
  Widget build(BuildContext context) {
    final avatarColors = [
      const Color(0xFFE53935), const Color(0xFFD81B60), const Color(0xFF8E24AA),
      const Color(0xFF5E35B1), const Color(0xFF3949AB), const Color(0xFF1E88E5),
      const Color(0xFF039BE5), const Color(0xFF00ACC1), const Color(0xFF00897B),
      const Color(0xFF43A047), const Color(0xFF7CB342), const Color(0xFFC0CA33),
      const Color(0xFFFDD835), const Color(0xFFFFB300), const Color(0xFFFB8C00),
      const Color(0xFFF4511E),
    ];
    final name = post.authorName ?? 'U';
    final hash = name.codeUnits.fold(0, (a, b) => a + b);
    final avatarColor = avatarColors[hash % avatarColors.length];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/profile/${post.authorId}'),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: avatarColor,
              backgroundImage: post.authorAvatar != null
                  ? CachedNetworkImageProvider(post.authorAvatar!)
                  : null,
              child: post.authorAvatar == null
                  ? Text(
                      name[0].toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/profile/${post.authorId}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      if (post.authorIsVerifiedLeader) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded, size: 14, color: cs.primary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _timeAgo(post.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(PhosphorIconsBold.dotsThreeOutline, size: 18, color: cs.onSurfaceVariant),
            onPressed: () => PostOptionsSheet.show(context, post),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ],
      ),
    );
  }
}

class _PostMedia extends StatelessWidget {
  final Announcement post;
  final ColorScheme cs;
  final VoidCallback onDoubleTap;
  final AnimationController heartAnimCtrl;
  final Animation<double> heartScale;
  final Animation<double> heartFade;

  const _PostMedia({
    required this.post,
    required this.cs,
    required this.onDoubleTap,
    required this.heartAnimCtrl,
    required this.heartScale,
    required this.heartFade,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: post.imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: cs.surfaceContainerHighest,
                  child: Icon(PhosphorIconsBold.image, size: 40, color: cs.onSurfaceVariant),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: heartAnimCtrl,
            builder: (context, child) {
              if (heartAnimCtrl.isAnimating == false && heartAnimCtrl.value == 0) {
                return const SizedBox.shrink();
              }
              return Opacity(
                opacity: heartFade.value,
                child: Transform.scale(
                  scale: heartScale.value,
                  child: child,
                ),
              );
            },
            child: const Icon(PhosphorIconsFill.heart, size: 80, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _PostBody extends StatelessWidget {
  final String body;
  final ColorScheme cs;
  final bool showFull;
  final VoidCallback onToggle;

  const _PostBody({
    required this.body,
    required this.cs,
    required this.showFull,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: cs.onSurface,
              height: 1.5,
            ),
            maxLines: showFull ? null : 3,
            overflow: showFull ? null : TextOverflow.ellipsis,
          ),
          if (body.length > 120)
            GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  showFull ? 'Show less' : 'Read more',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cs.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostActions extends StatelessWidget {
  final ColorScheme cs;
  final LikeState likeState;
  final SaveState saveState;
  final Announcement post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const _PostActions({
    required this.cs,
    required this.likeState,
    required this.saveState,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          _ActionButton(
            icon: likeState.isLiked ? PhosphorIconsFill.heart : PhosphorIconsBold.heart,
            color: likeState.isLiked ? const Color(0xFFE1306C) : cs.onSurfaceVariant,
            count: likeState.count,
            onTap: onLike,
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: PhosphorIconsBold.chatCircle,
            color: cs.onSurfaceVariant,
            count: post.commentsCount,
            onTap: onComment,
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: PhosphorIconsBold.paperPlaneRight,
            color: cs.onSurfaceVariant,
            onTap: onShare,
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSave,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                saveState.isSaved ? PhosphorIconsFill.bookmark : PhosphorIconsBold.bookmark,
                size: 22,
                color: saveState.isSaved ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final int? count;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.count,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.9);
  void _onTapUp(_) {
    setState(() => _scale = 1.0);
    HapticFeedback.lightImpact();
    widget.onTap();
  }
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 22, color: widget.color),
              if (widget.count != null && widget.count! > 0) ...[
                const SizedBox(width: 4),
                Text(
                  _fmtNum(widget.count!),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: widget.color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Post Meta (likes + comments) ──────────────────────────────────────────

class _PostMeta extends StatelessWidget {
  final int likeCount;
  final int commentCount;
  final ColorScheme cs;
  final VoidCallback onCommentTap;

  const _PostMeta({
    required this.likeCount,
    required this.commentCount,
    required this.cs,
    required this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (likeCount > 0)
            Text(
              '$likeCount ${likeCount == 1 ? 'like' : 'likes'}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          if (commentCount > 0)
            GestureDetector(
              onTap: onCommentTap,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'View all $commentCount ${commentCount == 1 ? 'comment' : 'comments'}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('MMM d').format(dt);
}

String _fmtNum(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  return '$n';
}