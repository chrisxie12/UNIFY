import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design/design_tokens.dart';


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
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Column(
        children: [
          // ── Top 60%: Blue gradient ──────────────────────────────
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
                // Geometric cutout decoration
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
                // Center content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: UnifyColors.textInverse.withValues(alpha: 0.20),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: UnifyColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.group,
                            color: UnifyColors.textInverse,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'UNIFY',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.5,
                          color: UnifyColors.textInverse,
                          height: 1.0,
                        ),
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
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: -32),
              decoration: const BoxDecoration(
                color: UnifyColors.surfaceWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(UnifyRadius.xxl),
                  topRight: Radius.circular(UnifyRadius.xxl),
                ),
                border: Border(
                  top: BorderSide(color: UnifyColors.divider),
                ),
                boxShadow: UnifyShadows.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      UnifySpacing.s24,
                      UnifySpacing.s24,
                      UnifySpacing.s24,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StaggeredItem(
                          animCtrl: _staggerCtrl,
                          delay: 0.0,
                          child: Text(
                            'Welcome to UNIFY',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.0,
                              height: 1.2,
                              color: UnifyColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        StaggeredItem(
                          animCtrl: _staggerCtrl,
                          delay: 0.2,
                          child: Text(
                            'Stay updated with campus announcements, connect with peers, and never miss what matters \u2014 all in one place.',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              height: 1.5,
                              color: UnifyColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      UnifySpacing.s24,
                      0,
                      UnifySpacing.s24,
                      bottom + UnifySpacing.s24,
                    ),
                    child: Column(
                      children: [
                        StaggeredItem(
                          animCtrl: _staggerCtrl,
                          delay: 0.3,
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _onGetStarted,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: UnifyColors.primaryBlue,
                                foregroundColor: UnifyColors.textInverse,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('Get Started'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 16),
                        StaggeredItem(
                          animCtrl: _staggerCtrl,
                          delay: 0.5,
                          child: Center(
                            child: Text(
                              'By continuing you agree to our Terms & Privacy Policy',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                height: 1.3,
                                color: UnifyColors.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
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
