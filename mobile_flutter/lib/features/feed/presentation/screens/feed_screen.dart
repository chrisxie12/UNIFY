import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/feed_provider.dart';
import '../../domain/entities/announcement.dart';
import '../widgets/announcement_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../system/presentation/widgets/system_announcement_banner.dart';
import 'package:unify/core/design_system/tokens.dart';
import 'package:unify/core/design_system/typography.dart';
import 'package:unify/core/design_system/components.dart';

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
      backgroundColor: context.bg,
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        color: context.primary,
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            // ── App bar ─────────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: context.appBarBg,
              surfaceTintColor: context.appBarBg,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.6,
              shadowColor: context.borderCol,
              toolbarHeight: 58,
              title: Row(
                children: [
                  Text(
                    'UNIFY',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: context.primary,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(width: USpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      firstName.isNotEmpty ? '$_greeting, $firstName' : _greeting,
                      style: UText.tiny.copyWith(color: context.primary),
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
                const SizedBox(width: USpacing.xs),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: context.borderCol),
              ),
            ),

            // ── System announcements ────────────────────────────────────────
            const SliverToBoxAdapter(child: SystemAnnouncementBanner()),

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
                            color: context.cardBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.wifi_off_rounded, size: 36, color: Color(0xFF9CA3AF)),
                        ),
                        const SizedBox(height: USpacing.base),
                        Text(
                          'Could not load feed',
                          style: UText.h4.copyWith(color: context.textPrimary),
                        ),
                        const SizedBox(height: USpacing.sm),
                        Text(
                          e.toString(),
                          style: UText.bodyXS.copyWith(color: context.textSecondary),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: USpacing.lg),
                        FilledButton(
                          onPressed: () => ref.invalidate(feedProvider),
                          style: FilledButton.styleFrom(
                            backgroundColor: context.primary,
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
                              color: context.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.campaign_outlined, size: 36, color: context.primary),
                          ),
                          const SizedBox(height: USpacing.base),
                          Text(
                            'Nothing here yet',
                            style: UText.h4.copyWith(color: context.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Check back soon for campus updates.',
                            style: UText.bodyXS.copyWith(color: context.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverMainAxisGroup(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(top: USpacing.sm),
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
                          padding: const EdgeInsets.symmetric(vertical: USpacing.lg),
                          child: Center(
                            child: SizedBox(
                              width: USpacing.xl,
                              height: USpacing.xl,
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
                                width: 64, height: 64,
                                decoration: BoxDecoration(
                                  color: context.bg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check_circle_outline_rounded, size: 32, color: context.textSecondary),
                              ),
                              const SizedBox(height: USpacing.md),
                              Text(
                                "You're all caught up",
                                style: UText.labelL.copyWith(color: context.textSecondary),
                              ),
                              const SizedBox(height: USpacing.xs),
                              Text(
                                'Pull down to refresh for new updates',
                                style: UText.caption.copyWith(color: context.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SliverToBoxAdapter(child: SizedBox(height: USpacing.x2)),
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
    _StoryData('Campus News', true,  null,              null,              AppColors.primary),
    _StoryData('Kwame A.',    false, 'KA',              null,              Color(0xFF8B5CF6)),
    _StoryData('Ama B.',      false, 'AB',              null,              Color(0xFF10B981)),
    _StoryData('Kofi M.',     false, 'KM',              null,              Color(0xFFEF4444)),
    _StoryData('Efua T.',     false, 'ET',              null,              Color(0xFFF59E0B)),
    _StoryData('Yaw O.',      false, 'YO',              null,              AppColors.primary),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.appBarBg,
      padding: const EdgeInsets.fromLTRB(USpacing.base, 14, 0, 14),
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
                  border: Border.all(color: context.borderCol, width: 2),
                  color: context.bg,
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
                  decoration: BoxDecoration(
                    color: context.primary,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: context.cardBg, blurRadius: 0, spreadRadius: 2)],
                  ),
                  child: const Icon(Icons.add, size: 13, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text('Your Story', style: UText.tiny.copyWith(color: context.textSecondary)),
      ],
    );
  }
}

class _StoryBubble extends StatelessWidget {
  final _StoryData data;
  const _StoryBubble({required this.data});

  static const _ring = LinearGradient(
    colors: [AppColors.primary, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    Widget inner = ClipOval(
      child: Container(
        color: data.color,
        child: data.imageUrl != null
            ? CachedNetworkImage(imageUrl: data.imageUrl!, fit: BoxFit.cover)
            : data.isUniversity
                ? const Icon(Icons.school_rounded, color: Colors.white, size: 22)
                : Center(
                    child: Text(
                      data.initials ?? data.name[0],
                      style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
                      ),
                    ),
                  ),
      ),
    );

    Widget avatar;
    if (data.isUniversity) {
      avatar = Container(
        width: 54, height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [data.color, data.color.withBlue(200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: data.imageUrl != null
            ? ClipOval(child: CachedNetworkImage(imageUrl: data.imageUrl!, fit: BoxFit.cover))
            : const Icon(Icons.school_rounded, color: Colors.white, size: 24),
      );
    } else {
      avatar = Container(
        width: 54, height: 54,
        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: _ring),
        padding: const EdgeInsets.all(2.5),
        child: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle, color: context.cardBg),
          padding: const EdgeInsets.all(1.5),
          child: inner,
        ),
      );
    }

    return Column(
      children: [
        avatar,
        const SizedBox(height: 6),
        Text(
          data.name.split(' ').first,
          style: UText.tiny.copyWith(color: context.textPrimary),
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
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: context.textPrimary),
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
      color: context.appBarBg,
      padding: const EdgeInsets.fromLTRB(USpacing.base, 0, USpacing.base, 14),
      child: Material(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.07),
        borderRadius: URadius.baseAll,
        color: context.cardBg,
        child: InkWell(
          onTap: () {},
          borderRadius: URadius.baseAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: context.cardBg),
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
                const SizedBox(width: USpacing.md),
                Expanded(
                  child: Text(
                    'Share an update, idea or question…',
                    style: UText.bodyXS.copyWith(color: context.textSecondary),
                  ),
                ),
                const SizedBox(width: USpacing.sm),
                Icon(Icons.photo_camera_outlined, color: context.textSecondary, size: 20),
              ],
            ),
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
      color: context.appBarBg,
      child: Column(
        children: [
          Expanded(
            child: TabBar(
              controller: controller,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: context.primary,
              unselectedLabelColor: context.textSecondary,
              labelStyle: UText.labelS,
              unselectedLabelStyle: UText.bodyXS,
              indicator: BoxDecoration(
                color: context.primary.withValues(alpha: 0.10),
                borderRadius: URadius.lgAll,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              tabs: tabs.map((t) => Tab(text: t, height: 43)).toList(),
            ),
          ),
          Container(height: 1, color: context.borderCol),
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
    return const UShimmerCard();
  }
}
