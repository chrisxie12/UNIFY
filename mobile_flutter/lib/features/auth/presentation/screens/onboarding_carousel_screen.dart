import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Onboarding Carousel — 4 premium scenes
//
// Scene 1: Find Your People Before School Starts
// Scene 2: Discover Campus Life
// Scene 3: Join Communities That Get You
// Scene 4: Build Your Future
// ---------------------------------------------------------------------------

class OnboardingCarouselScreen extends StatefulWidget {
  const OnboardingCarouselScreen({super.key});

  @override
  State<OnboardingCarouselScreen> createState() => _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState extends State<OnboardingCarouselScreen>
    with SingleTickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;
  double _scrollPage = 0; // fractional page for parallax

  // Float animation for the illustration icon
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  static const _pages = [_Page1(), _Page2(), _Page3(), _Page4()];
  static const _count = 4;

  @override
  void initState() {
    super.initState();
    _pageCtrl.addListener(() {
      if (mounted) setState(() => _scrollPage = _pageCtrl.page ?? 0);
    });

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    context.go('/get-started');
  }

  void _next() {
    if (_page < _count - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _count - 1;

    return Scaffold(
      body: Stack(
        children: [
          // ── Page content ───────────────────────────────────────
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _count,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              final parallaxOffset = (_scrollPage - index) * 36.0;
              return _OnboardingPage(
                page: _pages[index],
                parallaxOffset: parallaxOffset,
                floatAnim: _floatAnim,
              );
            },
          ),

          // ── Skip button ────────────────────────────────────────
          if (!isLast)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 20,
              child: TextButton(
                onPressed: _finish,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.80),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),

          // ── Bottom controls ────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomControls(
              page: _page,
              count: _count,
              isLast: isLast,
              onNext: _next,
              scrollPage: _scrollPage,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single onboarding page layout
// ---------------------------------------------------------------------------

class _OnboardingPage extends StatelessWidget {
  final _PageData page;
  final double parallaxOffset;
  final Animation<double> floatAnim;

  const _OnboardingPage({
    required this.page,
    required this.parallaxOffset,
    required this.floatAnim,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final illustrationH = size.height * 0.54;

    return Column(
      children: [
        // ── Gradient illustration area ─────────────────────────
        SizedBox(
          height: illustrationH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Gradient background
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: page.gradient),
                ),
              ),
              // Decorative rings
              _DecorativeRings(color: page.accentColor),
              // Floating illustration
              Center(
                child: AnimatedBuilder(
                  animation: floatAnim,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(parallaxOffset * 0.3, floatAnim.value),
                    child: _IllustrationWidget(page: page),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Text card ─────────────────────────────────────────
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(32, 36, 32, 120),
            child: Transform.translate(
              offset: Offset(-parallaxOffset * 0.15, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.headline,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A0A1A),
                      height: 1.22,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    page.body,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Feature pills
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: page.pills.map((pill) => _FeaturePill(
                      emoji: pill.$1,
                      label: pill.$2,
                      color: page.accentColor,
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Decorative rings
// ---------------------------------------------------------------------------

class _DecorativeRings extends StatelessWidget {
  final Color color;
  const _DecorativeRings({required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _RingsPainter(color: color)),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final Color color;
  const _RingsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rings = [
      (Offset(size.width * 0.85, size.height * 0.15), size.width * 0.22, 0.12),
      (Offset(size.width * 0.12, size.height * 0.75), size.width * 0.18, 0.10),
      (Offset(size.width * 0.70, size.height * 0.88), size.width * 0.14, 0.08),
      (Offset(size.width * 0.08, size.height * 0.22), size.width * 0.10, 0.07),
    ];

    for (final (center, radius, alpha) in rings) {
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(center, radius, paint);
      paint.color = Colors.white.withValues(alpha: alpha * 0.5);
      canvas.drawCircle(center, radius * 1.45, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// Illustration widget — large emoji + glow card
// ---------------------------------------------------------------------------

class _IllustrationWidget extends StatelessWidget {
  final _PageData page;
  const _IllustrationWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Outer glow
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.15),
                blurRadius: 60,
                spreadRadius: 20,
              ),
            ],
          ),
        ),
        // Main card
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Center(
            child: Text(page.emoji, style: const TextStyle(fontSize: 64)),
          ),
        ),
        // Floating accent bubbles — translate from Stack centre so negative
        // offsets go left/up without being clipped by Positioned bounds.
        ...page.floatingItems.map((item) => Align(
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(item.dx, item.dy),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: page.accentColor,
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Feature pill chip
// ---------------------------------------------------------------------------

class _FeaturePill extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _FeaturePill({
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.20), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom controls — dots + button
// ---------------------------------------------------------------------------

class _BottomControls extends StatelessWidget {
  final int page;
  final int count;
  final bool isLast;
  final VoidCallback onNext;
  final double scrollPage;

  const _BottomControls({
    required this.page,
    required this.count,
    required this.isLast,
    required this.onNext,
    required this.scrollPage,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (i) => _Dot(
              index: i,
              scrollPage: scrollPage,
            )),
          ),
          const SizedBox(height: 20),
          // Action button
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isLast
                    ? [const Color(0xFFFF6B35), const Color(0xFFFF8C42)]
                    : [const Color(0xFF0047FF), Theme.of(context).colorScheme.primary],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: (isLast ? const Color(0xFFFF6B35) : const Color(0xFF0047FF))
                      .withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onNext,
                borderRadius: BorderRadius.circular(18),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLast ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
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

// ---------------------------------------------------------------------------
// Animated dot indicator
// ---------------------------------------------------------------------------

class _Dot extends StatelessWidget {
  final int index;
  final double scrollPage;

  const _Dot({required this.index, required this.scrollPage});

  @override
  Widget build(BuildContext context) {
    final t = (1.0 - (scrollPage - index).abs()).clamp(0.0, 1.0);
    final width = 8.0 + 20.0 * t;
    final color = Color.lerp(
      const Color(0xFFD1D5DB),
      const Color(0xFF0047FF),
      t,
    )!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3.5),
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page data model
// ---------------------------------------------------------------------------

class _FloatingItem {
  final double dx;
  final double dy;
  final String label;
  const _FloatingItem(this.dx, this.dy, this.label);
}

abstract class _PageData {
  const _PageData();
  String get emoji;
  String get headline;
  String get body;
  List<(String, String)> get pills;
  List<_FloatingItem> get floatingItems;
  LinearGradient get gradient;
  Color get accentColor;
}

// ---------------------------------------------------------------------------
// Page 1 — Find Your People Before School Starts
// ---------------------------------------------------------------------------

class _Page1 extends _PageData {
  const _Page1();

  @override String get emoji => '🎓';

  @override String get headline => 'Find Your People\nBefore School Starts';

  @override String get body =>
      'Connect with future classmates, seniors, and alumni from your university '
      'before you step on campus. Build your network before day one.';

  @override List<(String, String)> get pills => [
    ('🏫', 'Campus Network'),
    ('🤝', 'Peer Connections'),
    ('💡', 'Mentorship'),
  ];

  @override List<_FloatingItem> get floatingItems => [
    const _FloatingItem(-120, -60, '💬 Meet Seniors'),
    const _FloatingItem(50, -75, '🏅 Verified'),
    const _FloatingItem(-130, 40, '🌍 1,200+ Students'),
  ];

  @override LinearGradient get gradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF001B5E), Color(0xFF002D8A), Color(0xFF0047FF)],
  );

  @override Color get accentColor => const Color(0xFF0047FF);
}

// ---------------------------------------------------------------------------
// Page 2 — Discover Campus Life
// ---------------------------------------------------------------------------

class _Page2 extends _PageData {
  const _Page2();

  @override String get emoji => '🏠';

  @override String get headline => 'Discover\nCampus Life';

  @override String get body =>
      'From housing tips to hidden study spots — get the insider guide to your '
      'campus from students who\'ve been there. No more orientation surprises.';

  @override List<(String, String)> get pills => [
    ('🗺️', 'Campus Map'),
    ('🍔', 'Food Spots'),
    ('📚', 'Study Rooms'),
  ];

  @override List<_FloatingItem> get floatingItems => [
    const _FloatingItem(-130, -50, '🏠 Housing Tips'),
    const _FloatingItem(45, -70, '☕ Best Cafes'),
    const _FloatingItem(-120, 45, '📍 Hidden Spots'),
  ];

  @override LinearGradient get gradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF065F46), Color(0xFF059669), Color(0xFF10B981)],
  );

  @override Color get accentColor => const Color(0xFF059669);
}

// ---------------------------------------------------------------------------
// Page 3 — Join Communities That Get You
// ---------------------------------------------------------------------------

class _Page3 extends _PageData {
  const _Page3();

  @override String get emoji => '💬';

  @override String get headline => 'Join Communities\nThat Get You';

  @override String get body =>
      'Interest-based hubs, study groups, clubs, and department channels. '
      'Find your tribe and stay in the loop — all in one place.';

  @override List<(String, String)> get pills => [
    ('🎭', 'Clubs & Societies'),
    ('📖', 'Study Groups'),
    ('🎮', 'Interest Hubs'),
  ];

  @override List<_FloatingItem> get floatingItems => [
    const _FloatingItem(-125, -55, '💻 Tech Hub'),
    const _FloatingItem(48, -68, '🎭 Drama Club'),
    const _FloatingItem(-118, 48, '🎵 Music Society'),
  ];

  @override LinearGradient get gradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4C1D95), Color(0xFF6D28D9), Color(0xFF8B5CF6)],
  );

  @override Color get accentColor => const Color(0xFF7C3AED);
}

// ---------------------------------------------------------------------------
// Page 4 — Build Your Future
// ---------------------------------------------------------------------------

class _Page4 extends _PageData {
  const _Page4();

  @override String get emoji => '🚀';

  @override String get headline => 'Build Your Future\nWith UNIFY';

  @override String get body =>
      'Showcase your achievements, discover internships, and connect with '
      'industry professionals. Your campus career journey starts here.';

  @override List<(String, String)> get pills => [
    ('💼', 'Internships'),
    ('🏆', 'UNIFY Score'),
    ('🌟', 'Achievements'),
  ];

  @override List<_FloatingItem> get floatingItems => [
    const _FloatingItem(-130, -55, '⚡ UNIFY Score'),
    const _FloatingItem(45, -70, '💼 Opportunities'),
    const _FloatingItem(-120, 45, '🏆 Leaderboard'),
  ];

  @override LinearGradient get gradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF92400E), Color(0xFFD97706), Color(0xFFFBBF24)],
  );

  @override Color get accentColor => const Color(0xFFD97706);
}
