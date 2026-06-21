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
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    Future.delayed(const Duration(seconds: 3), _navigate);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    // Fade out transition
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (_, __) {
        final t = _animCtrl.value;

        // Cycle through 3 colour phases over the 8s loop
        final phase = (t * 3).floor();
        final frac = (t * 3) - phase;
        final colors = [
          UnifyColors.primaryBlue,
          UnifyColors.primaryDark,
          UnifyColors.accentPurple,
          UnifyColors.primaryBlue,
        ];
        final topColor = Color.lerp(colors[phase], colors[phase + 1], frac)!;
        final bottomColor = Color.lerp(colors[phase + 1], colors[phase + 2], frac)!;

        // Logo scale: 0.8→1.0 over first 60% of 3s (1.8s)
        final logoScale = Tween<double>(begin: 0.8, end: 1.0)
            .animate(CurvedAnimation(
              parent: _animCtrl,
              curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
            ))
            .value;

        // Text fade & slide
        final textOpacity = ((t * 3) - 0.6).clamp(0.0, 1.0);
        final textSlide = 20.0 * (1.0 - textOpacity);
        final tagOpacity = ((t * 3) - 0.9).clamp(0.0, 1.0);

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [topColor, bottomColor],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: logoScale,
                    child: UnifyLogo(
                      size: 80,
                      backgroundColor: UnifyColors.textInverse.withValues(alpha: 0.20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Opacity(
                    opacity: textOpacity,
                    child: Transform.translate(
                      offset: Offset(0, textSlide),
                      child: Text(
                        'UNIFY',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 8,
                          color: UnifyColors.textInverse,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Opacity(
                    opacity: tagOpacity,
                    child: Text(
                      'Your campus, connected.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: UnifyColors.textInverse.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
