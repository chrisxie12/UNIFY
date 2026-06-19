import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../system/presentation/widgets/system_announcement_banner.dart';
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

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  List<Announcement> _filtered(List<Announcement> all) {
    if (_tabIndex == 0) return all;
    final cat = _tabs[_tabIndex].toLowerCase();
    return all.where((a) => a.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedProvider);
    final user     = Supabase.instance.client.auth.currentUser;
    final fullName  = user?.userMetadata?['full_name'] as String? ?? '';
    final firstName = fullName.split(' ').first;
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    return Scaffold(
      backgroundColor: context.bg,
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
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
              toolbarHeight: 56,
              title: Row(
                children: [
                  Text(
                    'UNIFY',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: context.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      firstName.isNotEmpty ? '$_greeting, $firstName' : _greeting,
                      style: TextStyle(fontSize: 11, color: context.primary, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search_rounded, color: context.textPrimary, size: 22),
                  onPressed: () {},
                  tooltip: 'Search',
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications_outlined, color: context.textPrimary, size: 22),
                      onPressed: () => context.push('/notifications'),
                      tooltip: 'Notifications',
                    ),
                    Positioned(
                      top: 11,
                      right: 11,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
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
              child: _StoriesRow(avatarUrl: avatarUrl, firstName: firstName),
            ),

            // ── Post composer ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _ComposerBar(avatarUrl: avatarUrl, firstName: firstName),
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
                          e.toString(),
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
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => AnnouncementCard(
                            item: items[i],
                            onTap: () => ref.read(feedProvider.notifier).markRead(items[i].id),
                          ),
                          childCount: items.length,
                        ),
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

class _StoriesRow extends StatelessWidget {
  const _StoriesRow({this.avatarUrl, required this.firstName});

  final String? avatarUrl;
  final String firstName;

  static const _placeholders = [
    _StoryData('Campus News', null,         null, Color(0xFF2563EB), true),
    _StoryData('Kwame A.',    'KA',         null, Color(0xFF7C3AED), false),
    _StoryData('Ama B.',      'AB',         null, Color(0xFF10B981), false),
    _StoryData('Kofi M.',     'KM',         null, Color(0xFFEF4444), false),
    _StoryData('Efua T.',     'ET',         null, Color(0xFFF59E0B), false),
    _StoryData('Yaw O.',      'YO',         null, Color(0xFF2563EB), false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.appBarBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
      child: SizedBox(
        height: 82,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            StoryCircle(
              name: firstName.isNotEmpty ? firstName : 'You',
              imageUrl: avatarUrl,
              initials: firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
              isSelf: true,
              onTap: () {},
            ),
            const SizedBox(width: 14),
            ..._placeholders.map((s) => Padding(
              padding: const EdgeInsets.only(right: 14),
              child: StoryCircle(
                name: s.name,
                initials: s.initials,
                color: s.color,
                hasRing: !s.isUniversity,
                onTap: () {},
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _StoryData {
  final String name;
  final String? initials;
  final String? imageUrl;
  final Color color;
  final bool isUniversity;
  const _StoryData(this.name, this.initials, this.imageUrl, this.color, this.isUniversity);
}

// ── Post composer bar ─────────────────────────────────────────────────────────

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({this.avatarUrl, required this.firstName});

  final String? avatarUrl;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.appBarBg,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderCol, width: 1),
          ),
          child: Row(
            children: [
              _AvatarMini(avatarUrl: avatarUrl, letter: firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U'),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Share an update, idea or question…',
                  style: TextStyle(fontSize: 13, color: context.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.photo_camera_outlined, color: context.textSecondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarMini extends StatelessWidget {
  const _AvatarMini({this.avatarUrl, required this.letter});

  final String? avatarUrl;
  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.inputFill,
        border: Border.all(color: context.borderCol),
      ),
      child: avatarUrl != null
          ? ClipOval(child: CachedNetworkImage(imageUrl: avatarUrl!, fit: BoxFit.cover))
          : Center(
              child: Text(letter, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary)),
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
  double get minExtent => 54;
  @override
  double get maxExtent => 54;

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
