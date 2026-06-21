import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/widgets/unify_wordmark.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Gradient cycling controller (8s, repeat)
  late final AnimationController _gradientCtrl;

  // Logo scale: 0-600ms, scale 0.8→1.0, elasticOut
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;

  // "UNIFY" text: 400-800ms, fade + slide up 20px
  late final AnimationController _textCtrl;
  late final Animation<double> _textOpacity;
  late final Animation<double> _textSlide;

  // Tagline: 700-1000ms, fade in
  late final AnimationController _taglineCtrl;
  late final Animation<double> _taglineOpacity;

  // Screen exit fade
  late final AnimationController _exitCtrl;
  late final Animation<double> _exitOpacity;

  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _primaryDark = Color(0xFF1D4ED8);
  static const Color _accentPurple = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();

    // Gradient — 8s repeating
    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Logo — 600ms, elasticOut scale
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );

    // "UNIFY" text — 400ms duration (window 400-800ms)
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );
    _textSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );

    // Tagline — 300ms duration (window 700-1000ms)
    _taglineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut),
    );

    // Exit fade — 400ms
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Start logo immediately (0-600ms)
    _logoCtrl.forward();

    // Start "UNIFY" text at 400ms
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _textCtrl.forward();

    // Start tagline at 700ms
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _taglineCtrl.forward();

    // Wait until 3000ms total has elapsed (700ms already elapsed, wait 2300ms more)
    await Future.delayed(const Duration(milliseconds: 2300));
    if (!mounted) return;

    // Fade out the entire screen over 400ms
    await _exitCtrl.forward();
    if (!mounted) return;

    await _navigate();
  }

  @override
  void dispose() {
    _gradientCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _taglineCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      context.go('/app/feed');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    if (!mounted) return;
    context.go(seenOnboarding ? '/get-started' : '/welcome');
  }

  /// Interpolate gradient colours cycling through primaryBlue → primaryDark →
  /// accentPurple over one full 8-second period (0.0 – 1.0).
  List<Color> _gradientColors(double t) {
    if (t < 0.33) {
      final p = t / 0.33;
      return [
        Color.lerp(_primaryBlue, _primaryDark, p)!,
        Color.lerp(_primaryDark, _accentPurple, p)!,
      ];
    } else if (t < 0.66) {
      final p = (t - 0.33) / 0.33;
      return [
        Color.lerp(_primaryDark, _accentPurple, p)!,
        Color.lerp(_accentPurple, _primaryBlue, p)!,
      ];
    } else {
      final p = (t - 0.66) / 0.34;
      return [
        Color.lerp(_accentPurple, _primaryBlue, p)!,
        Color.lerp(_primaryBlue, _primaryDark, p)!,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _exitOpacity,
        child: AnimatedBuilder(
          animation: _gradientCtrl,
          builder: (context, child) {
            final colors = _gradientColors(_gradientCtrl.value);
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                  colors: colors,
                ),
              ),
              child: child,
            );
          },
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Logo — scale 0.8→1.0, Curves.elasticOut, 0-600ms
                ScaleTransition(
                  scale: _logoScale,
                  child: const UnifyWordmark(
                    size: WordmarkSize.large,
                    style: WordmarkStyle.light,
                    vertical: true,
                    showText: false,
                  ),
                ),
                const SizedBox(height: 24),
                // 2. "UNIFY" text — fade + slide up 20px, 400-800ms
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _textOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: Text(
                          'UNIFY',
                          style: GoogleFonts.inter(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // 3. Tagline — fade in, 700-1000ms
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: Text(
                    'Your campus, connected.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
