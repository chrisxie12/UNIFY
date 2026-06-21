import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/widgets/unify_wordmark.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _accentPurple = Color(0xFF7C3AED);
const _radiusXl     = 32.0;

// ── Welcome Screen ────────────────────────────────────────────────────────────

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // Floating circle animation
  late final AnimationController _floatCtrl;
  // Content entrance animation
  late final AnimationController _enterCtrl;

  late final Animation<double> _float;
  late final Animation<double> _fadeTitle1;
  late final Animation<Offset> _slideTitle1;
  late final Animation<double> _fadeTitle2;
  late final Animation<Offset> _slideTitle2;
  late final Animation<double> _fadeDesc;
  late final Animation<double> _fadeBtn1;
  late final Animation<double> _scaleBtn1;
  late final Animation<double> _fadeBtn2;
  late final Animation<double> _fadeTerms;

  @override
  void initState() {
    super.initState();

    // 6-second floating loop (±20px)
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _float = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    // Staggered entrance — 800ms total
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeTitle1  = _interval(0.00, 0.30);
    _slideTitle1 = _slideInterval(0.00, 0.35);
    _fadeTitle2  = _interval(0.10, 0.40);
    _slideTitle2 = _slideInterval(0.10, 0.45);
    _fadeDesc    = _interval(0.25, 0.55);
    _fadeBtn1    = _interval(0.40, 0.70);
    _scaleBtn1   = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.40, 0.70, curve: Curves.easeOut),
      ),
    );
    _fadeBtn2  = _interval(0.55, 0.80);
    _fadeTerms = _interval(0.70, 1.00);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  Animation<double> _interval(double begin, double end) =>
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _enterCtrl,
          curve: Interval(begin, end, curve: Curves.easeOut),
        ),
      );

  Animation<Offset> _slideInterval(double begin, double end) =>
      Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _enterCtrl,
          curve: Interval(begin, end, curve: Curves.easeOut),
        ),
      );

  @override
  void dispose() {
    _floatCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.46;

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen gradient ────────────────────────────────────────
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [_accentPurple, Color(0xFF8B7CB3)],
              ),
            ),
            child: SizedBox.expand(),
          ),

          // ── Floating decorative circles ──────────────────────────────────
          AnimatedBuilder(
            animation: _float,
            builder: (_, __) => Stack(
              children: [
                Positioned(
                  top: -60 + _float.value * 0.8,
                  right: -40 + _float.value * 0.5,
                  child: const _Circle(200),
                ),
                Positioned(
                  top: 80 + _float.value * 0.6,
                  left: -60 - _float.value * 0.4,
                  child: const _Circle(150),
                ),
                Positioned(
                  top: topHeight - 80 + _float.value,
                  right: 20 + _float.value * 0.3,
                  child: const _Circle(100),
                ),
              ],
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top: logo + tagline
                SizedBox(
                  height: topHeight - MediaQuery.of(context).padding.top,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const UnifyWordmark(
                          size: WordmarkSize.large,
                          style: WordmarkStyle.light,
                          vertical: true,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Your campus, connected.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom: white card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft:  Radius.circular(_radiusXl),
                        topRight: Radius.circular(_radiusXl),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 20,
                          offset: Offset(0, -8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // "Welcome to"
                          FadeTransition(
                            opacity: _fadeTitle1,
                            child: SlideTransition(
                              position: _slideTitle1,
                              child: _sg('Welcome to',
                                  size: 32, weight: FontWeight.w700, color: const Color(0xFF0F172A)),
                            ),
                          ),
                          // "UNIFY"
                          FadeTransition(
                            opacity: _fadeTitle2,
                            child: SlideTransition(
                              position: _slideTitle2,
                              child: _sg('UNIFY',
                                  size: 32, weight: FontWeight.w700, color: const Color(0xFF0F172A)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Description
                          FadeTransition(
                            opacity: _fadeDesc,
                            child: _sg(
                              'Stay updated with announcements, connect with peers, '
                              'and never miss what matters on campus.',
                              size: 15,
                              weight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Get Started button
                          FadeTransition(
                            opacity: _fadeBtn1,
                            child: ScaleTransition(
                              scale: _scaleBtn1,
                              child: _CTA(
                                label: 'Get Started',
                                bg: _accentPurple,
                                fg: Colors.white,
                                onTap: () => context.push('/onboarding-flow'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Sign-in button
                          FadeTransition(
                            opacity: _fadeBtn2,
                            child: _CTA(
                              label: 'I already have an account',
                              bg: const Color(0xFFF1F5F9),
                              fg: const Color(0xFF0F172A),
                              onTap: () => context.push('/auth?mode=login'),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Terms
                          FadeTransition(
                            opacity: _fadeTerms,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {},
                                child: _sg(
                                  'By continuing you agree to our Terms & Privacy Policy',
                                  size: 12,
                                  weight: FontWeight.w400,
                                  color: const Color(0xFF94A3B8),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _sg(
  String text, {
  required double size,
  required FontWeight weight,
  required Color color,
  double? letterSpacing,
  double? height,
  TextAlign? textAlign,
}) =>
    Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      ),
    );

// ── Decorative floating circle ────────────────────────────────────────────────
class _Circle extends StatelessWidget {
  const _Circle(this.size);
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.03),
      ),
    );
  }
}

// ── CTA button with press scale ───────────────────────────────────────────────
class _CTA extends StatefulWidget {
  const _CTA({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  State<_CTA> createState() => _CTAState();
}

class _CTAState extends State<_CTA> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: widget.bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

