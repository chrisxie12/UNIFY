import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/extensions/theme_extensions.dart';

/// Premium animated splash — 4-scene intro with UNIFY logo, particle network,
/// and tagline. Adapts to the current theme preset.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _particleAppear;
  late final Animation<double> _particleMove;
  late final Animation<double> _lineOpacity;
  late final Animation<double> _particleFadeOut;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;

  late final List<_Particle> _particles;
  static final _rng = math.Random(42);

  @override
  void initState() {
    super.initState();
    _particles = _buildParticles();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    _initCurves();
    _ctrl.forward();
    _scheduleNavigate();
  }

  void _initCurves() {
    _particleAppear = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.38, curve: Curves.easeOut),
    );
    _particleMove = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.10, 0.82, curve: Curves.easeInOut),
    );
    _lineOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.22, 0.70, curve: Curves.easeInOut),
    );
    _particleFadeOut = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.66, 0.84, curve: Curves.easeIn),
    );
    _logoOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.74, 0.90, curve: Curves.easeOut),
    );
    _logoScale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.74, 0.96, curve: Curves.easeOutBack),
    );
    _textOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.88, 1.00, curve: Curves.easeOut),
    );
  }

  List<_Particle> _buildParticles() {
    const starts = [
      Offset(0.08, 0.12), Offset(0.88, 0.10),
      Offset(0.04, 0.44), Offset(0.93, 0.40),
      Offset(0.12, 0.84), Offset(0.85, 0.80),
      Offset(0.42, 0.03), Offset(0.57, 0.94),
      Offset(0.22, 0.28), Offset(0.76, 0.24),
      Offset(0.28, 0.68), Offset(0.72, 0.70),
      Offset(0.18, 0.55), Offset(0.82, 0.53),
    ];

    const cx = 0.50, cy = 0.42;
    const baseR = 0.17;

    return List.generate(14, (i) {
      final angle = (i / 14) * 2 * math.pi - math.pi / 2;
      final r = baseR + (_rng.nextDouble() - 0.5) * 0.06;
      return _Particle(
        start: starts[i],
        end: Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
        dotRadius: 2.5 + _rng.nextDouble() * 2.0,
        glowRadius: 6.0 + _rng.nextDouble() * 5.0,
      );
    });
  }

  Future<void> _scheduleNavigate() async {
    await Future.delayed(const Duration(milliseconds: 3700));
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

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;
    final isDark = context.isDark;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final networkAlpha = (
            _particleAppear.value * (1.0 - _particleFadeOut.value)
          ).clamp(0.0, 1.0);

          return Stack(
            children: [
              _Background(primary: primary, isDark: isDark),
              if (networkAlpha > 0.005)
                Positioned.fill(
                  child: Opacity(
                    opacity: networkAlpha,
                    child: CustomPaint(
                      painter: _NetworkPainter(
                        particles: _particles,
                        progress: _particleMove.value,
                        lineOpacity: _lineOpacity.value,
                        primaryColor: primary,
                      ),
                    ),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: _logoOpacity.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 0.80 + 0.20 * _logoScale.value.clamp(0.0, 1.15),
                        child: _LogoWidget(primary: primary),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Opacity(
                      opacity: _textOpacity.value.clamp(0.0, 1.0),
                      child: Column(
                        children: [
                          Text(
                            'UNIFY',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFFE4E7ED) : Colors.white,
                              letterSpacing: 7,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Your Campus. Your People. Your Future.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: (isDark ? const Color(0xFF949BA8) : Colors.white).withValues(alpha: 0.62),
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Background extends StatelessWidget {
  final Color primary;
  final bool isDark;

  const _Background({required this.primary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF0D0F13), const Color(0xFF15171D), const Color(0xFF1C1E26)]
                    : [Color.alphaBlend(Colors.black.withValues(alpha: 0.35), primary),
                       primary,
                       Color.alphaBlend(Colors.white.withValues(alpha: 0.15), primary)],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Colors.transparent, Colors.black.withValues(alpha: isDark ? 0.50 : 0.35)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoWidget extends StatelessWidget {
  final Color primary;

  const _LogoWidget({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: primary.withValues(alpha: 0.55), blurRadius: 52, spreadRadius: 10),
              BoxShadow(color: Colors.white.withValues(alpha: 0.10), blurRadius: 28, spreadRadius: 5),
            ],
          ),
        ),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: primary.withValues(alpha: 0.30), blurRadius: 20, spreadRadius: 2),
            ],
          ),
        ),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
            ],
          ),
          padding: const EdgeInsets.all(15),
          child: SvgPicture.asset('assets/images/logo.svg'),
        ),
      ],
    );
  }
}

class _Particle {
  final Offset start;
  final Offset end;
  final double dotRadius;
  final double glowRadius;

  const _Particle({
    required this.start,
    required this.end,
    required this.dotRadius,
    required this.glowRadius,
  });
}

class _NetworkPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final double lineOpacity;
  final Color primaryColor;

  const _NetworkPainter({
    required this.particles,
    required this.progress,
    required this.lineOpacity,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final positions = particles.map((p) {
      final norm = Offset.lerp(p.start, p.end, progress)!;
      return Offset(norm.dx * size.width, norm.dy * size.height);
    }).toList();

    _paintLines(canvas, positions, size);
    _paintDots(canvas, positions);
  }

  void _paintLines(Canvas canvas, List<Offset> pos, Size size) {
    final threshold = size.shortestSide * 0.38;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < pos.length; i++) {
      for (int j = i + 1; j < pos.length; j++) {
        final dist = (pos[i] - pos[j]).distance;
        if (dist < threshold) {
          final a = (1.0 - dist / threshold) * lineOpacity * 0.65;
          linePaint.color = primaryColor.withValues(alpha: (a * 0.6).clamp(0, 1));
          canvas.drawLine(pos[i], pos[j], linePaint);
        }
      }
    }
  }

  void _paintDots(Canvas canvas, List<Offset> positions) {
    final fillPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < particles.length; i++) {
      final pos = positions[i];
      final p = particles[i];

      fillPaint.color = primaryColor.withValues(alpha: 0.10);
      canvas.drawCircle(pos, p.dotRadius + p.glowRadius, fillPaint);
      fillPaint.color = primaryColor.withValues(alpha: 0.18);
      canvas.drawCircle(pos, p.dotRadius + p.glowRadius * 0.55, fillPaint);
      fillPaint.color = primaryColor.withValues(alpha: 0.28);
      canvas.drawCircle(pos, p.dotRadius + p.glowRadius * 0.25, fillPaint);

      fillPaint.color = Colors.white.withValues(alpha: 0.94);
      canvas.drawCircle(pos, p.dotRadius, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter old) =>
      old.progress != progress || old.lineOpacity != lineOpacity;
}
