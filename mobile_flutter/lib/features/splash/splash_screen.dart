import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/design/design_tokens.dart';
import '../../core/widgets/unify_logo.dart';

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
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (!mounted) return;
      if (session != null) {
        context.go('/');
        return;
      }
    } catch (e) {
      debugPrint('[Splash] Supabase not available, showing welcome: $e');
    }
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_welcome') ?? false;
    if (!mounted) return;
    context.go(seen ? '/auth' : '/welcome');
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
      backgroundColor: UnifyColors.primaryBlue,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // ── Subtle pulse ring ──
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, child) {
              final v = _pulseCtrl.value;
              return Positioned(
                top: size.height * 0.08,
                right: -60,
                child: Opacity(
                  opacity: 0.15 + 0.1 * v,
                  child: Transform.scale(scale: 1.0 + 0.04 * v, child: child),
                ),
              );
            },
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
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
                    // Hero logo — white circle on brand blue
                    Opacity(
                      opacity: logoAnim.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - logoAnim.value)),
                        child: Transform.scale(
                          scale: 0.9 + 0.1 * logoAnim.value,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const UnifyLogo(size: 90),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Brand title
                    Opacity(
                      opacity: titleAnim.value,
                      child: Transform.translate(
                        offset: Offset(0, 8 * (1 - titleAnim.value)),
                        child: Text(
                          'UNIFY',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            height: 1,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tagline
                    Opacity(
                      opacity: tagAnim.value,
                      child: Text(
                        'Your campus, connected.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),

                    // Loading indicator
                    Opacity(
                      opacity: loadAnim.value,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Loading experience...',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
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
