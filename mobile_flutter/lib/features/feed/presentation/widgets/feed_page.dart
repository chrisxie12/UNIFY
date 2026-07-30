import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../snapshots/data/models/snapshot_models.dart';
import '../../../snapshots/presentation/providers/snapshot_provider.dart';
import '../../domain/entities/announcement.dart';
import '../providers/feed_provider.dart';
import 'feed_card.dart';
import '../../../../core/widgets/app_error_widget.dart';

// ── FeedPage ────────────────────────────────────────────────────────────────

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage>
    with SingleTickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  late AnimationController _greetCtrl;
  late Animation<Offset> _greetSlide;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _greetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _greetSlide = Tween<Offset>(
      begin: const Offset(0, 20), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _greetCtrl, curve: Curves.easeOutBack));
    _greetCtrl.forward();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _greetCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  List<Widget> _buildMixedFeed(List<Announcement> posts, ColorScheme cs) {
    final items = <Widget>[];
    for (int i = 0; i < posts.length; i++) {
      items.add(_AnimatedFeedItem(index: i, child: FeedCard(post: posts[i])));
      if (i > 0 && i % 4 == 0) {
        items.add(_SmartSection(key: ValueKey('smart_$i'), cs: cs, seed: i));
      }
      if (i > 0 && i % 7 == 0) {
        items.add(_CampusWidgetsSection(key: ValueKey('campus_$i'), cs: cs, seed: i));
      }
    }
    return items;
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
      backgroundColor: cs.surfaceContainerLow,
      body: RefreshIndicator(
        color: cs.primary,
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _FeedAppBar(
              avatarUrl: avatarUrl, fullName: fullName, cs: cs, greetSlide: _greetSlide,
            ),
            _StorySection(storyGroupsAsync: storyGroupsAsync, cs: cs, avatarUrl: avatarUrl, fullName: fullName),
            _CampusHighlights(cs: cs),
            feedAsync.when(
              loading: () => const SliverToBoxAdapter(child: _SkeletonFeed()),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: true,
                child: AppErrorWidget(e, onRetry: () => ref.invalidate(feedProvider)),
              ),
              data: (feedState) {
                if (feedState.items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: true,
                    child: _EmptyFeed(onAction: () => context.push('/announcement/create')),
                  );
                }
                return SliverList(
                  delegate: SliverChildListDelegate(
                    _buildMixedFeed(feedState.items, cs),
                  ),
                );
              },
            ),
            if (feedAsync.valueOrNull?.isLoadingMore == true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ── Animated feed item (fade + slide) ───────────────────────────────────────

class _AnimatedFeedItem extends StatelessWidget {
  final int index;
  final Widget child;
  const _AnimatedFeedItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index % 5) * 60),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

// ── Smart Section (recommended content between posts) ───────────────────────

class _SmartSection extends StatelessWidget {
  final ColorScheme cs;
  final int seed;
  const _SmartSection({super.key, required this.cs, required this.seed});

  static const _sections = [
    _SmartData('Students You May Know', 'From your department', PhosphorIconsBold.usersThree, 0xFF2563EB),
    _SmartData('Trending Clubs', 'Join the conversation', PhosphorIconsBold.fire, 0xFFEF4444),
    _SmartData('Upcoming Events', 'This week on campus', PhosphorIconsBold.calendar, 0xFFF59E0B),
    _SmartData('Popular Discussions', 'Trending now', PhosphorIconsBold.chatCircleDots, 0xFF06B6D4),
    _SmartData('Study Groups Near You', 'Find study partners', PhosphorIconsBold.books, 0xFF22C55E),
  ];

  @override
  Widget build(BuildContext context) {
    final section = _sections[seed % _sections.length];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Color(section.color).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(section.icon, size: 16, color: Color(section.color)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.title, style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface,
                  )),
                  Text(section.subtitle, style: GoogleFonts.inter(
                    fontSize: 12, color: cs.onSurfaceVariant,
                  )),
                ],
              ),
              const Spacer(),
              Text('See all', style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w500, color: cs.primary,
              )),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (_, i) => Container(
                width: 80,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(section.color).withValues(alpha: 0.12),
                      child: Icon(PhosphorIconsBold.user, size: 16, color: Color(section.color)),
                    ),
                    const SizedBox(height: 6),
                    Text('User ${i + 1}', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w500, color: cs.onSurface,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartData {
  final String title;
  final String subtitle;
  final IconData icon;
  final int color;
  const _SmartData(this.title, this.subtitle, this.icon, this.color);
}

// ── Campus Widgets Section ──────────────────────────────────────────────────

class _CampusWidgetsSection extends StatelessWidget {
  final ColorScheme cs;
  final int seed;
  const _CampusWidgetsSection({super.key, required this.cs, required this.seed});

  static final _widgets = [
    _CampusWidgetData('Today\'s Classes', PhosphorIconsBold.bookOpen, 0xFF2563EB),
    _CampusWidgetData('Exam Countdown', PhosphorIconsBold.alarm, 0xFFEF4444),
    _CampusWidgetData('Cafeteria Specials', PhosphorIconsBold.coffee, 0xFFF59E0B),
    _CampusWidgetData('Library Hours', PhosphorIconsBold.clock, 0xFF06B6D4),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('Campus Tools', style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface,
            )),
          ),
          Row(
            children: _widgets.map((w) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Color(w.color).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(w.icon, size: 18, color: Color(w.color)),
                      ),
                      const SizedBox(height: 6),
                      Text(w.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w500, color: cs.onSurface,
                      )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CampusWidgetData {
  final String title;
  final IconData icon;
  final int color;
  const _CampusWidgetData(this.title, this.icon, this.color);
}

// ── Feed AppBar ─────────────────────────────────────────────────────────────

class _FeedAppBar extends StatelessWidget {
  final String? avatarUrl;
  final String fullName;
  final ColorScheme cs;
  final Animation<Offset> greetSlide;

  const _FeedAppBar({
    required this.avatarUrl,
    required this.fullName,
    required this.cs,
    required this.greetSlide,
  });

  @override
  Widget build(BuildContext context) {
    // Profile avatar color
    final avatarColors = [
      const Color(0xFFE53935), const Color(0xFFD81B60), const Color(0xFF8E24AA),
      const Color(0xFF5E35B1), const Color(0xFF3949AB), const Color(0xFF1E88E5),
      const Color(0xFF039BE5), const Color(0xFF00ACC1), const Color(0xFF00897B),
      const Color(0xFF43A047), const Color(0xFF7CB342),
    ];
    final hash = fullName.isEmpty ? 0 : fullName.codeUnits.fold(0, (a, b) => a + b);
    final avatarBg = avatarColors[hash % avatarColors.length];

    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: false,
      stretch: false,
      toolbarHeight: 64,
      backgroundColor: cs.surface.withValues(alpha: 0.75),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.85),
          border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text('U', style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w800, color: cs.onPrimary,
                )),
              ),
            ),
            const SizedBox(width: 6),
            Text('UNIFY', style: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface,
              letterSpacing: -0.3,
            )),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(PhosphorIconsBold.bell, size: 22, color: cs.onSurfaceVariant),
              Positioned(
                right: -2, top: -2,
                child: Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(color: const Color(0xFFEF4444), shape: BoxShape.circle),
                  child: Center(child: Text('3', style: TextStyle(
                    color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700,
                  ))),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(PhosphorIconsBold.magnifyingGlass, size: 22, color: cs.onSurfaceVariant),
          onPressed: () => context.push('/search'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: avatarBg,
              backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Story Section ───────────────────────────────────────────────────────────

class _StorySection extends StatelessWidget {
  final AsyncValue<List<SnapshotGroup>> storyGroupsAsync;
  final ColorScheme cs;
  final String? avatarUrl;
  final String fullName;

  const _StorySection({
    required this.storyGroupsAsync,
    required this.cs,
    this.avatarUrl,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    return storyGroupsAsync.when(
      loading: () => _storyPlaceholder(cs),
      error: (_, __) => _storyPlaceholder(cs),
      data: (groups) => SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: groups.isEmpty ? 1 : groups.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cs.surfaceContainerHighest,
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: cs.surfaceContainerHighest,
                              backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl!) : null,
                              child: avatarUrl == null
                                  ? Icon(PhosphorIconsBold.user, size: 24, color: cs.onSurfaceVariant)
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 0, bottom: 0,
                            child: Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cs.primary,
                                border: Border.all(color: cs.surface, width: 2),
                              ),
                              child: Icon(PhosphorIconsBold.plus, size: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Your Story', style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant,
                      )),
                    ],
                  ),
                ),
              );
            }
            final group = groups[index - 1];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: group.hasUnseen
                            ? LinearGradient(colors: [cs.primary, cs.tertiary], begin: Alignment.topLeft, end: Alignment.bottomRight)
                            : null,
                        border: !group.hasUnseen ? Border.all(color: cs.outlineVariant, width: 1.5) : null,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: cs.surface),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: cs.surfaceContainerHighest,
                          backgroundImage: group.authorAvatar != null ? CachedNetworkImageProvider(group.authorAvatar!) : null,
                          child: group.authorAvatar == null
                              ? Text(group.initials, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant))
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 60,
                      child: Text(
                        group.authorName ?? 'User',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant),
                        maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _storyPlaceholder(ColorScheme cs) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 1,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.surfaceContainerHighest,
                  border: Border.all(color: cs.outlineVariant, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.transparent,
                  child: Icon(PhosphorIconsBold.plus, size: 24, color: cs.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 4),
              Text('Add Story', style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Campus Highlights ───────────────────────────────────────────────────────

class _CampusHighlights extends StatelessWidget {
  final ColorScheme cs;
  const _CampusHighlights({required this.cs});

  static final _highlights = [
    _HighlightData('Upcoming Events', 'Stay in the loop', PhosphorIconsBold.calendar, 0xFF2563EB),
    _HighlightData('Hackathons', 'Build something great', PhosphorIconsBold.code, 0xFF06B6D4),
    _HighlightData('Sports', 'Game day schedules', PhosphorIconsBold.tShirt, 0xFF22C55E),
    _HighlightData('Scholarships', 'Apply now', PhosphorIconsBold.student, 0xFFF59E0B),
    _HighlightData('Elections', 'Your voice matters', PhosphorIconsBold.chartPieSlice, 0xFFEF4444),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        itemCount: _highlights.length,
        itemBuilder: (context, index) {
          final h = _highlights[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(h.color).withValues(alpha: 0.12),
                  Color(h.color).withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(h.color).withValues(alpha: 0.15)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Color(h.color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(h.icon, size: 16, color: Color(h.color)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.title, style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface,
                          )),
                          const SizedBox(height: 1),
                          Text(h.subtitle, style: GoogleFonts.inter(
                            fontSize: 10, color: cs.onSurfaceVariant,
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HighlightData {
  final String title;
  final String subtitle;
  final IconData icon;
  final int color;
  const _HighlightData(this.title, this.subtitle, this.icon, this.color);
}

// ── Skeleton Feed (Shimmer Loading) ─────────────────────────────────────────

class _SkeletonFeed extends StatelessWidget {
  const _SkeletonFeed();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: List.generate(3, (_) => _shimmerCard(cs)),
    );
  }

  Widget _shimmerCard(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerBox(cs, 40, 40, 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(cs, 120, 14, 4),
                  const SizedBox(height: 6),
                  _shimmerBox(cs, 80, 10, 4),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _shimmerBox(cs, double.infinity, 14, 6),
          const SizedBox(height: 8),
          _shimmerBox(cs, double.infinity, 14, 6),
          const SizedBox(height: 8),
          _shimmerBox(cs, 160, 14, 6),
          const SizedBox(height: 16),
          Row(
            children: [
              _shimmerBox(cs, 44, 44, 8),
              const SizedBox(width: 8),
              _shimmerBox(cs, 44, 44, 8),
              const SizedBox(width: 8),
              _shimmerBox(cs, 44, 44, 8),
              const Spacer(),
              _shimmerBox(cs, 44, 44, 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox(ColorScheme cs, double w, double h, double radius) {
    return Container(
      width: w.isFinite ? w : null,
      height: h,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Empty Feed ──────────────────────────────────────────────────────────────

class _EmptyFeed extends StatelessWidget {
  final VoidCallback onAction;
  const _EmptyFeed({required this.onAction});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(PhosphorIconsBold.megaphone, size: 36, color: cs.primary),
            ),
            const SizedBox(height: 20),
            Text('Nothing here yet', style: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface,
            )),
            const SizedBox(height: 8),
            Text(
              'Follow clubs, students, or departments\nto personalize your feed.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Discover Campus', style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w600,
              )),
            ),
          ],
        ),
      ),
    );
  }
}