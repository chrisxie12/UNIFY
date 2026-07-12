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
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;
    final storyGroupsAsync = ref.watch(storyGroupsProvider);
    final primary = context.primary;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final bg = context.bg;
    final borderCol = context.borderCol;

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(feedProvider.notifier).refresh();
          await ref.read(storyGroupsProvider.notifier).refresh();
        },
        color: primary,
        strokeWidth: 2.5,
        displacement: 80,
        edgeOffset: 0,
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            SliverAppBar(
              backgroundColor: bg,
              surfaceTintColor: bg,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              toolbarHeight: 48,
              centerTitle: true,
              leading: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: IconButton(
                  icon: Icon(Icons.camera_alt_outlined, color: textPrimary, size: 22),
                  onPressed: () => context.push('/stories/create'),
                  tooltip: 'New Story',
                ),
              ),
              title: Text(
                'UNIFY',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                _NotifBadgeIcon(),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    icon: Icon(Icons.send_outlined, color: textPrimary, size: 22),
                    onPressed: () => context.go('/app/messaging'),
                    tooltip: 'Messages',
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0.5),
                child: Container(height: 0.5, color: borderCol.withValues(alpha: 0.3)),
              ),
            ),

            const SliverToBoxAdapter(child: SystemAnnouncementBanner()),

            SliverToBoxAdapter(
              child: _StoriesRow(
                avatarUrl: avatarUrl,
                firstName: fullName.split(' ').first,
                groups: storyGroupsAsync.valueOrNull ?? [],
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoryTabsDelegate(
                tabs: _tabs,
                selectedIndex: _tabIndex,
                onSelect: (i) => setState(() => _tabIndex = i),
              ),
            ),

            feedAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ShimmerCard(),
                  childCount: 4,
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.wifi_off_rounded, size: 36, color: primary),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Couldn\'t load feed',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ErrorMapper.toUserMessage(e),
                          style: TextStyle(fontSize: 13, color: textSecondary),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => ref.invalidate(feedProvider),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Try again'),
                          style: FilledButton.styleFrom(
                            backgroundColor: primary,
                            minimumSize: const Size(140, 46),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.campaign_outlined, size: 36, color: primary),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Nothing here yet',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back soon for campus updates.',
                              style: TextStyle(fontSize: 13, color: textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final rows = <Widget>[];
                bool addedLatestLabel = false;
                for (int i = 0; i < items.length; i++) {
                  final post = items[i];
                  if (_tabIndex == 0 && i == 0 && post.isPinned) {
                    rows.add(const _SectionHeader('PINNED'));
                  }
                  if (_tabIndex == 0 && !post.isPinned && !addedLatestLabel) {
                    rows.add(const _SectionHeader('LATEST'));
                    addedLatestLabel = true;
                  }
                  rows.add(AnnouncementCard(
                    item: post,
                    onTap: () => ref.read(feedProvider.notifier).markRead(post.id),
                  ));
                }

                return SliverMainAxisGroup(
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
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
                              child: CircularProgressIndicator(color: primary, strokeWidth: 2.5),
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
                                  color: primary.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check_circle_outline_rounded, size: 28, color: primary),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "You're all caught up",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pull down to refresh',
                                style: TextStyle(fontSize: 12, color: textSecondary),
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
    final uid = Supabase.instance.client.auth.currentUser?.id;
    final myGroup = groups.where((g) => g.authorId == uid).firstOrNull;
    final otherGroups = groups.where((g) => g.authorId != uid).toList();

    return Container(
      color: context.appBarBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
      child: SizedBox(
        height: 92,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
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
            ...otherGroups.asMap().entries.map((entry) {
              final i = entry.key;
              final g = entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: StoryCircle(
                  name: g.authorName ?? 'User',
                  imageUrl: g.authorAvatar,
                  initials: g.initials,
                  hasRing: g.hasUnseen,
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
          Container(height: 0.5, color: context.borderCol.withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryTabsDelegate old) =>
      old.selectedIndex != selectedIndex;
}

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

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(Icons.push_pin_rounded, size: 11, color: context.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.textSecondary.withValues(alpha: 0.6),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final borderCol = context.borderCol;
    final shimmer = context.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.08);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: shimmer, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 12, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 6),
                    Container(width: 80, height: 10, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(height: 250, color: shimmer),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(width: 180, height: 12, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
