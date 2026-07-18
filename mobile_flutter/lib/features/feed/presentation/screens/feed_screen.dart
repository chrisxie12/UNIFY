import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/feed_provider.dart';
import '../providers/announcement_social_provider.dart';
import '../../domain/entities/announcement.dart';
import '../widgets/comment_sheet.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../system/presentation/widgets/system_announcement_banner.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
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
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ?? '';
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;
    final storyGroupsAsync = ref.watch(storyGroupsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(feedProvider.notifier).refresh();
          await ref.read(storyGroupsProvider.notifier).refresh();
        },
        color: theme.colorScheme.primary,
        strokeWidth: 2.5,
        displacement: 80,
        edgeOffset: 0,
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            // ── Instagram-style top bar ────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_box_outlined,
                          size: 28, color: Colors.black),
                      onPressed: () => context.push('/stories/create'),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Spacer(),
                    const Text(
                      'UNIFY',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _NotifBadgeIcon(),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.send_outlined,
                              size: 28, color: Colors.black),
                          onPressed: () => context.go('/app/messaging'),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SystemAnnouncementBanner()),

            // ── Stories row ────────────────────────────────────────
            SliverToBoxAdapter(
              child: _StoriesRow(
                avatarUrl: avatarUrl,
                firstName: fullName.split(' ').first,
                groups: storyGroupsAsync.valueOrNull ?? [],
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                height: 0.5,
                color: const Color(0xFFE5E7EB),
              ),
            ),

            // ── Feed content ───────────────────────────────────────
            feedAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ShimmerCard(),
                  childCount: 2,
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: AppErrorWidget(
                  e,
                  customMessage: 'Couldn\'t load feed',
                  onRetry: () => ref.invalidate(feedProvider),
                ),
              ),
              data: (feedState) {
                if (feedState.items.isEmpty) {
                  return SliverFillRemaining(
                    child: AppEmptyWidget(
                      icon: Icons.campaign_outlined,
                      title: 'Nothing here yet',
                      subtitle: 'Check back soon for campus updates.',
                    ),
                  );
                }

                return SliverMainAxisGroup(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = feedState.items[index];
                          return _buildPostCard(post: post);
                        },
                        childCount: feedState.items.length,
                      ),
                    ),
                    if (feedState.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          ),
                        ),
                      )
                    else if (!feedState.hasMore)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 40, 24, 96),
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      context.primary.withValues(alpha: 0.15),
                                      context.primary.withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check_circle_outline_rounded,
                                    size: 28, color: context.primary),
                              ),
                              const SizedBox(height: 14),
                              Text("You're all caught up",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: context.textPrimary)),
                              const SizedBox(height: 4),
                              Text('Pull down to refresh',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondary)),
                            ],
                          ),
                        ),
                      )
                    else
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Post card ───────────────────────────────────────────────────────────
  Widget _buildPostCard({required Announcement post}) {
    final likeState = ref.watch(
      announcementLikeProvider(
          (id: post.id, initialCount: post.likesCount)),
    );
    final hasImage = post.imageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              _StoryAvatar(
                size: 36,
                avatarUrl: post.authorAvatar,
                name: post.authorName ?? 'Campus Admin',
                hasStory: post.authorIsVerifiedLeader,
                colors: const [
                  Color(0xFFF97316),
                  Color(0xFFEC4899),
                  Color(0xFF2563EB),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.authorName ?? 'Campus Admin',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (post.authorIsVerifiedLeader) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified,
                              size: 13, color: Colors.blue[400]),
                        ],
                      ],
                    ),
                    if (post.authorLeadershipRole != null)
                      Text(
                        post.authorLeadershipRole!,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz,
                    size: 20, color: Colors.black),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),

        // Image
        if (hasImage)
          SizedBox(
            height: 375,
            child: CachedNetworkImage(
              imageUrl: post.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  ref
                      .read(announcementLikeProvider(
                              (id: post.id, initialCount: post.likesCount))
                          .notifier)
                      .toggle();
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    likeState.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    key: ValueKey(likeState.isLiked),
                    size: 28,
                    color: likeState.isLiked
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => CommentSheet.show(context, post.id),
                child: const Icon(Icons.chat_bubble_outline,
                    size: 26, color: Colors.black),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () async {
                  await Share.share('${post.title}\n\n${post.body}',
                      subject: post.title);
                  ref
                      .read(announcementSocialRepoProvider)
                      .recordShare(post.id);
                },
                child: const Icon(Icons.send_outlined,
                    size: 26, color: Colors.black),
              ),
              const Spacer(),
              const Icon(Icons.bookmark_border,
                  size: 26, color: Colors.black),
            ],
          ),
        ),

        // Likes count
        if (likeState.count > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${_fmtNum(likeState.count)} likes',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),

        const SizedBox(height: 6),

        // Caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '${post.authorName ?? 'Campus Admin'} ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: post.body),
              ],
            ),
          ),
        ),

        // Comments count
        if (post.commentsCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () => CommentSheet.show(context, post.id),
              child: Text(
                'View all ${_fmtNum(post.commentsCount)} ${post.commentsCount == 1 ? 'comment' : 'comments'}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ),
          ),

        const SizedBox(height: 4),

        // Timestamp
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            _timeAgo(post.createdAt),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
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
}

// ── Notification badge icon ────────────────────────────────────────────────

class _NotifBadgeIcon extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider).valueOrNull ?? 0;
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.favorite_border,
              size: 28, color: Colors.black),
          onPressed: () => context.push('/notifications'),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        if (unread > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Stories row ────────────────────────────────────────────────────────────

class _StoriesRow extends ConsumerWidget {
  final String? avatarUrl;
  final String firstName;
  final List<dynamic> groups;

  const _StoriesRow({
    this.avatarUrl,
    required this.firstName,
    required this.groups,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    final myGroup =
        groups.where((g) => g.authorId == uid).firstOrNull;
    final otherGroups =
        groups.where((g) => g.authorId != uid).toList();

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 1 + otherGroups.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildStoryItem(
              name: firstName.isNotEmpty ? firstName : 'You',
              initial: firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
              color: const Color(0xFF2563EB),
              isUser: true,
              viewed: false,
              onTap: () {
                if (myGroup != null) {
                  final allGroups = [myGroup, ...otherGroups];
                  context.push('/stories/view', extra: {
                    'groups': allGroups,
                    'index': 0,
                  });
                } else {
                  context.push('/stories/create');
                }
              },
            );
          }
          final g = otherGroups[index - 1];
          return _buildStoryItem(
            name: g.authorName ?? 'User',
            initial: g.initials ?? 'U',
            color: context.primary,
            viewed: !g.hasUnseen,
            onTap: () {
              final allGroups = myGroup != null
                  ? [myGroup, ...otherGroups]
                  : otherGroups;
              final viewIndex = myGroup != null ? index : index + 1;
              context.push('/stories/view', extra: {
                'groups': allGroups,
                'index': viewIndex,
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildStoryItem({
    required String name,
    required String initial,
    required Color color,
    bool isUser = false,
    bool viewed = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: viewed
                        ? null
                        : const LinearGradient(
                            colors: [
                              Color(0xFFF97316),
                              Color(0xFFEC4899),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    border: viewed
                        ? Border.all(
                            color: const Color(0xFFE5E7EB), width: 2.5)
                        : null,
                  ),
                ),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (isUser)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2.5),
                        ),
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isUser ? 'Your Story' : name.split(' ').first,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
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
}

class _StoryAvatar extends StatelessWidget {
  final double size;
  final String? avatarUrl;
  final String name;
  final bool hasStory;
  final List<Color> colors;

  const _StoryAvatar({
    required this.size,
    this.avatarUrl,
    required this.name,
    this.hasStory = false,
    this.colors = const [Color(0xFFF97316), Color(0xFFEC4899)],
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      width: size + 6,
      height: size + 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasStory
            ? LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2563EB),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ClipOval(
          child: avatarUrl != null
              ? CachedNetworkImage(
                  imageUrl: avatarUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Center(
                    child: Text(initial,
                        style: TextStyle(
                            fontSize: size * 0.4,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                )
              : Center(
                  child: Text(initial,
                      style: TextStyle(
                          fontSize: size * 0.4,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
        ),
      ),
    );
  }
}

// ── Shimmer loading card ───────────────────────────────────────────────────

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shimmer = context.isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.withValues(alpha: 0.08);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: shimmer,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: shimmer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: shimmer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 375, color: shimmer),
        ],
      ),
    );
  }
}
