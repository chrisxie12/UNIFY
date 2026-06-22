import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design/design_tokens.dart';
import '../../core/widgets/unify_primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: UnifyAnim.enter,
    )..forward();
  }

  @override
  void dispose() {
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
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: UnifyColors.surfaceWhite,
      body: Stack(
        children: [
          // ── Top 60%: Blue gradient ─────────────────────────────
          SizedBox(
            height: size.height * 0.60,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        UnifyColors.primaryBlue,
                        UnifyColors.primaryDark,
                      ],
                    ),
                  ),
                  child: SizedBox.expand(),
                ),

                // Geometric ring cutout, bottom-right, partly off-screen
                Positioned(
                  right: -80,
                  bottom: -80,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: UnifyColors.textInverse.withValues(alpha: 0.05),
                        width: 60,
                      ),
                    ),
                  ),
                ),

                // Center content: layered logo + wordmark + tagline
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              UnifyColors.textInverse.withValues(alpha: 0.20),
                        ),
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('UNIFY', style: UnifyTextStyle.display()),
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

          // ── Bottom 40%: White card overlapping the gradient ────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.40 + 32 + safeBottom,
              decoration: const BoxDecoration(
                color: UnifyColors.surfaceWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(UnifyRadius.xxl),
                  topRight: Radius.circular(UnifyRadius.xxl),
                ),
                border: Border(
                  top: BorderSide(color: UnifyColors.divider),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                UnifySpacing.s24,
                UnifySpacing.s24,
                UnifySpacing.s24,
                safeBottom + UnifySpacing.s24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StaggeredItem(
                    animCtrl: _staggerCtrl,
                    delay: 0.0,
                    child: Text(
                      'Welcome to UNIFY',
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
                    child: Center(
                      child: TextButton(
                        onPressed: () => context.push('/auth'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          minimumSize: const Size(0, 44),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'I already have an account',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: UnifyColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: UnifySpacing.s16),
                  StaggeredItem(
                    animCtrl: _staggerCtrl,
                    delay: 0.5,
                    child: Center(
                      child: Text(
                        'By continuing you agree to our Terms & Privacy Policy',
                        style: UnifyTextStyle.micro(
                            color: UnifyColors.textTertiary),
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
