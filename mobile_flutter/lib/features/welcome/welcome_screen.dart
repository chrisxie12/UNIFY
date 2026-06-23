import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design/design_tokens.dart';

/// Welcome — the single pre-auth entry screen. Matches the
/// "UNIFY Bold Minimal Redesign" mockup exactly, with the UNIFY logo
/// in place of the placeholder icon.
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
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_welcome', true);
  }

  Future<void> _onGetStarted() async {
    await _markSeen();
    if (!mounted) return;
    context.push('/auth?mode=signup');
  }

  Future<void> _onHaveAccount() async {
    await _markSeen();
    if (!mounted) return;
    context.push('/auth?mode=login');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: UnifyColors.surfaceWhite,
      body: Stack(
        children: [
          // ── Hero: top blue panel ───────────────────────────────────────
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
                      colors: [UnifyColors.primaryBlue, UnifyColors.primaryDark],
                    ),
                  ),
                  child: SizedBox.expand(),
                ),

                // Concentric ring accents (matching mockup)
                Positioned(
                  right: -90,
                  bottom: -40,
                  child: _ring(360, 0.06),
                ),
                Positioned(
                  left: -70,
                  top: -30,
                  child: _ring(240, 0.05),
                ),

                // Logo + wordmark + tagline
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // UNIFY logo inside a soft halo circle
                      Container(
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.16),
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
                      Text(
                        'UNIFY',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          height: 1,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your campus, connected.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.80),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom white card ──────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: UnifyColors.surfaceWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(UnifyRadius.xxl),
                  topRight: Radius.circular(UnifyRadius.xxl),
                ),
              ),
              padding: EdgeInsets.fromLTRB(28, 32, 28, safeBottom + 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Staggered(
                    ctrl: _staggerCtrl, delay: 0.0,
                    child: Text(
                      'Welcome to UNIFY',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        height: 1.1,
                        color: UnifyColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Staggered(
                    ctrl: _staggerCtrl, delay: 0.1,
                    child: Text(
                      'Stay updated with campus announcements, connect with peers, and never miss what matters — all in one place.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        height: 1.55,
                        color: UnifyColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Get Started
                  _Staggered(
                    ctrl: _staggerCtrl, delay: 0.2,
                    child: GestureDetector(
                      onTap: _onGetStarted,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: UnifyColors.primaryBlue,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: UnifyColors.primaryBlue.withValues(alpha: 0.30),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Get Started',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // I already have an account
                  _Staggered(
                    ctrl: _staggerCtrl, delay: 0.3,
                    child: Center(
                      child: GestureDetector(
                        onTap: _onHaveAccount,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            'I already have an account',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: UnifyColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Terms
                  _Staggered(
                    ctrl: _staggerCtrl, delay: 0.4,
                    child: Center(
                      child: Text(
                        'By continuing you agree to our Terms & Privacy Policy',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: UnifyColors.textTertiary,
                          height: 1.4,
                        ),
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

  Widget _ring(double diameter, double alpha) => Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );
}

// ── Staggered entrance wrapper ─────────────────────────────────────────────

class _Staggered extends StatelessWidget {
  final AnimationController ctrl;
  final double delay;
  final Widget child;

  const _Staggered({required this.ctrl, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = ((ctrl.value - delay) / 0.5).clamp(0.0, 1.0);
        final curveT = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: curveT,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - curveT)),
            child: child,
          ),
        );
      },
    );
  }
}
