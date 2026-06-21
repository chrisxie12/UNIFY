import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unify/core/design_system/components.dart';
import '../providers/announcement_social_provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/story_circle.dart';
import '../../domain/entities/announcement.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../snapshots/data/models/snapshot_models.dart';
import '../../../snapshots/presentation/providers/snapshot_provider.dart';
import '../../../system/presentation/widgets/system_announcement_banner.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/extensions/theme_extensions.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kAspectRatio = 4 / 5;

const _kCategoryColors = <String, Color>{
  'general':  Color(0xFF64748B),
  'admin':    Color(0xFFDC2626),
  'events':   Color(0xFF7C3AED),
  'academic': Color(0xFF2563EB),
};

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  return DateFormat('MMM d').format(dt);
}

String _fmtNum(int n) {
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  return '$n';
}

// ─────────────────────────────────────────────────────────────────────────────
// FeedScreen
// ─────────────────────────────────────────────────────────────────────────────

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollCtrl = ScrollController();
  int _tabIndex = 0;

  static const _tabs = ['All', 'Academic', 'Events', 'Admin', 'General'];

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
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  List<Announcement> _filtered(List<Announcement> all) {
    if (_tabIndex == 0) return all;
    final cat = _tabs[_tabIndex].toLowerCase();
    return all.where((a) => a.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ?? '';
    final firstName = fullName.split(' ').first;
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;
    final storyGroupsAsync = ref.watch(storyGroupsProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(feedProvider.notifier).refresh();
          await ref.read(storyGroupsProvider.notifier).refresh();
        },
        color: context.primary,
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            // ── Pinned top bar (52px) ───────────────────────────────────────
            SliverAppBar(
              backgroundColor: context.appBarBg,
              surfaceTintColor: context.appBarBg,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              toolbarHeight: 52,
              centerTitle: false,
              title: Text(
                'UNIFY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: context.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.send_outlined, color: context.textPrimary, size: 22),
                  onPressed: () => context.go('/app/messaging'),
                  tooltip: 'Messages',
                ),
                _NotifBadgeIcon(),
              ],
            ),

            // ── System announcements ───────────────────────────────────────
            const SliverToBoxAdapter(child: SystemAnnouncementBanner()),

            // ── Stories train ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _StoriesTrain(
                avatarUrl: avatarUrl,
                firstName: firstName,
                groups: storyGroupsAsync.valueOrNull ?? [],
              ),
            ),

            // ── Update input (44px pill) ──────────────────────────────────
            SliverToBoxAdapter(child: _UpdateInput(avatarUrl: avatarUrl)),

            // ── Category tabs (pinned) ──────────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoryTabsDelegate(
                tabs: _tabs,
                selectedIndex: _tabIndex,
                onSelect: (i) => setState(() => _tabIndex = i),
              ),
            ),

            // ── Feed content ───────────────────────────────────────────────
            feedAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => const _ShimmerFeedCard(),
                  childCount: 4,
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: UEmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: 'Could not load feed',
                  subtitle: ErrorMapper.toUserMessage(e),
                  actionLabel: 'Try again',
                  onAction: () => ref.invalidate(feedProvider),
                ),
              ),
              data: (feedState) {
                final items = _filtered(feedState.items);
                if (items.isEmpty) {
                  return SliverFillRemaining(
                    child: UEmptyState(
                      icon: Icons.campaign_outlined,
                      title: 'Nothing here yet',
                      subtitle: 'Check back soon for campus updates.',
                    ),
                  );
                }

                final rows = <Widget>[];
                bool addedLatestLabel = false;
                for (int i = 0; i < items.length; i++) {
                  final post = items[i];
                  if (_tabIndex == 0 && i == 0 && post.isPinned) {
                    rows.add(const _SectionLabel('PINNED'));
                  }
                  if (_tabIndex == 0 && !post.isPinned && !addedLatestLabel) {
                    rows.add(const _SectionLabel('LATEST'));
                    addedLatestLabel = true;
                  }
                  rows.add(_FeedCard(
                    item: post,
                    onTap: () => ref.read(feedProvider.notifier).markRead(post.id),
                  ));
                }

                return SliverMainAxisGroup(slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => rows[i],
                      childCount: rows.length,
                    ),
                  ),
                  if (feedState.isLoadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: context.primary, strokeWidth: 2),
                          ),
                        ),
                      ),
                    )
                  else if (!feedState.hasMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 96),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: context.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check_circle_outline_rounded, size: 28, color: context.primary),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "You're all caught up",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pull down to refresh for new updates',
                              style: TextStyle(fontSize: 12, color: context.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StoriesTrain — Instagram-style story circles with gradient rings
// ─────────────────────────────────────────────────────────────────────────────

class _StoriesTrain extends ConsumerWidget {
  const _StoriesTrain({
    this.avatarUrl,
    required this.firstName,
    required this.groups,
  });

  final String? avatarUrl;
  final String firstName;
  final List<SnapshotGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    final myGroup = groups.where((g) => g.authorId == uid).firstOrNull;
    final otherGroups = groups.where((g) => g.authorId != uid).toList();

    return Container(
      color: context.appBarBg,
      padding: const EdgeInsets.fromLTRB(12, 10, 0, 6),
      child: SizedBox(
        height: 92,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // Your story
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: StoryCircle(
                name: firstName.isNotEmpty ? firstName : 'You',
                imageUrl: myGroup?.authorAvatar ?? avatarUrl,
                initials: firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                isSelf: true,
                hasRing: myGroup != null,
                size: 60,
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
              ),
            ),
            // Other users' stories — always show gradient ring
            ...otherGroups.asMap().entries.map((entry) {
              final i = entry.key;
              final g = entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: StoryCircle(
                  name: g.authorName ?? 'User',
                  imageUrl: g.authorAvatar,
                  initials: g.initials,
                  hasRing: true,
                  size: 60,
                  onTap: () {
                    final allGroups = myGroup != null
                        ? [myGroup, ...otherGroups]
                        : otherGroups;
                    final viewIndex = myGroup != null ? i + 1 : i;
                    context.push('/stories/view', extra: {
                      'groups': allGroups,
                      'index': viewIndex,
                    });
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _UpdateInput — 44px pill with avatar + "What's on your mind?"
// ─────────────────────────────────────────────────────────────────────────────

class _UpdateInput extends StatelessWidget {
  const _UpdateInput({this.avatarUrl});
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ?? '';
    final avatar = user?.userMetadata?['avatar_url'] as String?;

    return Container(
      color: context.appBarBg,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 36,
              height: 36,
              child: avatar != null
                  ? CachedNetworkImage(
                      imageUrl: avatar,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _AvatarFallback(name: fullName),
                    )
                  : _AvatarFallback(name: fullName),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/stories/create'),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: context.inputFill,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: context.borderCol, width: 0.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  "What's on your mind?",
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.primary.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: context.primary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CategoryTabsDelegate — pinned sliver header
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  const _CategoryTabsDelegate({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  double get minExtent => 46;

  @override
  double get maxExtent => 46;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: context.appBarBg,
      child: Column(
        children: [
          Expanded(
            child: _CategoryTabs(
              tabs: tabs,
              selectedIndex: selectedIndex,
              onSelect: onSelect,
            ),
          ),
          Container(height: 1, color: context.borderCol),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryTabsDelegate old) =>
      old.selectedIndex != selectedIndex;
}

// ─────────────────────────────────────────────────────────────────────────────
// _CategoryTabs — horizontal pill filter row
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => _CategoryPill(
          label: tabs[i],
          selected: selectedIndex == i,
          onTap: () => onSelect(i),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? context.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? context.primary : context.borderCol,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : context.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FeedCard — Instagram-style card mapped to Announcement entity
// ─────────────────────────────────────────────────────────────────────────────

class _FeedCard extends ConsumerWidget {
  const _FeedCard({required this.item, this.onTap});

  final Announcement item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeState = ref.watch(
      announcementLikeProvider((id: item.id, initialCount: item.likesCount)),
    );
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;
    final catKey = item.category.toLowerCase();
    final catColor = _kCategoryColors[catKey] ?? context.primary;
    final catLabel = item.category[0].toUpperCase() + item.category.substring(1);

    return Column(
      children: [
        // ── Card header ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: item.authorAvatar != null
                      ? CachedNetworkImage(
                          imageUrl: item.authorAvatar!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _AvatarFallback(name: item.authorName ?? 'U'),
                        )
                      : _AvatarFallback(name: item.authorName ?? 'U'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.authorName ?? 'Campus Admin',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.authorIsVerifiedLeader) ...[
                          const SizedBox(width: 3),
                          Icon(Icons.verified_rounded, size: 12, color: context.primary),
                        ],
                      ],
                    ),
                    if (item.authorLeadershipRole != null)
                      Text(
                        item.authorLeadershipRole!,
                        style: TextStyle(fontSize: 11, color: context.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(catLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: catColor)),
              ),
              const SizedBox(width: 2),
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.more_horiz, color: context.textSecondary, size: 18),
                ),
              ),
            ],
          ),
        ),

        // ── Media container (4:5 edge-to-edge) ───────────────────────────────
        if (hasImage)
          GestureDetector(
            onDoubleTap: () {
              ref
                  .read(announcementLikeProvider((id: item.id, initialCount: item.likesCount)).notifier)
                  .toggle();
            },
            child: AspectRatio(
              aspectRatio: _kAspectRatio,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: context.inputFill,
                  child: Center(
                    child: Icon(Icons.broken_image_outlined, color: context.textSecondary, size: 32),
                  ),
                ),
              ),
            ),
          ),

        // ── Caption ──────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(12, hasImage ? 10 : 12, 12, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.isPinned)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.push_pin_rounded, size: 12, color: catColor),
                      const SizedBox(width: 3),
                      Text('Pinned', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: catColor)),
                    ],
                  ),
                ),
              if (item.isUrgent)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.priority_high_rounded, size: 12, color: Color(0xFFDC2626)),
                      const SizedBox(width: 3),
                      Text('Urgent', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                    ],
                  ),
                ),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: context.textPrimary, height: 1.4),
                  children: [
                    TextSpan(
                      text: '${item.authorName ?? 'Campus Admin'}  ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: item.title,
                    ),
                    if (item.body.isNotEmpty)
                      TextSpan(
                        text: '  ${item.body}',
                      ),
                  ],
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // ── Action row (icon-only, Instagram-style) ──────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
          child: Row(
            children: [
              _IconBtn(
                icon: likeState.isLiked ? Icons.favorite : Icons.favorite_border,
                color: likeState.isLiked ? const Color(0xFFE1306C) : context.textSecondary,
                onTap: () {
                  onTap?.call();
                  ref
                      .read(announcementLikeProvider((id: item.id, initialCount: item.likesCount)).notifier)
                      .toggle();
                },
              ),
              _IconBtn(
                icon: Icons.mode_comment_outlined,
                color: context.textSecondary,
                onTap: () => CommentSheet.show(context, item.id),
              ),
              _IconBtn(
                icon: Icons.send_outlined,
                color: context.textSecondary,
                onTap: () async {
                  await Share.share('${item.title}\n\n${item.body}', subject: item.title);
                  ref.read(announcementSocialRepoProvider).recordShare(item.id);
                },
              ),
              const Spacer(),
              _IconBtn(
                icon: Icons.bookmark_border_outlined,
                color: context.textSecondary,
                onTap: () {},
              ),
            ],
          ),
        ),

        // ── Like count ───────────────────────────────────────────────────────
        if (likeState.count > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_fmtNum(likeState.count)} likes',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary),
              ),
            ),
          ),

        // ── Comments link ────────────────────────────────────────────────────
        if (item.commentsCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => CommentSheet.show(context, item.id),
                child: Text(
                  'View all ${_fmtNum(item.commentsCount)} comments',
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                ),
              ),
            ),
          ),

        // ── Timestamp ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _timeAgo(item.createdAt).toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: context.textSecondary.withValues(alpha: 0.7),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),

        // ── Spacer ──────────────────────────────────────────────────────────
        const SizedBox(height: 8),
        Divider(height: 1, thickness: 0.5, color: context.borderCol),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _IconBtn — icon-only pressable (no label, Instagram-style)
// ─────────────────────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionLabel — PINNED / LATEST label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NotifBadgeIcon — notification bell with unread count
// ─────────────────────────────────────────────────────────────────────────────

class _NotifBadgeIcon extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider).valueOrNull ?? 0;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.favorite_border, color: context.textPrimary, size: 24),
          onPressed: () => context.push('/notifications'),
          tooltip: 'Notifications',
        ),
        if (unread > 0)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              height: 16,
              constraints: const BoxConstraints(minWidth: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: context.error,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.surfaceCard, width: 2),
              ),
              child: Center(
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  style: TextStyle(
                    color: context.textInverse,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ShimmerFeedCard — Instagram-style skeleton loader
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerFeedCard extends StatelessWidget {
  const _ShimmerFeedCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                UShimmerBox(width: 32, height: 32, radius: BorderRadius.circular(16)),
                const SizedBox(width: 10),
                Expanded(child: UShimmerBox(height: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: _kAspectRatio,
            child: UShimmerBox(height: double.infinity, radius: BorderRadius.zero),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                const UShimmerBox(height: 12),
                const SizedBox(height: 4),
                UShimmerBox(width: 160, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
