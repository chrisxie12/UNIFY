import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/extensions/theme_extensions.dart';

/// Premium onboarding carousel — 4 brand scenes with UNIFY logo, gradient
/// illustrations, and parallax. Fully theme-aware.
class OnboardingCarouselScreen extends StatefulWidget {
  const OnboardingCarouselScreen({super.key});

  @override
  State<OnboardingCarouselScreen> createState() => _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState extends State<OnboardingCarouselScreen>
    with SingleTickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;
  double _scrollPage = 0;

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
        SizedBox(
          height: illustrationH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: page.gradient(context)),
                ),
              ),
              _DecorativeRings(color: page.accentColor(context)),
              Center(
                child: AnimatedBuilder(
                  animation: floatAnim,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(parallaxOffset * 0.3, floatAnim.value),
                    child: _IllustrationWidget(page: page),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 60,
                left: 24,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.surfaceCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(32, 36, 32, 120),
            child: Transform.translate(
              offset: Offset(-parallaxOffset * 0.15, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.headline,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                      height: 1.22,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    page.body,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: context.textSecondary,
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: page.pills.map((pill) => _FeaturePill(
                      emoji: pill.$1,
                      label: pill.$2,
                      color: page.accentColor(context),
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
  _RingsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.40);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.12);

    for (int i = 0; i < 5; i++) {
      final r = size.width * (0.30 + i * 0.12);
      paint.strokeWidth = 0.6 + i * 0.2;
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) => old.color != color;
}

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.20), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(label,
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

class _IllustrationWidget extends StatelessWidget {
  final _PageData page;
  const _IllustrationWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width * 0.60;
    final height = width * 0.55;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(page.emoji, style: TextStyle(fontSize: width * 0.35)),
        const SizedBox(height: 16),
        SizedBox(
          width: width * 0.6,
          height: height * 0.6,
          child: SvgPicture.asset(
            'assets/images/logo.svg',
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0.15),
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}

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
    final primary = context.primary;

    return Container(
      color: context.surfaceCard,
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (i) => _Dot(
              index: i,
              scrollPage: scrollPage,
              primary: primary,
            )),
          ),
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isLast
                    ? [primary, context.primaryDark]
                    : [primary, context.primaryLight],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.35),
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

class _Dot extends StatelessWidget {
  final int index;
  final double scrollPage;
  final Color primary;

  const _Dot({required this.index, required this.scrollPage, required this.primary});

  @override
  Widget build(BuildContext context) {
    final t = (1.0 - (scrollPage - index).abs()).clamp(0.0, 1.0);
    final width = 8.0 + 20.0 * t;
    final color = Color.lerp(context.surfaceDivider, primary, t)!;

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
  LinearGradient gradient(BuildContext context);
  Color accentColor(BuildContext context);
}

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

  @override LinearGradient gradient(BuildContext context) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [context.primaryDark, context.primary, context.primaryLight],
  );

  @override Color accentColor(BuildContext context) => context.primary;
}

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

  @override LinearGradient gradient(BuildContext context) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [context.primaryDark, context.primary, const Color(0xFF10B981)],
  );

  @override Color accentColor(BuildContext context) => const Color(0xFF059669);
}

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

  @override LinearGradient gradient(BuildContext context) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [context.primaryDark, context.primary, const Color(0xFF8B5CF6)],
  );

  @override Color accentColor(BuildContext context) => const Color(0xFF7C3AED);
}

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

  @override LinearGradient gradient(BuildContext context) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [context.primaryDark, context.primary, const Color(0xFFFBBF24)],
  );

  @override Color accentColor(BuildContext context) => context.primary;
}
