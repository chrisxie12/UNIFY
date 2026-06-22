import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/design/design_tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Entrance: staggered fade/slide for logo, title, tagline, loading line.
  late final AnimationController _entryCtrl;
  // Slow breathing pulse for the background geometric ring.
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 3), _navigate);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    if (!mounted) return;
    if (session != null) {
      context.go('/app/feed');
    } else {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('seen_welcome') ?? false;
      if (!mounted) return;
      context.go(seen ? '/auth' : '/welcome');
    }
  }

  /// A staggered slice of the entrance timeline.
  Animation<double> _stage(double begin, double end,
          [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(begin, end, curve: curve),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final logoAnim = _stage(0.0, 0.45);
    final titleAnim = _stage(0.2, 0.6);
    final tagAnim = _stage(0.45, 0.9);
    final loadAnim = _stage(0.6, 1.0);

    return Scaffold(
      backgroundColor: UnifyColors.surfaceWhite,
      body: Stack(
        // overflow-hidden: clip the off-screen ring
        clipBehavior: Clip.hardEdge,
        children: [
          // ── Top gradient wash (blue-50 → transparent over top half) ──
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: size.height * 0.5,
              width: double.infinity,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x80EFF6FF), Color(0x00EFF6FF)],
                  ),
                ),
              ),
            ),
          ),

          // ── Subtle geometric ring accent ──
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, child) {
              final v = _pulseCtrl.value;
              return Positioned(
                top: size.height * 0.10,
                right: -80,
                child: Opacity(
                  opacity: 0.4 + 0.4 * v,
                  child: Transform.scale(scale: 1.0 + 0.05 * v, child: child),
                ),
              );
            },
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: UnifyColors.divider.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
          ),

          // ── Foreground content ──
          Center(
            child: AnimatedBuilder(
              animation: _entryCtrl,
              builder: (_, __) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hero logo — float + fade in
                    Opacity(
                      opacity: logoAnim.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - logoAnim.value)),
                        child: Transform.scale(
                          scale: 0.9 + 0.1 * logoAnim.value,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: UnifyColors.primaryBlue
                                      .withValues(alpha: 0.10),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Brand title
                    Opacity(
                      opacity: titleAnim.value,
                      child: Transform.translate(
                        offset: Offset(0, 8 * (1 - titleAnim.value)),
                        child: Text(
                          'UNIFY',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.5,
                            height: 1,
                            color: UnifyColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tagline
                    Opacity(
                      opacity: tagAnim.value,
                      child: Text(
                        'Your campus, connected.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                          color: UnifyColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 64),

                    // Loading hint
                    Opacity(
                      opacity: loadAnim.value,
                      child: Text(
                        'Loading experience...',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: UnifyColors.textSecondary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
