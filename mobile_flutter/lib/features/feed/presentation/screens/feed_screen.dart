import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/feed_provider.dart';
import '../../domain/entities/announcement.dart';
import '../widgets/announcement_card.dart';
import '../widgets/story_circle.dart';
import '../widgets/category_tabs.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../system/presentation/widgets/system_announcement_banner.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../snapshots/data/models/snapshot_models.dart';
import '../../../snapshots/presentation/providers/snapshot_provider.dart';
import 'package:unify/core/design_system/components.dart';

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
            // ── App bar ──────────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: context.appBarBg,
              surfaceTintColor: context.appBarBg,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 52,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.add_box_outlined, color: context.textPrimary, size: 24),
                onPressed: () => context.push('/stories/create'),
                tooltip: 'New Story',
              ),
              title: Text(
                'UNIFY',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: context.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                _NotifBadgeIcon(),
                IconButton(
                  icon: Icon(Icons.send_outlined, color: context.textPrimary, size: 22),
                  onPressed: () => context.go('/app/messaging'),
                  tooltip: 'Messages',
                ),
                const SizedBox(width: 4),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: context.borderCol),
              ),
            ),

            // ── System announcements ──────────────────────────────────────────
            const SliverToBoxAdapter(child: SystemAnnouncementBanner()),

            // ── Stories row ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _StoriesRow(
                avatarUrl: avatarUrl,
                firstName: firstName,
                groups: storyGroupsAsync.valueOrNull ?? [],
              ),
            ),

            // ── Category tabs (pinned) ─────────────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoryTabsDelegate(
                tabs: _tabs,
                selectedIndex: _tabIndex,
                onSelect: (i) => setState(() => _tabIndex = i),
              ),
            ),

            // ── Feed content ──────────────────────────────────────────────────
            feedAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => const UShimmerCard(),
                  childCount: 5,
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: context.inputFill,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.wifi_off_rounded, size: 32, color: Color(0xFF9CA3AF)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Could not load feed',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ErrorMapper.toUserMessage(e),
                          style: TextStyle(fontSize: 13, color: context.textSecondary),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => ref.invalidate(feedProvider),
                          style: FilledButton.styleFrom(
                            backgroundColor: context.primary,
                            minimumSize: const Size(120, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              data: (feedState) {
                final items = _filtered(feedState.items);
                if (items.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: context.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.campaign_outlined, size: 32, color: context.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nothing here yet',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Check back soon for campus updates.',
                            style: TextStyle(fontSize: 13, color: context.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverMainAxisGroup(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => AnnouncementCard(
                          item: items[i],
                          onTap: () => ref.read(feedProvider.notifier).markRead(items[i].id),
                        ),
                        childCount: items.length,
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
                                  color: context.inputFill,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check_circle_outline_rounded, size: 28, color: context.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "You're all caught up",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textSecondary),
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
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stories row ───────────────────────────────────────────────────────────────

class _StoriesRow extends ConsumerWidget {
  const _StoriesRow({
    this.avatarUrl,
    required this.firstName,
    required this.groups,
  });

  final String? avatarUrl;
  final String firstName;
  final List<SnapshotGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Separate own group from others
    final uid = Supabase.instance.client.auth.currentUser?.id;
    final myGroup = groups.where((g) => g.authorId == uid).firstOrNull;
    final otherGroups = groups.where((g) => g.authorId != uid).toList();

    return Container(
      color: context.appBarBg,
      padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
      child: SizedBox(
        height: 88,
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
                hasRing: myGroup != null, // ring if user has active story
                size: 56,
                onTap: () {
                  if (myGroup != null) {
                    // View own story
                    final allGroups = [myGroup, ...otherGroups];
                    context.push('/stories/view', extra: {
                      'groups': allGroups,
                      'index': 0,
                    });
                  } else {
                    // Create new story
                    context.push('/stories/create');
                  }
                },
              ),
            ),
            // Other users' stories
            ...otherGroups.asMap().entries.map((entry) {
              final i = entry.key;
              final g = entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: StoryCircle(
                  name: g.authorName ?? 'User',
                  imageUrl: g.authorAvatar,
                  initials: g.initials,
                  hasRing: g.hasUnseen,
                  size: 56,
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

// ── Category tabs delegate (pinned SliverPersistentHeader) ────────────────────

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
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: context.appBarBg,
      child: Column(
        children: [
          Expanded(
            child: CategoryTabs(
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

// ── Notification badge icon ───────────────────────────────────────────────────

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
