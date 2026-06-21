import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _primaryBlue  = Color(0xFF2563EB);
const _accentPurple = Color(0xFF7C3AED);
const _surfaceGrey  = Color(0xFFF8FAFC);
const _textDark     = Color(0xFF0F172A);
const _textGrey     = Color(0xFF64748B);
const _textLight    = Color(0xFF94A3B8);
const _divider      = Color(0xFFE2E8F0);

const _xs  = 4.0;
const _sm  = 8.0;
const _md  = 12.0;
const _lg  = 16.0;

const _radiusSm   = 8.0;
const _radiusLg   = 16.0;
const _radiusPill = 999.0;

const _storyAvatar    = 64.0;
const _postAvatar     = 40.0;
const _composerAvatar = 36.0;

// ── Typography helper ─────────────────────────────────────────────────────────
TextStyle _sg(double size, FontWeight weight, Color color, {double? ls, double? h}) =>
    GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: ls,
      height: h,
    );

// ── Data models ───────────────────────────────────────────────────────────────
class _Story {
  final String name;
  final String avatarUrl;
  final bool isYou;
  final bool hasStory;
  final bool viewed;
  const _Story({
    required this.name,
    required this.avatarUrl,
    this.isYou = false,
    this.hasStory = false,
    this.viewed = false,
  });
}

class _Post {
  final String id;
  final String author;
  final String handle;
  final String avatarUrl;
  final String category;
  final String time;
  final String body;
  final int views;
  final int likes;
  final int comments;
  final bool pinned;
  final bool isVerified;
  const _Post({
    required this.id,
    required this.author,
    required this.handle,
    required this.avatarUrl,
    required this.category,
    required this.time,
    required this.body,
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.pinned = false,
    this.isVerified = false,
  });
}

// ── Mock data ─────────────────────────────────────────────────────────────────
const _stories = <_Story>[
  _Story(name: 'Your Story', avatarUrl: 'https://i.pravatar.cc/150?u=you', isYou: true),
  _Story(name: 'Campus', avatarUrl: 'https://i.pravatar.cc/150?u=campus', hasStory: true),
  _Story(name: 'Kwame', avatarUrl: 'https://i.pravatar.cc/150?u=kwame', hasStory: true),
  _Story(name: 'Ama', avatarUrl: 'https://i.pravatar.cc/150?u=ama', hasStory: true, viewed: true),
  _Story(name: 'Kofi', avatarUrl: 'https://i.pravatar.cc/150?u=kofi', hasStory: true),
  _Story(name: 'Efua', avatarUrl: 'https://i.pravatar.cc/150?u=efua', hasStory: true, viewed: true),
  _Story(name: 'Nana', avatarUrl: 'https://i.pravatar.cc/150?u=nana', hasStory: true),
  _Story(name: 'Akos', avatarUrl: 'https://i.pravatar.cc/150?u=akos', hasStory: true, viewed: true),
];

const _posts = <_Post>[
  _Post(
    id: '1',
    author: 'Christian Twum Gyan',
    handle: '@chrisxie',
    avatarUrl: 'https://i.pravatar.cc/150?u=christian',
    category: 'General',
    time: '5d',
    body: 'Excited to announce that UNIFY is now live on campus! 🎉 Connect with fellow students, stay updated on campus events, and make the most of your university experience. Welcome aboard, GCTU family!',
    views: 156,
    likes: 42,
    comments: 8,
    pinned: true,
  ),
  _Post(
    id: '2',
    author: 'GCTU SRC',
    handle: '@gctu_src',
    avatarUrl: 'https://i.pravatar.cc/150?u=gctu_src',
    category: 'Admin',
    time: '2d',
    body: 'IMPORTANT: All students are reminded that the second semester registration deadline is this Friday. Visit the academic office or use the student portal to complete your registration. Late registration attracts a GH₵ 50 penalty.',
    views: 1204,
    likes: 203,
    comments: 47,
    isVerified: true,
  ),
  _Post(
    id: '3',
    author: 'Campus Events',
    handle: '@campus_events',
    avatarUrl: 'https://i.pravatar.cc/150?u=campus_events',
    category: 'Events',
    time: '1d',
    body: '🎭 GCTU Cultural Night is happening this Saturday at the Main Auditorium! Come experience the rich diversity of our campus culture. Performances, food, music, and more. Admission is FREE for all students with valid ID.',
    views: 3400,
    likes: 876,
    comments: 132,
  ),
  _Post(
    id: '4',
    author: 'Dr. Kofi Mensah',
    handle: '@dr_mensah',
    avatarUrl: 'https://i.pravatar.cc/150?u=dr_mensah',
    category: 'Academic',
    time: '8h',
    body: 'Office hours for this week have been moved to Thursday 2–4 PM due to faculty senate commitments. Students with project submissions or academic queries should plan accordingly.',
    views: 89,
    likes: 12,
    comments: 3,
  ),
];

const _filterTabs = ['All', 'Academic', 'Events', 'Admin', 'General'];

// ── Screen ────────────────────────────────────────────────────────────────────
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _activeTab = 0;
  int _navIndex  = 0;

  List<_Post> get _filteredPosts {
    if (_activeTab == 0) return _posts;
    final label = _filterTabs[_activeTab].toLowerCase();
    return _posts.where((p) => p.category.toLowerCase() == label).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPosts;

    return Scaffold(
      backgroundColor: _surfaceGrey,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 56,
            leading: Padding(
              padding: const EdgeInsets.only(left: _lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'UNIFY',
                  style: _sg(24, FontWeight.w900, _primaryBlue, ls: -0.5),
                ),
              ),
            ),
            leadingWidth: 100,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_box_outlined),
                color: _textDark,
                onPressed: () {},
                tooltip: 'New Story',
              ),
              _NavBadgeIcon(
                icon: Icons.favorite_border_rounded,
                color: _textDark,
                onTap: () {},
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined),
                color: _textDark,
                onPressed: () {},
                tooltip: 'Messages',
              ),
              const SizedBox(width: _xs),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: _divider),
            ),
          ),

          // ── Stories row ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(_lg, _md, 0, _md),
              child: SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _stories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: _md),
                  itemBuilder: (_, i) => _StoryItem(story: _stories[i]),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: _xs)),

          // ── Composer bar ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: _lg, vertical: _sm),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: _composerAvatar / 2,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=you'),
                  ),
                  const SizedBox(width: _md),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: _divider),
                          borderRadius: BorderRadius.circular(_radiusPill),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: _md),
                        child: Text(
                          "What's on your mind?",
                          style: _sg(14, FontWeight.w400, _textLight),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: _sm),
                  IconButton(
                    icon: const Icon(Icons.photo_library_outlined, color: _primaryBlue),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: _xs)),

          // ── Filter tabs (pinned) ─────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterTabsDelegate(
              tabs: _filterTabs,
              selectedIndex: _activeTab,
              onSelect: (i) => setState(() => _activeTab = i),
            ),
          ),

          // ── Pinned label ─────────────────────────────────────────────────────
          if (_activeTab == 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(_lg, _lg, _lg, _xs),
                child: Row(
                  children: [
                    const Icon(Icons.push_pin_rounded, size: 14, color: _textLight),
                    const SizedBox(width: _xs),
                    Text('PINNED', style: _sg(11, FontWeight.w700, _textLight, ls: 1.2)),
                  ],
                ),
              ),
            ),

          // ── Post list ────────────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final post = filtered[i];
                final showPinnedLabel = _activeTab == 0 && post.pinned;
                final isLast = i == filtered.length - 1;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!showPinnedLabel && i == 1 && _activeTab == 0)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(_lg, _lg, _lg, _xs),
                        child: Text('LATEST', style: _sg(11, FontWeight.w700, _textLight, ls: 1.2)),
                      ),
                    _PostCard(post: post),
                    if (isLast) _CaughtUpFooter(),
                  ],
                );
              },
              childCount: filtered.length,
            ),
          ),

          if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _primaryBlue.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.campaign_outlined, size: 32, color: _primaryBlue),
                    ),
                    const SizedBox(height: _lg),
                    Text('Nothing here yet', style: _sg(16, FontWeight.w700, _textDark)),
                    const SizedBox(height: _xs),
                    Text('Check back soon', style: _sg(13, FontWeight.w400, _textGrey)),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ── Story item ────────────────────────────────────────────────────────────────
class _StoryItem extends StatelessWidget {
  const _StoryItem({required this.story});
  final _Story story;

  @override
  Widget build(BuildContext context) {
    final ringColor = story.viewed ? _textLight : (story.isYou ? _primaryBlue : _accentPurple);
    final showRing  = story.hasStory || story.isYou;

    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: _storyAvatar + 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (showRing)
                  Container(
                    width: _storyAvatar + 4,
                    height: _storyAvatar + 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: story.viewed || story.isYou
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      border: (story.viewed || story.isYou)
                          ? Border.all(color: ringColor, width: 2)
                          : null,
                    ),
                  ),
                Container(
                  width: _storyAvatar,
                  height: _storyAvatar,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: DecorationImage(
                      image: NetworkImage(story.avatarUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (story.isYou)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _primaryBlue,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: _xs),
            Text(
              story.name,
              style: _sg(11, FontWeight.w500, _textDark),
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

// ── Post card ─────────────────────────────────────────────────────────────────
class _PostCard extends StatefulWidget {
  const _PostCard({required this.post});
  final _Post post;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liked = false;

  static const _categoryColors = <String, Color>{
    'General':  Color(0xFF64748B),
    'Admin':    Color(0xFFDC2626),
    'Events':   Color(0xFF7C3AED),
    'Academic': Color(0xFF2563EB),
  };

  @override
  Widget build(BuildContext context) {
    final post   = widget.post;
    final catCol = _categoryColors[post.category] ?? _primaryBlue;

    return Container(
      margin: const EdgeInsets.fromLTRB(_lg, 0, _lg, _md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(_lg, _lg, _lg, _sm),
            child: Row(
              children: [
                CircleAvatar(
                  radius: _postAvatar / 2,
                  backgroundImage: NetworkImage(post.avatarUrl),
                ),
                const SizedBox(width: _md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(post.author, style: _sg(14, FontWeight.w700, _textDark)),
                          if (post.isVerified) ...[
                            const SizedBox(width: _xs),
                            const Icon(Icons.verified_rounded, size: 14, color: _primaryBlue),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          Text(post.handle, style: _sg(12, FontWeight.w400, _textGrey)),
                          const SizedBox(width: _xs),
                          Text('·', style: _sg(12, FontWeight.w400, _textGrey)),
                          const SizedBox(width: _xs),
                          Text(post.time, style: _sg(12, FontWeight.w400, _textGrey)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: _sm, vertical: _xs),
                  decoration: BoxDecoration(
                    color: catCol.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(_radiusSm),
                  ),
                  child: Text(post.category, style: _sg(11, FontWeight.w600, catCol)),
                ),
                const SizedBox(width: _xs),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: _textGrey, size: 20),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(_lg, 0, _lg, _md),
            child: Text(post.body, style: _sg(14, FontWeight.w400, _textDark, h: 1.5)),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.fromLTRB(_lg, 0, _lg, _sm),
            child: Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 13, color: _textLight),
                const SizedBox(width: _xs),
                Text(_fmtNum(post.views), style: _sg(12, FontWeight.w400, _textLight)),
                if (post.likes > 0) ...[
                  const SizedBox(width: _md),
                  const Icon(Icons.favorite_rounded, size: 13, color: Color(0xFFEF4444)),
                  const SizedBox(width: _xs),
                  Text(_fmtNum(post.likes), style: _sg(12, FontWeight.w400, _textLight)),
                ],
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: _divider),

          // Action row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _sm, vertical: _xs),
            child: Row(
              children: [
                _ActionBtn(
                  icon: _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  label: _fmtNum(post.likes + (_liked ? 1 : 0)),
                  color: _liked ? const Color(0xFFEF4444) : _textGrey,
                  onTap: () => setState(() => _liked = !_liked),
                ),
                _ActionBtn(
                  icon: Icons.mode_comment_outlined,
                  label: _fmtNum(post.comments),
                  color: _textGrey,
                  onTap: () {},
                ),
                _ActionBtn(
                  icon: Icons.repeat_rounded,
                  label: 'Reshare',
                  color: _textGrey,
                  onTap: () {},
                ),
                const Spacer(),
                _ActionBtn(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: _textGrey,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _sm, vertical: _sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: _xs),
            Text(label, style: _sg(12, FontWeight.w500, color)),
          ],
        ),
      ),
    );
  }
}

// ── Filter tabs (pinned header delegate) ──────────────────────────────────────
class _FilterTabsDelegate extends SliverPersistentHeaderDelegate {
  const _FilterTabsDelegate({
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
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: _lg),
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: _sm),
              itemBuilder: (_, i) {
                final selected = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: _md),
                    decoration: BoxDecoration(
                      color: selected ? _primaryBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(_radiusPill),
                    ),
                    child: Text(
                      tabs[i],
                      style: _sg(13, FontWeight.w600, selected ? Colors.white : _textGrey),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(height: 1, color: _divider),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _FilterTabsDelegate old) =>
      old.selectedIndex != selectedIndex;
}

// ── "All caught up" footer ────────────────────────────────────────────────────
class _CaughtUpFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_lg, _lg * 2, _lg, _lg),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _primaryBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded, size: 28, color: _primaryBlue),
          ),
          const SizedBox(height: _md),
          Text("You're all caught up", style: _sg(14, FontWeight.w700, _textDark)),
          const SizedBox(height: _xs),
          Text('Pull down to refresh for new updates', style: _sg(12, FontWeight.w400, _textGrey)),
        ],
      ),
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Feed'),
    _NavItem(icon: Icons.explore_outlined, label: 'Hubs'),
    _NavItem(icon: Icons.send_rounded, label: 'Messages', badge: '3'),
    _NavItem(icon: Icons.event_outlined, label: 'Events'),
    _NavItem(icon: Icons.menu_book_outlined, label: 'Study'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _divider)),
      ),
      padding: EdgeInsets.only(
        top: _sm,
        bottom: MediaQuery.of(context).padding.bottom + _sm,
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final item     = _items[i];
          final selected = i == currentIndex;
          final color    = selected ? _primaryBlue : _textGrey;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(item.icon, color: color, size: 24),
                      if (item.badge != null)
                        Positioned(
                          top: -4,
                          right: -8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(_radiusPill),
                            ),
                            child: Text(
                              item.badge!,
                              style: _sg(9, FontWeight.w700, Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(item.label, style: _sg(10, FontWeight.w500, color)),
                  if (selected)
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: _primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String? badge;
  const _NavItem({required this.icon, required this.label, this.badge});
}

// ── Notification badge icon (app bar) ─────────────────────────────────────────
class _NavBadgeIcon extends StatelessWidget {
  const _NavBadgeIcon({required this.icon, required this.color, required this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        IconButton(icon: Icon(icon, color: color), onPressed: onTap),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
String _fmtNum(int n) {
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  return '$n';
}
