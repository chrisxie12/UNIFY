import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design/design_tokens.dart';
import '../auth/presentation/providers/auth_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerCtrl;
  bool _googleLoading = false;
  String? _error;

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

  Future<void> _onGoogle() async {
    setState(() { _googleLoading = true; _error = null; });
    try {
      await _markSeen();
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      // GoRouter refresh stream handles navigation after OAuth callback.
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _onEmail() async {
    await _markSeen();
    if (!mounted) return;
    context.push('/auth?mode=signup');
  }

  Future<void> _onLogin() async {
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
          // ── Hero: top 58% blue gradient ──────────────────────────────
          SizedBox(
            height: size.height * 0.58,
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

                // Decorative ring cutout
                Positioned(
                  right: -80,
                  bottom: -80,
                  child: Container(
                    width: 380,
                    height: 380,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 56,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -60,
                  top: 30,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.04),
                        width: 40,
                      ),
                    ),
                  ),
                ),

                // Logo + wordmark
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'UNIFY',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          height: 1,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your campus, connected.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
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

          // ── Bottom card ───────────────────────────────────────────────
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
                border: Border(top: BorderSide(color: UnifyColors.divider)),
              ),
              padding: EdgeInsets.fromLTRB(
                24, 28, 24, safeBottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Staggered(
                    ctrl: _staggerCtrl, delay: 0.0,
                    child: Text(
                      'Welcome to UNIFY',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: UnifyColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _Staggered(
                    ctrl: _staggerCtrl, delay: 0.1,
                    child: Text(
                      'Connect with peers, stay updated on campus announcements, and never miss what matters — all in one place.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        height: 1.55,
                        color: UnifyColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error
                  if (_error != null) ...[
                    _Staggered(
                      ctrl: _staggerCtrl, delay: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: UnifyColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],

                  // Continue with Google
                  _Staggered(
                    ctrl: _staggerCtrl, delay: 0.2,
                    child: _GoogleButton(
                      loading: _googleLoading,
                      onTap: _googleLoading ? null : _onGoogle,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Continue with Student Email
                  _Staggered(
                    ctrl: _staggerCtrl, delay: 0.3,
                    child: GestureDetector(
                      onTap: _onEmail,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [UnifyColors.primaryBlue, UnifyColors.accentPurple],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: UnifyColors.primaryBlue.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.email_outlined,
                                size: 18, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              'Continue with Student Email',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Log in link
                  _Staggered(
                    ctrl: _staggerCtrl, delay: 0.4,
                    child: Center(
                      child: GestureDetector(
                        onTap: _onLogin,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                color: UnifyColors.textSecondary,
                              ),
                              children: [
                                const TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Log in',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: UnifyColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Terms
                  _Staggered(
                    ctrl: _staggerCtrl, delay: 0.5,
                    child: Center(
                      child: Text(
                        'By continuing you agree to our Terms & Privacy Policy',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
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
}

// ── Google button ──────────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onTap;

  const _GoogleButton({required this.loading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: UnifyColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: UnifyColors.primaryBlue),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('assets/images/google.svg', width: 20, height: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: UnifyColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Staggered entrance wrapper ─────────────────────────────────────────────

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

// Private version for internal use without a key.
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
