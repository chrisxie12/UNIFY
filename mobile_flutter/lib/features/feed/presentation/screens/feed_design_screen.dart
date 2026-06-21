import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/unify_post.dart';
import '../providers/unify_feed_providers.dart';

class FeedDesignScreen extends StatefulWidget {
  const FeedDesignScreen({super.key});

  @override
  State<FeedDesignScreen> createState() => _FeedDesignScreenState();
}

class _FeedDesignScreenState extends State<FeedDesignScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _StoriesTrain()),
                  SliverToBoxAdapter(child: _UpdateInput()),
                  SliverToBoxAdapter(child: const DynamicFeedList()),
                  SliverToBoxAdapter(child: _FeedFooter()),
                ],
              ),
            ),
            _BottomTabBar(),
          ],
        ),
      ),
    );
  }
}

// ── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'Junify',
            style: GoogleFonts.greatVibes(
              fontSize: 30,
              color: const Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(Icons.favorite_border, color: const Color(0xFF1F2937), size: 26),
          const SizedBox(width: 18),
          SizedBox(
            width: 26,
            height: 26,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, color: const Color(0xFF1F2937), size: 26),
                Transform.rotate(
                  angle: 0.1,
                  child: Icon(Icons.flash_on, color: const Color(0xFF1F2937), size: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stories Train ────────────────────────────────────────────────────────────

class _StoriesTrain extends StatelessWidget {
  final _stories = [
    _StoryData('Your Story', 'U', true),
    _StoryData('Campus', 'C', false),
    _StoryData('Kwame', 'KA', false),
    _StoryData('Ama', 'AB', false),
    _StoryData('Kofi', 'KM', false),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 12, top: 12),
        itemCount: _stories.length,
        itemBuilder: (_, i) {
          final s = _stories[i];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: s.isSelf
                ? _YourStoryCircle()
                : _StoryRing(child: _AvatarCircle(initials: s.initials!)),
          );
        },
      ),
    );
  }
}

class _StoryData {
  final String name;
  final String? initials;
  final bool isSelf;
  const _StoryData(this.name, this.initials, this.isSelf);
}

class _YourStoryCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD1D5DB),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: Center(
                child: Text(
                  'U',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: -1,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF3730A3),
                    ),
                    child: const Icon(Icons.add, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 62,
          child: Text(
            'Your Story',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String initials;
  const _AvatarCircle({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFD1D5DB),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _StoryRing extends StatelessWidget {
  final Widget child;
  const _StoryRing({required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF3730A3), Color(0xFF8B5CF6), Color(0xFFEC4899)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(2),
            child: child,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 62,
          child: Text(
            _labelForChild(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  String _labelForChild() {
    if (child is _AvatarCircle) {
      return (child as _AvatarCircle).initials;
    }
    return '';
  }
}

// ── Global Update Input ──────────────────────────────────────────────────────

class _UpdateInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD1D5DB),
              ),
              child: Center(
                child: Text(
                  'U',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Share an update, idea or question...',
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
              ),
            ),
            Icon(Icons.camera_alt_outlined, size: 20, color: const Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

// ── Dynamic Feed List ────────────────────────────────────────────────────────

class DynamicFeedList extends ConsumerWidget {
  const DynamicFeedList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(unifyFeedStreamProvider);

    return feedAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(child: Text('No updates on campus yet!')),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (_, i) => DynamicFeedPostCard(post: posts[i]),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF3730A3))),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text('Failed loading feed updates: $err')),
      ),
    );
  }
}

// ── Dynamic Feed Post Card ───────────────────────────────────────────────────

class DynamicFeedPostCard extends StatelessWidget {
  final UnifyPost post;
  const DynamicFeedPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Post Header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF3730A3),
                    backgroundImage: post.authorAvatarUrl != null
                        ? NetworkImage(post.authorAvatarUrl!)
                        : null,
                    child: post.authorAvatarUrl == null
                        ? const Text('🎓', style: TextStyle(fontSize: 14))
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        post.timestampText,
                        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.more_vert, color: Color(0xFF1F2937)),
            ],
          ),
        ),

        // ── Media Canvas (4:5) ──────────────────────────────────────────
        AspectRatio(
          aspectRatio: 4 / 5,
          child: Container(
            color: const Color(0xFFBAE6FD),
            child: Stack(
              children: [
                // Default campus vector landscape
                _DefaultMediaCanvas(),
                // Module tag badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.moduleTag,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (post.isPinned)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.push_pin, size: 10, color: Colors.white),
                          SizedBox(width: 4),
                          Text('pinned', style: TextStyle(fontSize: 11, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── Action Icons ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Row(
            children: [
              Icon(Icons.favorite_border, color: const Color(0xFF1F2937), size: 26),
              const SizedBox(width: 16),
              Icon(Icons.mode_comment_outlined, color: const Color(0xFF1F2937), size: 24),
              const SizedBox(width: 16),
              Transform.rotate(
                angle: -0.3,
                child: Icon(Icons.send_outlined, color: const Color(0xFF1F2937), size: 24),
              ),
              const Spacer(),
              Icon(Icons.bookmark_border, color: const Color(0xFF1F2937), size: 26),
            ],
          ),
        ),

        // ── Metrics + Caption ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${post.likeCount} likes',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF1F2937),
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: '${post.authorName} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: post.content),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Default Media Canvas ─────────────────────────────────────────────────────

class _DefaultMediaCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sky gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF7EC8E3), Color(0xFFB8E1F0), Color(0xFFE8F5E9)],
            ),
          ),
        ),
        // Sun
        Positioned(
          top: 16, right: 24,
          child: Container(
            width: 48, height: 48,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x50FFF176)),
          ),
        ),
        // Brick building
        Positioned(
          bottom: 90, left: 0, right: 0,
          child: Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFFD2691E), Color(0xFF8B4513)],
              ),
            ),
          ),
        ),
        // Clock tower
        Positioned(
          bottom: 90, left: 0, right: 0,
          child: Column(
            children: [
              Container(
                width: 48, height: 80,
                decoration: BoxDecoration(color: const Color(0xFFC4A882), borderRadius: BorderRadius.circular(4)),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: const Color(0xFFF5F5DC),
                        border: Border.all(color: const Color(0xFF8B7355), width: 2),
                      ),
                      child: const Center(child: Text('|', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF8B7355)))),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32, height: 36,
                      decoration: const BoxDecoration(color: Color(0xFF8B7355), borderRadius: BorderRadius.vertical(bottom: Radius.circular(4))),
                    ),
                  ],
                ),
              ),
              Container(width: 36, height: 6, decoration: BoxDecoration(color: const Color(0xFF654321), borderRadius: BorderRadius.circular(2))),
            ],
          ),
        ),
        // Green quad
        Positioned(
          bottom: 0, left: 0, right: 0, height: 90,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
              ),
            ),
          ),
        ),
        // Students
        Positioned(bottom: 32, left: 48, child: _StudentDot()),
        Positioned(bottom: 42, right: 72, child: _StudentDot()),
        Positioned(bottom: 36, left: 120, child: _StudentDot()),
        Positioned(bottom: 46, right: 120, child: _StudentDot()),
      ],
    );
  }
}

class _StudentDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0x60404040), borderRadius: BorderRadius.circular(2)));
  }
}

// ── Feed Footer ──────────────────────────────────────────────────────────────

class _FeedFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          SizedBox(
            width: 40, height: 40,
            child: CircleAvatar(
              backgroundColor: Color(0xFFF3F4F6),
              child: Icon(Icons.check, size: 22, color: Color(0xFF3730A3)),
            ),
          ),
          SizedBox(height: 12),
          Text(
            "You're all caught up",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Pull down to refresh for new updates',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Tab Bar ───────────────────────────────────────────────────────────

class _BottomTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _TabItem(Icons.home, 'Feed', true),
      _TabItem(Icons.grid_view_outlined, 'Hubs', false),
      _TabItem(Icons.chat_bubble_outline, 'Messages', false),
      _TabItem(Icons.calendar_today_outlined, 'Events', false),
      _TabItem(Icons.menu_book_outlined, 'Study', false),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFF3F4F6), width: 1)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map(_buildTabItem).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(_TabItem item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          item.icon,
          size: 22,
          color: item.isActive ? const Color(0xFF3730A3) : const Color(0xFF9CA3AF),
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: item.isActive ? FontWeight.w700 : FontWeight.w500,
            color: item.isActive ? const Color(0xFF3730A3) : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final bool isActive;
  const _TabItem(this.icon, this.label, this.isActive);
}
