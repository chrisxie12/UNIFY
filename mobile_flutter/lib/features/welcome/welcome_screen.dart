import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design/design_tokens.dart';
import '../../core/widgets/unify_logo.dart';
import '../../core/widgets/unify_primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _staggerCtrl = AnimationController(
      vsync: this,
      duration: UnifyAnim.enter,
    )..forward();
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  void _onGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_welcome', true);
    if (!mounted) return;
    context.push('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // ── Top 60%: Gradient ──────────────────────────────────
          SizedBox(
            height: size.height * 0.60,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        UnifyColors.accentPurple,
                        Color(0xFF8B7CB3),
                      ],
                    ),
                  ),
                ),
                // Decorative floating circles
                AnimatedBuilder(
                  animation: _floatCtrl,
                  builder: (_, __) {
                    final f = _floatCtrl.value;
                    return Stack(
                      children: [
                        _floatCircle(200, -40, size.height * 0.08, f * 15),
                        _floatCircle(150, size.width - 100, size.height * 0.20, -f * 12),
                        _floatCircle(100, size.width * 0.3, size.height * 0.35, f * 18),
                      ],
                    );
                  },
                ),
                // Center content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UnifyLogo(
                        size: 120,
                        backgroundColor: UnifyColors.textInverse.withValues(alpha: 0.20),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'UNIFY',
                        style: UnifyTextStyle.display(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your campus, connected.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          color: UnifyColors.textInverse.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom 40%: White card ─────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.40 + MediaQuery.of(context).padding.bottom,
              decoration: const BoxDecoration(
                color: UnifyColors.surfaceWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(UnifyRadius.xxl),
                  topRight: Radius.circular(UnifyRadius.xxl),
                ),
                boxShadow: UnifyShadows.lg,
              ),
              padding: EdgeInsets.fromLTRB(
                UnifySpacing.s24,
                UnifySpacing.s24,
                UnifySpacing.s24,
                MediaQuery.of(context).padding.bottom + UnifySpacing.s24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Welcome to" — staggered slide + fade
                  StaggeredItem(
                    animCtrl: _staggerCtrl,
                    delay: 0.0,
                    child: Text(
                      'Welcome to',
                      style: UnifyTextStyle.h1(),
                    ),
                  ),
                  StaggeredItem(
                    animCtrl: _staggerCtrl,
                    delay: 0.1,
                    child: Text(
                      'UNIFY',
                      style: UnifyTextStyle.h1(),
                    ),
                  ),
                  const SizedBox(height: UnifySpacing.s8),
                  StaggeredItem(
                    animCtrl: _staggerCtrl,
                    delay: 0.2,
                    child: Text(
                      'Stay updated with campus announcements, connect with peers, and never miss what matters — all in one place.',
                      style: UnifyTextStyle.body(),
                    ),
                  ),
                  const Spacer(),
                  StaggeredItem(
                    animCtrl: _staggerCtrl,
                    delay: 0.3,
                    child: UnifyPrimaryButton(
                      label: 'Get Started',
                      onPressed: _onGetStarted,
                    ),
                  ),
                  const SizedBox(height: UnifySpacing.s12),
                  StaggeredItem(
                    animCtrl: _staggerCtrl,
                    delay: 0.4,
                    child: UnifyPrimaryButton(
                      label: 'I already have an account',
                      backgroundColor: UnifyColors.surfaceElevated,
                      onPressed: () => context.push('/auth'),
                    ),
                  ),
                  const SizedBox(height: UnifySpacing.s16),
                  StaggeredItem(
                    animCtrl: _staggerCtrl,
                    delay: 0.5,
                    child: Center(
                      child: Text(
                        'By continuing you agree to our Terms & Privacy Policy',
                        style: UnifyTextStyle.micro(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatCircle(double r, double left, double top, double offset) {
    return Positioned(
      left: left,
      top: top + offset,
      child: Transform.translate(
        offset: Offset(0, offset),
        child: Container(
          width: r,
          height: r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: UnifyColors.textInverse.withValues(alpha: 0.03),
          ),
        ),
      ),
    );
  }
}

// ── Staggered entrance wrapper ──────────────────────────────────────────

class StaggeredItem extends StatelessWidget {
  final AnimationController animCtrl;
  final double delay;
  final Widget child;

  const StaggeredItem({
    super.key,
    required this.animCtrl,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animCtrl,
      builder: (_, __) {
        final t = ((animCtrl.value - delay) / 0.5).clamp(0.0, 1.0);
        final curveT = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: curveT,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - curveT)),
            child: child,
          ),
        );
      },
    );
  }
}
