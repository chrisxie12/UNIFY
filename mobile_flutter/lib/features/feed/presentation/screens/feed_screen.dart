import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/feed_provider.dart';
import '../providers/announcement_social_provider.dart';
import '../../domain/entities/announcement.dart';
import '../widgets/comment_sheet.dart';
import '../../../../core/design_system/tokens.dart';
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
  final Map<String, int> _postImageIndices = {};

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

    return Scaffold(
      backgroundColor: context.surfaceBg,
      body: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(feedProvider.notifier).refresh();
          await ref.read(storyGroupsProvider.notifier).refresh();
        },
        color: context.primary,
        strokeWidth: 2.5,
        displacement: 80,
        edgeOffset: 0,
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(USpacing.base, USpacing.md, USpacing.base, USpacing.xs),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/stories/create'),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: context.borderSubtle, width: 1.5),
                        ),
                        child: Icon(Iconsax.gallery_add, size: 18, color: context.textSecondary),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.crown_1_copy, size: 22, color: context.primary),
                        const SizedBox(width: 6),
                        Text(
                          'UNIFY',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: context.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _NotifBadgeIcon(),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => context.go('/app/messaging'),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.surfaceFill,
                            ),
                            child: Icon(Iconsax.message_2, size: 18, color: context.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(height: 0.5, color: context.borderSubtle.withValues(alpha: 0.5)),
            ),

            const SliverToBoxAdapter(child: SystemAnnouncementBanner()),

            SliverToBoxAdapter(
              child: _StoriesRow(
                avatarUrl: avatarUrl,
                firstName: fullName.split(' ').first,
                groups: storyGroupsAsync.valueOrNull ?? [],
              ),
            ),

            feedAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ShimmerCard(),
                  childCount: 3,
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: AppErrorWidget(
                  e,
                  customMessage: "Couldn't load feed",
                  onRetry: () => ref.invalidate(feedProvider),
                ),
              ),
              data: (feedState) {
                if (feedState.items.isEmpty) {
                  return SliverFillRemaining(
                    child: Padding(
                      padding: EdgeInsets.only(top: USpacing.x4),
                      child: AppEmptyWidget(
                        icon: Iconsax.element_3_copy,
                        title: 'Nothing here yet',
                        subtitle: 'Check back soon for campus updates.',
                      ),
                    ),
                  );
                }

                return SliverMainAxisGroup(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = feedState.items[index];
                          final images = post.imageUrl != null
                              ? [post.imageUrl!]
                              : <String>[];
                          final hasMore = images.length > 1;
                          final currentIdx = _postImageIndices[post.id] ?? 0;

                          return _PostCard(
                            post: post,
                            images: images,
                            hasMore: hasMore,
                            currentImageIndex: currentIdx,
                            onPageChanged: hasMore
                                ? (i) => setState(() => _postImageIndices[post.id] = i)
                                : null,
                          );
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
                              width: 24, height: 24,
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
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: context.primary.withValues(alpha: 0.1),
                                ),
                                child: Icon(Iconsax.tick_circle_copy, size: 28, color: context.primary),
                              ),
                              const SizedBox(height: 14),
                              Text("You're all caught up",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                              const SizedBox(height: 4),
                              Text('Pull down to refresh',
                                style: TextStyle(fontSize: 12, color: context.textSecondary)),
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
      ),
    );
  }
}

class _NotifBadgeIcon extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider).valueOrNull ?? 0;
    return Stack(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.surfaceFill,
          ),
          child: IconButton(
            icon: Icon(Iconsax.notification, size: 18, color: context.textPrimary),
            onPressed: () => context.push('/notifications'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        if (unread > 0)
          Positioned(
            right: 6, top: 6,
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: context.error, shape: BoxShape.circle, border: Border.all(color: context.surfaceBg, width: 1.5)),
            ),
          ),
      ],
    );
  }
}

class _StoriesRow extends ConsumerWidget {
  final String? avatarUrl;
  final String firstName;
  final List<dynamic> groups;

  const _StoriesRow({this.avatarUrl, required this.firstName, required this.groups});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    final myGroup = groups.where((g) => g.authorId == uid).firstOrNull;
    final otherGroups = groups.where((g) => g.authorId != uid).toList();

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: USpacing.sm),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: USpacing.base),
        itemCount: 1 + otherGroups.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _StoryCircle(
              name: firstName.isNotEmpty ? firstName : 'You',
              initial: firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
              color: context.primary,
              isUser: true,
              onTap: () {
                if (myGroup != null) {
                  final allGroups = [myGroup, ...otherGroups];
                  context.push('/stories/view', extra: {'groups': allGroups, 'index': 0});
                } else {
                  context.push('/stories/create');
                }
              },
            );
          }
          final g = otherGroups[index - 1];
          return _StoryCircle(
            name: g.authorName ?? 'User',
            initial: g.initials ?? 'U',
            color: context.primary,
            viewed: !g.hasUnseen,
            onTap: () {
              final allGroups = myGroup != null ? [myGroup, ...otherGroups] : otherGroups;
              final viewIndex = myGroup != null ? index : index + 1;
              context.push('/stories/view', extra: {'groups': allGroups, 'index': viewIndex});
            },
          );
        },
      ),
    );
  }
}

class _StoryCircle extends StatelessWidget {
  final String name;
  final String initial;
  final Color color;
  final bool isUser;
  final bool viewed;
  final VoidCallback onTap;

  const _StoryCircle({
    required this.name, required this.initial, required this.color,
    this.isUser = false, this.viewed = false, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: USpacing.md),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: viewed ? null : LinearGradient(
                      colors: [const Color(0xFFF97316), const Color(0xFFEC4899)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    border: viewed ? Border.all(color: context.borderSubtle, width: 2.5) : null,
                  ),
                ),
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.surfaceFill,
                    border: Border.all(color: context.surfaceBg, width: 3),
                  ),
                  child: Center(
                    child: Text(initial, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: context.textSecondary)),
                  ),
                ),
                if (isUser)
                  Positioned(
                    right: 1, bottom: 1,
                    child: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: context.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.surfaceBg, width: 2.5),
                      ),
                      child: Icon(Iconsax.add, color: context.onPrimary, size: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isUser ? 'Your Story' : name.split(' ').first,
              style: TextStyle(fontSize: 11, color: context.textSecondary, fontWeight: FontWeight.w400),
              maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final Announcement post;
  final List<String> images;
  final bool hasMore;
  final int currentImageIndex;
  final ValueChanged<int>? onPageChanged;

  const _PostCard({
    required this.post, required this.images, required this.hasMore,
    required this.currentImageIndex, this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeState = ref.watch(
      announcementLikeProvider((id: post.id, initialCount: post.likesCount)),
    );
    final isDark = context.isDark;

    return Padding(
      padding: EdgeInsets.fromLTRB(USpacing.base, 0, USpacing.base, USpacing.base),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: BorderRadius.circular(URadius.base),
          border: Border.all(color: context.borderSubtle.withValues(alpha: isDark ? 0.3 : 0.5)),
          boxShadow: isDark ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))] : context.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(USpacing.md, USpacing.md, USpacing.sm, USpacing.sm),
              child: Row(
                children: [
                  _Avatar(avatarUrl: post.authorAvatar, name: post.authorName, size: 36),
                  SizedBox(width: USpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.authorName ?? 'Campus Admin',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (post.authorIsVerifiedLeader) ...[
                              SizedBox(width: 3),
                              Icon(Icons.verified_rounded, size: 13, color: context.primary),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            if (post.authorLeadershipRole != null) ...[
                              Text(post.authorLeadershipRole!, style: TextStyle(fontSize: 11, color: context.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(' · ', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                            ],
                            Text(_timeAgo(post.createdAt), style: TextStyle(fontSize: 11, color: context.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 32, height: 32,
                    child: IconButton(
                      icon: Icon(Iconsax.more, size: 18, color: context.textSecondary),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            if (images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(URadius.md),
                child: SizedBox(
                  height: 360,
                  child: images.length == 1
                      ? CachedNetworkImage(
                          imageUrl: images[0],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                        )
                      : Stack(
                          children: [
                            PageView.builder(
                              itemCount: images.length,
                              onPageChanged: onPageChanged,
                              itemBuilder: (context, i) => CachedNetworkImage(
                                imageUrl: images[i],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorWidget: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                            if (hasMore)
                              Positioned(
                                bottom: 16, left: 0, right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    images.length,
                                    (i) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: currentImageIndex == i ? 8 : 6,
                                      height: currentImageIndex == i ? 8 : 6,
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: currentImageIndex == i ? context.primary : Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),

            Padding(
              padding: EdgeInsets.fromLTRB(USpacing.md, USpacing.sm, USpacing.md, 0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: context.textPrimary, fontSize: 13, height: 1.45),
                  children: [
                    TextSpan(text: '${post.title}  ', style: const TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: post.body, style: const TextStyle(fontWeight: FontWeight.w400)),
                  ],
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (post.isUrgent)
              Padding(
                padding: const EdgeInsets.fromLTRB(USpacing.md, USpacing.xs, 0, 0),
                child: Row(
                  children: [
                    Icon(Iconsax.danger_copy, size: 12, color: context.error),
                    SizedBox(width: 3),
                    Text('Urgent', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.error)),
                  ],
                ),
              ),

            Padding(
              padding: EdgeInsets.fromLTRB(USpacing.md, USpacing.sm, USpacing.md, USpacing.xs),
              child: Row(
                children: [
                  _ActionIcon(
                    icon: likeState.isLiked ? Iconsax.heart_copy : Iconsax.heart,
                    color: likeState.isLiked ? const Color(0xFFE1306C) : context.textSecondary,
                    onTap: () => ref.read(announcementLikeProvider((id: post.id, initialCount: post.likesCount)).notifier).toggle(),
                  ),
                  SizedBox(width: USpacing.lg),
                  _ActionIcon(
                    icon: Iconsax.message_text,
                    color: context.textSecondary,
                    onTap: () => CommentSheet.show(context, post.id),
                  ),
                  SizedBox(width: USpacing.lg),
                  _ActionIcon(
                    icon: Iconsax.export_3,
                    color: context.textSecondary,
                    onTap: () async {
                      await Share.share('${post.title}\n\n${post.body}', subject: post.title);
                      ref.read(announcementSocialRepoProvider).recordShare(post.id);
                    },
                  ),
                  const Spacer(),
                  _ActionIcon(
                    icon: Iconsax.bookmark,
                    color: context.textSecondary,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            if (likeState.count > 0 || post.commentsCount > 0)
              Padding(
                padding: EdgeInsets.fromLTRB(USpacing.md, 0, USpacing.md, USpacing.sm),
                child: Row(
                  children: [
                    if (likeState.count > 0)
                      Text('${_fmtNum(likeState.count)} likes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.textPrimary)),
                    if (likeState.count > 0 && post.commentsCount > 0) SizedBox(width: USpacing.xs),
                    if (post.commentsCount > 0)
                      GestureDetector(
                        onTap: () => CommentSheet.show(context, post.id),
                        child: Text('${_fmtNum(post.commentsCount)} ${post.commentsCount == 1 ? 'comment' : 'comments'}', style: TextStyle(fontSize: 12, color: context.textSecondary)),
                      ),
                  ],
                ),
              ),

            Padding(
              padding: EdgeInsets.fromLTRB(USpacing.md, 0, USpacing.md, USpacing.md),
              child: Text(_timeAgo(post.createdAt), style: TextStyle(fontSize: 10, color: context.textDisabled)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final String? name;
  final double size;

  const _Avatar({this.avatarUrl, this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final label = name?.isNotEmpty == true ? name![0].toUpperCase() : 'U';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.surfaceFill,
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Center(
                  child: Text(label, style: TextStyle(fontSize: size * 0.45, fontWeight: FontWeight.w700, color: context.textSecondary)),
                ),
              )
            : Center(
                child: Text(label, style: TextStyle(fontSize: size * 0.45, fontWeight: FontWeight.w700, color: context.textSecondary)),
              ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.shimmerBase;

    return Padding(
      padding: EdgeInsets.fromLTRB(USpacing.base, 0, USpacing.base, USpacing.base),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: BorderRadius.circular(URadius.base),
          border: Border.all(color: context.borderSubtle.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(USpacing.md),
              child: Row(
                children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: s, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100, height: 12, decoration: BoxDecoration(color: s, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 6),
                      Container(width: 60, height: 10, decoration: BoxDecoration(color: s, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ],
              ),
            ),
            Container(height: 360, color: s),
            Padding(
              padding: const EdgeInsets.all(USpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: double.infinity, height: 10, decoration: BoxDecoration(color: s, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 6),
                  Container(width: 160, height: 10, decoration: BoxDecoration(color: s, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: USpacing.md),
                  Row(
                    children: [
                      Container(width: 22, height: 22, decoration: BoxDecoration(color: s, shape: BoxShape.circle)),
                      SizedBox(width: USpacing.lg),
                      Container(width: 22, height: 22, decoration: BoxDecoration(color: s, shape: BoxShape.circle)),
                      SizedBox(width: USpacing.lg),
                      Container(width: 22, height: 22, decoration: BoxDecoration(color: s, shape: BoxShape.circle)),
                    ],
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
