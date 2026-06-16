import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/feed_provider.dart';
import '../../domain/entities/announcement.dart';
import '../widgets/announcement_card.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF0066FF);
const _kBg      = Color(0xFFF5F7FA);
const _kText1   = Color(0xFF0A0A1A);
const _kText2   = Color(0xFF6B7280);
const _kBorder  = Color(0xFFE5E7EB);

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with TickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  late final TabController _tabCtrl;

  static const _tabs = ['All', 'Academic', 'Events', 'Admin', 'General'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() {});
    });
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
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
    final t = _tabCtrl.index;
    if (t == 0) return all;
    final cat = _tabs[t].toLowerCase();
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
      backgroundColor: _kBg,
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        color: _kPrimary,
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            // ── App bar ─────────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.6,
              shadowColor: _kBorder,
              toolbarHeight: 58,
              title: Row(
                children: [
                  const Text(
                    'UNIFY',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _kPrimary,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _kPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      firstName.isNotEmpty ? _greeting + ', ' + firstName : _greeting,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _kPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded, color: _kText1, size: 22),
                  onPressed: () {},
                  tooltip: 'Search',
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: _kText1, size: 22),
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
                child: Container(height: 1, color: _kBorder),
              ),
            ),

            // ── Stories row ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _StoriesRow(avatarUrl: avatarUrl, firstName: firstName),
            ),

            // ── Post composer ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _ComposerBar(avatarUrl: avatarUrl, firstName: firstName),
            ),

            // ── Pinned tab bar ───────────────────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(controller: _tabCtrl, tabs: _tabs),
            ),

            // ── Feed content ─────────────────────────────────────────────────
            feedAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => const _ShimmerCard(),
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
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.wifi_off_rounded, size: 36, color: Color(0xFF9CA3AF)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Could not load feed',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _kText1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          e.toString(),
                          style: const TextStyle(fontSize: 13, color: _kText2),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () => ref.invalidate(feedProvider),
                          style: FilledButton.styleFrom(
                            backgroundColor: _kPrimary,
                            minimumSize: const Size(120, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: _kPrimary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.campaign_outlined, size: 36, color: _kPrimary),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nothing here yet',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _kText1),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Check back soon for campus updates.',
                            style: TextStyle(fontSize: 13, color: _kText2),
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
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2),
                            ),
                          ),
                        ),
                      )
                    else if (!feedState.hasMore)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 56),
                          child: Row(
                            children: [
                              const Expanded(child: Divider(color: _kBorder)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  "You're all caught up",
                                  style: const TextStyle(fontSize: 12, color: _kText2),
                                ),
                              ),
                              const Expanded(child: Divider(color: _kBorder)),
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
  final String? avatarUrl;
  final String firstName;
  const _StoriesRow({this.avatarUrl, required this.firstName});

  static const _placeholders = [
    _StoryData('Campus News', true,  null,              null,              Color(0xFF0066FF)),
    _StoryData('Kwame A.',    false, 'KA',              null,              Color(0xFF8B5CF6)),
    _StoryData('Ama B.',      false, 'AB',              null,              Color(0xFF10B981)),
    _StoryData('Kofi M.',     false, 'KM',              null,              Color(0xFFEF4444)),
    _StoryData('Efua T.',     false, 'ET',              null,              Color(0xFFF59E0B)),
    _StoryData('Yaw O.',      false, 'YO',              null,              Color(0xFF0066FF)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 0, 14),
      child: SizedBox(
        height: 84,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _MyStory(avatarUrl: avatarUrl, name: firstName),
            const SizedBox(width: 14),
            ..._placeholders.map((s) => Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _StoryBubble(data: s),
            )),
          ],
        ),
      ),
    );
  }
}

class _StoryData {
  final String name;
  final bool isUniversity;
  final String? initials;
  final String? imageUrl;
  final Color color;
  const _StoryData(this.name, this.isUniversity, this.initials, this.imageUrl, this.color);
}

class _MyStory extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  const _MyStory({this.avatarUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 54,
          height: 54,
          child: Stack(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _kBorder, width: 2),
                  color: const Color(0xFFF5F7FA),
                ),
                child: avatarUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: avatarUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _Initials(name.isNotEmpty ? name[0].toUpperCase() : 'U'),
                        ),
                      )
                    : _Initials(name.isNotEmpty ? name[0].toUpperCase() : 'U'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: _kPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: 2)],
                  ),
                  child: const Icon(Icons.add, size: 13, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text('Your Story', style: TextStyle(fontSize: 10, color: _kText2, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _StoryBubble extends StatelessWidget {
  final _StoryData data;
  const _StoryBubble({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: data.color,
            border: data.isUniversity
                ? null
                : Border.all(color: _kPrimary.withOpacity(0.3), width: 2),
            gradient: data.isUniversity
                ? LinearGradient(
                    colors: [data.color, data.color.withBlue(200)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: data.imageUrl != null
              ? ClipOval(child: CachedNetworkImage(imageUrl: data.imageUrl!, fit: BoxFit.cover))
              : data.isUniversity
                  ? const Icon(Icons.school_rounded, color: Colors.white, size: 24)
                  : Center(
                      child: Text(
                        data.initials ?? data.name[0],
                        style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white,
                        ),
                      ),
                    ),
        ),
        const SizedBox(height: 6),
        Text(
          data.name.split(' ').first,
          style: const TextStyle(fontSize: 10, color: _kText1, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _Initials extends StatelessWidget {
  final String letter;
  const _Initials(this.letter);

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      letter,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _kText1),
    ),
  );
}

// ── Post composer bar ─────────────────────────────────────────────────────────

class _ComposerBar extends StatelessWidget {
  final String? avatarUrl;
  final String firstName;
  const _ComposerBar({this.avatarUrl, required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: _kBorder),
                child: avatarUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: avatarUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _Initials(firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U'),
                        ),
                      )
                    : _Initials(firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Share an update, idea or question...',
                  style: const TextStyle(fontSize: 13, color: _kText2),
                ),
              ),
              const Icon(Icons.photo_camera_outlined, color: _kText2, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pinned tab bar ────────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController controller;
  final List<String> tabs;
  const _TabBarDelegate({required this.controller, required this.tabs});

  @override
  double get minExtent => 47;
  @override
  double get maxExtent => 47;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: TabBar(
              controller: controller,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: _kPrimary,
              unselectedLabelColor: _kText2,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              indicatorColor: _kPrimary,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              tabs: tabs.map((t) => Tab(text: t, height: 43)).toList(),
            ),
          ),
          Container(height: 1, color: _kBorder),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) => false;
}

// ── Shimmer loading card ──────────────────────────────────────────────────────

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF3F4F6),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(42, 42, radius: 21),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(130, 13),
                      const SizedBox(height: 6),
                      _box(80, 11),
                    ],
                  ),
                ),
                _box(60, 22, radius: 6),
              ],
            ),
            const SizedBox(height: 14),
            _box(double.infinity, 15),
            const SizedBox(height: 8),
            _box(double.infinity, 13),
            const SizedBox(height: 5),
            _box(200, 13),
            const SizedBox(height: 14),
            Row(
              children: [
                _box(56, 11),
                const SizedBox(width: 20),
                _box(64, 11),
                const SizedBox(width: 12),
                _box(52, 11),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(double w, double h, {double radius = 6}) => Container(
    width: w, height: h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
