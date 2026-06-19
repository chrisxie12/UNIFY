import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_item.dart';
import '../widgets/chat_list/chat_list_item.dart';
import '../widgets/chat_list/story_row.dart';
import '../widgets/chat_list/search_bar.dart';
import '../widgets/chat_list/filter_tabs.dart';
import '../widgets/chat_list/bottom_nav.dart';
import '../widgets/chat_list/fab_button.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────

const _primary  = Color(0xFF2563EB);
const _textDark = Color(0xFF0F172A);
const _divider  = Color(0xFFE2E8F0);
const _surface  = Color(0xFFF8FAFC);

// ── Chat List Screen ──────────────────────────────────────────────────────────

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ScrollController _scroll = ScrollController();

  int _activeTab  = 0;
  int _navIndex   = 0;
  bool _showIcons = true;
  double _lastOffset = 0;

  // Counts for the bottom nav badge (sum of all unread in mock data)
  int get _totalUnread =>
      mockChats.fold(0, (sum, c) => sum + c.unreadCount);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scroll.offset.clamp(0.0, double.infinity);
    final scrollingDown = offset > _lastOffset;
    _lastOffset = offset;

    if (scrollingDown && offset > 60 && _showIcons) {
      setState(() => _showIcons = false);
    } else if (!scrollingDown && !_showIcons) {
      setState(() => _showIcons = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          // ── Main scrollable content ─────────────────────────────────────
          CustomScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Animated app bar
              _AnimatedAppBar(showIcons: _showIcons),

              // White surface for stories + search
              SliverToBoxAdapter(
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      const ChatStoryRow(),
                      const Divider(height: 0.5, thickness: 0.5, color: _divider),
                      const ChatSearchBar(),
                    ],
                  ),
                ),
              ),

              // Pinned filter tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterDelegate(
                  activeIndex: _activeTab,
                  onSelect: (i) => setState(() => _activeTab = i),
                ),
              ),

              // Archived chats row
              SliverToBoxAdapter(
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: const ArchivedChatsRow(),
                ),
              ),

              // Chat list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ColoredBox(
                    color: Colors.white,
                    child: ChatListItem(chat: mockChats[index]),
                  ),
                  childCount: mockChats.length,
                ),
              ),

              // Bottom padding so content isn't hidden behind nav
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),

          // ── Floating bottom navigation ──────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ChatBottomNav(
              activeIndex: _navIndex,
              onSelect: (i) => setState(() => _navIndex = i),
              unreadCount: _totalUnread,
            ),
          ),

          // ── Floating action button ──────────────────────────────────────
          Positioned(
            bottom: 88,
            right: 20,
            child: ChatFab(onTap: () {}),
          ),
        ],
      ),
    );
  }
}

// ── Animated SliverAppBar ─────────────────────────────────────────────────────
//
// The "UNIFY" title and avatar are always visible (pinned: true).
// The camera icon fades + slides out when the user scrolls down past 60px,
// and fades + slides back in when they scroll up.

class _AnimatedAppBar extends StatelessWidget {
  const _AnimatedAppBar({required this.showIcons});

  final bool showIcons;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      toolbarHeight: 60,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User avatar with gradient story ring
            const _HeaderAvatar(hasUnviewedStory: true),
            const SizedBox(width: 10),
            // UNIFY brand text
            Text(
              'UNIFY',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _primary,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            // Search icon — always visible
            const _HeaderIconBtn(icon: Icons.search_rounded, tooltip: 'Search'),
            // Camera icon — hides when scrolled down
            ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                alignment: Alignment.centerRight,
                widthFactor: showIcons ? 1.0 : 0.0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: showIcons ? 1.0 : 0.0,
                  child: const _HeaderIconBtn(
                    icon: Icons.camera_alt_outlined,
                    tooltip: 'New Story',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: _divider),
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.hasUnviewedStory});

  final bool hasUnviewedStory;

  static const _gradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF2563EB),
      ),
      child: Center(
        child: Text(
          'ME',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );

    if (hasUnviewedStory) {
      return Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: _gradient,
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(1.5),
          child: inner,
        ),
      );
    }

    return inner;
  }
}

class _HeaderIconBtn extends StatelessWidget {
  const _HeaderIconBtn({required this.icon, required this.tooltip});

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 22, color: _textDark),
        onPressed: () {},
        splashRadius: 22,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }
}

// ── Filter tabs persistent header delegate ────────────────────────────────────

class _FilterDelegate extends SliverPersistentHeaderDelegate {
  const _FilterDelegate({
    required this.activeIndex,
    required this.onSelect,
  });

  final int activeIndex;
  final ValueChanged<int> onSelect;

  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 50;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _divider, width: 0.5)),
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ChatFilterTabs(
        activeIndex: activeIndex,
        onSelect: onSelect,
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterDelegate old) => old.activeIndex != activeIndex;
}
