import 'dart:ui';
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
import '../widgets/post_options_sheet.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../system/presentation/widgets/system_announcement_banner.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../snapshots/presentation/providers/snapshot_provider.dart';
import '../../../../core/widgets/unify_logo.dart';

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

    return Scaffold(
      backgroundColor: context.surfaceBg,
      body: Column(
        children: [
          _GlassHeader(fullName: fullName, avatarUrl: avatarUrl),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(feedProvider.notifier).refresh();
                await ref.read(storyGroupsProvider.notifier).refresh();
              },
              color: context.primary,
              strokeWidth: 2.5,
              displacement: 80,
              child: CustomScrollView(
                controller: _scrollCtrl,
                slivers: [
                  const SliverToBoxAdapter(
                    child: SystemAnnouncementBanner(),
                  ),
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
                        (_, i) => const _ShimmerCard(),
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
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              USpacing.sm, 0, USpacing.sm, USpacing.base,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final post = feedState.items[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      top: USpacing.sm,
                                    ),
                                    child: _PostCard(post: post),
                                  );
                                },
                                childCount: feedState.items.length,
                              ),
                            ),
                          ),
                          if (feedState.isLoadingMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: SizedBox(
                                    width: 24, height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else if (!feedState.hasMore)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24, 40, 24, 96,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 56, height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: context.primary
                                            .withValues(alpha: 0.1),
                                      ),
                                      child: Icon(
                                        Iconsax.tick_circle_copy,
                                        size: 28,
                                        color: context.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      "You're all caught up",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: context.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pull down to refresh',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 32),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: const _FabButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _GlassHeader extends StatelessWidget {
  final String fullName;
  final String? avatarUrl;

  const _GlassHeader({required this.fullName, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: USpacing.sm,
            left: USpacing.base,
            right: USpacing.base,
          ),
          decoration: BoxDecoration(
            color: context.isDark
                ? Colors.black.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.9),
            border: Border(
              bottom: BorderSide(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            children: [
              const UnifyLogo(size: 40),
              const SizedBox(width: USpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'UNIFY',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('👋', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    Text(
                      "What's happening on campus today?",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: USpacing.sm),
              _NotifBadgeIcon(),
              const SizedBox(width: USpacing.md),
              _AvatarWithStatus(
                avatarUrl: avatarUrl,
                name: fullName,
                size: 32,
                hasGreenDot: true,
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
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Iconsax.notification,
            size: 24,
            color: context.textPrimary,
          ),
          onPressed: () => context.push('/notifications'),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        if (unread > 0)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.isDark
                      ? Colors.black
                      : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AvatarWithStatus extends StatelessWidget {
  final String? avatarUrl;
  final String? name;
  final double size;
  final bool hasGreenDot;

  const _AvatarWithStatus({
    this.avatarUrl,
    this.name,
    required this.size,
    this.hasGreenDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = name?.isNotEmpty == true ? name![0].toUpperCase() : 'U';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.borderSubtle,
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: avatarUrl != null
                ? CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _AvatarFallback(
                      label: label,
                      size: size,
                    ),
                  )
                : _AvatarFallback(label: label, size: size),
          ),
        ),
        if (hasGreenDot)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.isDark
                      ? Colors.black
                      : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String label;
  final double size;

  const _AvatarFallback({required this.label, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.surfaceFill,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.w700,
            color: context.textSecondary,
          ),
        ),
      ),
    );
  }
}

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
    final myGroup = groups.where((g) => g.authorId == uid).firstOrNull;
    final otherGroups = groups.where((g) => g.authorId != uid).toList();

    return Container(
      color: context.surfaceCard,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: USpacing.base),
          itemCount: 1 + otherGroups.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _StoryCircle(
                name: firstName.isNotEmpty ? firstName : 'You',
                label: 'Your Story',
                isOwn: true,
                onTap: () {
                  if (myGroup != null) {
                    final allGroups = [myGroup, ...otherGroups];
                    context.push(
                      '/stories/view',
                      extra: {'groups': allGroups, 'index': 0},
                    );
                  } else {
                    context.push('/stories/create');
                  }
                },
              );
            }
            final g = otherGroups[index - 1];
            return _StoryCircle(
              name: g.authorName ?? 'User',
              label: g.authorName?.split(' ').first ?? 'User',
              hasUnseen: g.hasUnseen ?? true,
              onTap: () {
                final allGroups = myGroup != null
                    ? [myGroup, ...otherGroups]
                    : otherGroups;
                final viewIndex = myGroup != null ? index : index + 1;
                context.push(
                  '/stories/view',
                  extra: {'groups': allGroups, 'index': viewIndex},
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StoryCircle extends StatelessWidget {
  final String name;
  final String label;
  final bool isOwn;
  final bool hasUnseen;
  final VoidCallback onTap;

  const _StoryCircle({
    required this.name,
    required this.label,
    this.isOwn = false,
    this.hasUnseen = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: USpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isOwn)
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.borderSubtle,
                        width: 2,
                      ),
                    ),
                    child: const SizedBox(),
                  )
                else if (hasUnseen)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2563EB),
                          Color(0xFF7C3AED),
                          Color(0xFF14B8A6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.borderSubtle,
                    ),
                  ),
                Container(
                  width: isOwn ? 60 : 64,
                  height: isOwn ? 60 : 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.surfaceCard,
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: _StoryAvatar(name: name),
                  ),
                ),
                if (isOwn)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: context.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.surfaceCard,
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        Iconsax.add,
                        color: context.onPrimary,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isOwn ? 'Your Story' : label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isOwn ? FontWeight.w600 : FontWeight.w500,
                color: isOwn
                    ? context.textPrimary
                    : (hasUnseen
                        ? context.textPrimary
                        : context.textSecondary),
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
  final String name;

  const _StoryAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return _buildFallback(context, initial);
  }

  Widget _buildFallback(BuildContext context, String initial) {
    return Container(
      color: context.surfaceFill,
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: context.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final Announcement post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeState = ref.watch(
      announcementLikeProvider((
        id: post.id,
        initialCount: post.likesCount,
      )),
    );
    final saveState = ref.watch(announcementSaveProvider(post.id));
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 3,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(post: post),
          if (post.imageUrl != null)
            _PostMedia(imageUrl: post.imageUrl!, category: post.category),
          _PostBody(post: post),
          if (post.isUrgent)
            Padding(
              padding: EdgeInsets.fromLTRB(
                USpacing.base, 0, USpacing.base, USpacing.xs,
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.danger_copy,
                    size: 12,
                    color: context.error,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Urgent',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.error,
                    ),
                  ),
                ],
              ),
            ),
          _ActionRow(
            post: post,
            likeState: likeState,
            saveState: saveState,
            onLike: () => ref
                .read(announcementLikeProvider((
                  id: post.id,
                  initialCount: post.likesCount,
                )).notifier)
                .toggle(),
            onComment: () => CommentSheet.show(context, post.id),
            onShare: () async {
              await Share.share(
                '${post.title}\n\n${post.body}',
                subject: post.title,
              );
              ref
                  .read(announcementSocialRepoProvider)
                  .recordShare(post.id);
            },
            onSave: () => ref
                .read(announcementSaveProvider(post.id).notifier)
                .toggle(),
          ),
          _PostFooter(post: post, likeState: likeState),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final Announcement post;

  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        USpacing.base, USpacing.base, USpacing.sm, USpacing.sm,
      ),
      child: Row(
        children: [
          _AvatarWithStatus(
            avatarUrl: post.authorAvatar,
            name: post.authorName,
            size: 40,
          ),
          const SizedBox(width: USpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        post.authorName ?? 'Campus Admin',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (post.authorIsVerifiedLeader) ...[
                      const SizedBox(width: 3),
                      Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: context.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    if (post.authorLeadershipRole != null) ...[
                      Text(
                        post.authorLeadershipRole!,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                    Text(
                      _timeAgo(post.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Iconsax.more,
              size: 20,
              color: context.textDisabled,
            ),
            onPressed: () => PostOptionsSheet.show(context, post),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _PostMedia extends StatelessWidget {
  final String imageUrl;
  final String category;

  const _PostMedia({
    required this.imageUrl,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: USpacing.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 200,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: context.surfaceFill,
                  child: Icon(
                    Iconsax.gallery,
                    size: 32,
                    color: context.textDisabled,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.surfaceCard.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    category == 'events' ? 'Campus Event' : 'Campus',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostBody extends StatelessWidget {
  final Announcement post;

  const _PostBody({required this.post});

  @override
  Widget build(BuildContext context) {
    final isAcademic = post.category == 'academic';
    final body = post.body;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        USpacing.base,
        post.imageUrl != null ? USpacing.sm : USpacing.xs,
        USpacing.base,
        USpacing.xs,
      ),
      child: isAcademic
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(USpacing.base),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.isDark
                      ? context.primary.withValues(alpha: 0.2)
                      : const Color(0xFFDBEAFE),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final Announcement post;
  final LikeState likeState;
  final SaveState saveState;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const _ActionRow({
    required this.post,
    required this.likeState,
    required this.saveState,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        USpacing.base, USpacing.sm, USpacing.base, 0,
      ),
      child: Row(
        children: [
          _ActionButton(
            icon: likeState.isLiked ? Iconsax.heart_copy : Iconsax.heart,
            color: likeState.isLiked
                ? const Color(0xFFE1306C)
                : context.textSecondary,
            label: _fmtNum(likeState.count),
            onTap: onLike,
          ),
          const SizedBox(width: USpacing.lg),
          _ActionButton(
            icon: Iconsax.message_text,
            color: context.textSecondary,
            label: _fmtNum(post.commentsCount),
            onTap: onComment,
          ),
          const SizedBox(width: USpacing.lg),
          _ActionButton(
            icon: Iconsax.send_2,
            color: context.textSecondary,
            onTap: onShare,
          ),
          const Spacer(),
          _ActionButton(
            icon: saveState.isSaved ? Iconsax.bookmark_copy : Iconsax.bookmark,
            color: saveState.isSaved
                ? context.primary
                : context.textSecondary,
            onTap: onSave,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color),
          if (label != null) ...[
            const SizedBox(width: 5),
            Text(
              label!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PostFooter extends StatelessWidget {
  final Announcement post;
  final LikeState likeState;

  const _PostFooter({
    required this.post,
    required this.likeState,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        USpacing.base,
        USpacing.xs,
        USpacing.base,
        USpacing.base,
      ),
      child: Row(
        children: [
          if (likeState.count > 0)
            Text(
              '${_fmtNum(likeState.count)} likes',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          if (likeState.count > 0 && post.commentsCount > 0)
            const SizedBox(width: 4),
          if (post.commentsCount > 0)
            GestureDetector(
              onTap: () => CommentSheet.show(context, post.id),
              child: Text(
                '${_fmtNum(post.commentsCount)} ${post.commentsCount == 1 ? 'comment' : 'comments'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: context.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  const _FabButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: context.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Iconsax.add, color: Colors.white, size: 28),
        onPressed: () {
          // TODO: navigate to create post screen
        },
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    final s = context.shimmerBase;
    final isDark = context.isDark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDark
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(USpacing.base),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: s,
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
                          color: s,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          color: s,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: USpacing.sm),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: s,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(USpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: s,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 160,
                    height: 10,
                    decoration: BoxDecoration(
                      color: s,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: s,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: USpacing.lg),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: s,
                          shape: BoxShape.circle,
                        ),
                      ),
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
  if (n >= 1000) {
    return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  }
  return '$n';
}
