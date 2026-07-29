import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/feed_provider.dart';
import '../providers/announcement_social_provider.dart';
import '../../domain/entities/announcement.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/post_options_sheet.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../snapshots/data/models/snapshot_models.dart';
import '../../../snapshots/presentation/providers/snapshot_provider.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedProvider);
    final storyGroupsAsync = ref.watch(storyGroupsProvider);
    final cs = Theme.of(context).colorScheme;
    final user = Supabase.instance.client.auth.currentUser;
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;
    final fullName = user?.userMetadata?['full_name'] as String? ?? '';

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        color: cs.primary,
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              backgroundColor: cs.surface.withValues(alpha: 0.85),
              surfaceTintColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: cs.surfaceContainerHighest,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? Text(
                            fullName.isNotEmpty
                                ? fullName[0].toUpperCase()
                                : 'U',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurfaceVariant,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              title: Text(
                'UNIFY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    icon: Icon(PhosphorIconsBold.heart, size: 22, color: cs.onSurface),
                    onPressed: () {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    icon: Icon(
                      PhosphorIconsBold.chatCircle,
                      size: 22,
                      color: cs.onSurface,
                    ),
                    onPressed: () => context.push('/messaging'),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _StoriesRow(
                    storyGroupsAsync: storyGroupsAsync,
                    cs: cs,
                    avatarUrl: avatarUrl,
                    fullName: fullName,
                  ),
                  Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
                ],
              ),
            ),
            feedAsync.when(
              loading: () => const SliverFillRemaining(
                hasScrollBody: true,
                child: AppLoadingWidget.card(),
              ),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: true,
                child: AppErrorWidget(
                  e,
                  onRetry: () => ref.invalidate(feedProvider),
                ),
              ),
              data: (feedState) {
                if (feedState.items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: true,
                    child: AppEmptyWidget(
                      icon: PhosphorIconsBold.image,
                      title: 'No posts yet',
                      subtitle: 'Be the first to share something!',
                      actionLabel: 'Create Post',
                      onAction: () => context.push('/announcement/create'),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = feedState.items[index];
                      return _PostCard(
                        post: post,
                        cs: cs,
                      );
                    },
                    childCount: feedState.items.length,
                    addAutomaticKeepAlives: true,
                  ),
                );
              },
            ),
            if (feedAsync.valueOrNull?.isLoadingMore == true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Stories Row ────────────────────────────────────────────────────────────

class _StoriesRow extends StatelessWidget {
  final AsyncValue<List<SnapshotGroup>> storyGroupsAsync;
  final ColorScheme cs;
  final String? avatarUrl;
  final String fullName;

  const _StoriesRow({
    required this.storyGroupsAsync,
    required this.cs,
    this.avatarUrl,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    return storyGroupsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (groups) {
        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: groups.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cs.surfaceContainerHighest,
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: cs.surfaceContainerHighest,
                                backgroundImage: avatarUrl != null
                                    ? NetworkImage(avatarUrl!)
                                    : null,
                                child: avatarUrl == null
                                    ? Icon(
                                        PhosphorIconsBold.user,
                                        size: 28,
                                        color: cs.onSurfaceVariant,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cs.primary,
                                  border: Border.all(
                                    color: cs.surface,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  PhosphorIconsBold.plus,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your Story',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              final group = groups[index - 1];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: group.hasUnseen
                              ? LinearGradient(
                                  colors: [
                                    cs.primary,
                                    cs.tertiary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          border: !group.hasUnseen
                              ? Border.all(
                                  color: cs.outlineVariant,
                                  width: 1.5,
                                )
                              : null,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.surface,
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: cs.surfaceContainerHighest,
                            backgroundImage: group.authorAvatar != null
                                ? NetworkImage(group.authorAvatar!)
                                : null,
                            child: group.authorAvatar == null
                                ? Text(
                                    group.initials,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 68,
                        child: Text(
                          group.authorName ?? 'User',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Post Card ──────────────────────────────────────────────────────────────

class _PostCard extends ConsumerStatefulWidget {
  final Announcement post;
  final ColorScheme cs;

  const _PostCard({
    required this.post,
    required this.cs,
  });

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _heartAnimCtrl;
  late Animation<double> _heartScale;
  late Animation<double> _heartFade;

  @override
  bool get wantKeepAlive => true;

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
      ref
          .read(announcementLikeProvider((
            id: post.id,
            initialCount: post.likesCount,
          )).notifier)
          .toggle();
    }
    _heartAnimCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final post = widget.post;
    final cs = widget.cs;
    final likeState = ref.watch(
      announcementLikeProvider((id: post.id, initialCount: post.likesCount)),
    );
    final saveState = ref.watch(announcementSaveProvider(post.id));

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile/${post.authorId}'),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surfaceContainerHighest,
                    ),
                    child: ClipOval(
                      child: post.authorAvatar != null
                          ? CachedNetworkImage(
                              imageUrl: post.authorAvatar!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Center(
                                child: Text(
                                  (post.authorName ?? 'U')[0].toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                (post.authorName ?? 'U')[0].toUpperCase(),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/profile/${post.authorId}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.authorName ?? 'Campus Admin',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (post.authorIsVerifiedLeader) ...[
                              const SizedBox(width: 3),
                              Icon(
                                Icons.verified_rounded,
                                size: 13,
                                color: cs.primary,
                              ),
                            ],
                            const SizedBox(width: 4),
                            Text(
                              _timeAgo(post.createdAt),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    PhosphorIconsBold.dotsThreeOutline,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                  onPressed: () => PostOptionsSheet.show(context, post),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // ── Media with double-tap heart ─────────────────────────────────
          if (post.imageUrl != null)
            GestureDetector(
              onDoubleTap: _onDoubleTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: cs.surfaceContainerHighest,
                        child: Icon(
                          PhosphorIconsBold.image,
                          size: 40,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _heartAnimCtrl,
                    builder: (context, child) {
                      if (_heartAnimCtrl.isAnimating == false &&
                          _heartAnimCtrl.value == 0) {
                        return const SizedBox.shrink();
                      }
                      return Opacity(
                        opacity: _heartFade.value,
                        child: Transform.scale(
                          scale: _heartScale.value,
                          child: child,
                        ),
                      );
                    },
                    child: const Icon(
                      PhosphorIconsFill.heart,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          // ── Body text (no image fallback) ───────────────────────────────
          if (post.imageUrl == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Text(
                post.body.isNotEmpty ? post.body : post.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: cs.onSurface,
                  height: 1.4,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // ── Actions ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                _ActionButton(
                  icon: likeState.isLiked
                      ? PhosphorIconsFill.heart
                      : PhosphorIconsBold.heart,
                  color: likeState.isLiked
                      ? const Color(0xFFE1306C)
                      : cs.onSurfaceVariant,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(announcementLikeProvider((
                          id: post.id,
                          initialCount: post.likesCount,
                        )).notifier)
                        .toggle();
                  },
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: PhosphorIconsBold.chatCircle,
                  color: cs.onSurfaceVariant,
                  onTap: () => CommentSheet.show(context, post.id),
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: PhosphorIconsBold.paperPlaneRight,
                  color: cs.onSurfaceVariant,
                  onTap: () async {
                    await Share.share(
                      '${post.title}\n\n${post.body}',
                      subject: post.title,
                    );
                    ref
                        .read(announcementSocialRepoProvider)
                        .recordShare(post.id);
                  },
                ),
                const Spacer(),
                _ActionButton(
                  icon: saveState.isSaved
                      ? PhosphorIconsFill.bookmark
                      : PhosphorIconsBold.bookmark,
                  color: saveState.isSaved
                      ? cs.primary
                      : cs.onSurfaceVariant,
                  onTap: () => ref
                      .read(announcementSaveProvider(post.id).notifier)
                      .toggle(),
                ),
              ],
            ),
          ),
          // ── Likes count ─────────────────────────────────────────────────
          if (likeState.count > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Text(
                '${_fmtNum(likeState.count)} likes',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
          // ── Caption ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${post.authorName ?? 'User'} ',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: post.body.isNotEmpty ? post.body : post.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // ── Comments link ───────────────────────────────────────────────
          if (post.commentsCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: GestureDetector(
                onTap: () => CommentSheet.show(context, post.id),
                child: Text(
                  'View all ${_fmtNum(post.commentsCount)} ${post.commentsCount == 1 ? 'comment' : 'comments'}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Divider(height: 1, indent: 12, endIndent: 12, color: cs.outlineVariant.withValues(alpha: 0.2)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Action Button ──────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

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
