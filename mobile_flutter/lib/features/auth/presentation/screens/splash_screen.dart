import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Splash Screen — 4-scene animated intro
//
// Scene 1 (0s–1.3s): Glowing particle dots appear scattered across screen
// Scene 2 (0.7s–2.4s): Particles converge, connecting lines form a network
// Scene 3 (2.3s–2.9s): Network fades out, logo materialises from the centre
// Scene 4 (3.0s–3.4s): "UNIFY / Your Campus…" text fades in → navigate
// ---------------------------------------------------------------------------

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ── Main controller (3 400 ms) ─────────────────────────────────────────────
  late final AnimationController _ctrl;

  // ── Sub-animations (all driven from _ctrl via Interval) ───────────────────
  late final Animation<double> _particleAppear;   // dots fade in
  late final Animation<double> _particleMove;     // dots drift to ring
  late final Animation<double> _lineOpacity;      // network lines appear
  late final Animation<double> _particleFadeOut;  // dots + lines dissolve
  late final Animation<double> _logoOpacity;      // logo fades in
  late final Animation<double> _logoScale;        // logo scales with micro-bounce
  late final Animation<double> _textOpacity;      // tagline fades in

  // ── Particle data ──────────────────────────────────────────────────────────
  late final List<_Particle> _particles;
  static final _rng = math.Random(42); // fixed seed → consistent layout

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

  // ── Scatter→ring particle layout ──────────────────────────────────────────

  List<_Particle> _buildParticles() {
    // Starting positions: hand-placed to look naturally scattered
    const starts = [
      Offset(0.08, 0.12), Offset(0.88, 0.10),
      Offset(0.04, 0.44), Offset(0.93, 0.40),
      Offset(0.12, 0.84), Offset(0.85, 0.80),
      Offset(0.42, 0.03), Offset(0.57, 0.94),
      Offset(0.22, 0.28), Offset(0.76, 0.24),
      Offset(0.28, 0.68), Offset(0.72, 0.70),
      Offset(0.18, 0.55), Offset(0.82, 0.53),
    ];

    // Convergence ring centred on logo position (0.50, 0.42)
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

  // ── Navigation ─────────────────────────────────────────────────────────────

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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final networkAlpha = (
            _particleAppear.value * (1.0 - _particleFadeOut.value)
          ).clamp(0.0, 1.0);

          return Stack(
            children: [
              // ── Background ─────────────────────────────────────────────
              const _Background(),

              // ── Particle network ───────────────────────────────────────
              if (networkAlpha > 0.005)
                Positioned.fill(
                  child: Opacity(
                    opacity: networkAlpha,
                    child: CustomPaint(
                      painter: _NetworkPainter(
                        particles: _particles,
                        progress: _particleMove.value,
                        lineOpacity: _lineOpacity.value,
                      ),
                    ),
                  ),
                ),

              // ── Logo + tagline ─────────────────────────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo — fades + scales in with micro-bounce
                    Opacity(
                      opacity: _logoOpacity.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 0.80 + 0.20 * _logoScale.value.clamp(0.0, 1.15),
                        child: const _LogoWidget(),
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Text
                    Opacity(
                      opacity: _textOpacity.value.clamp(0.0, 1.0),
                      child: Column(
                        children: [
                          const Text(
                            'UNIFY',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 7,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Your Campus. Your People. Your Future.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.62),
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

// ---------------------------------------------------------------------------
// Background — static gradient + depth vignette
// ---------------------------------------------------------------------------

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Primary blue gradient
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF001B5E), Color(0xFF002D8A), Color(0xFF0047FF)],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
        // Subtle radial vignette for depth
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
              ),
            ),
          ),
        ),
        // Faint warm accent glow at bottom-centre (orange tint)
        Positioned(
          bottom: -60,
          left: 0,
          right: 0,
          height: 220,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.0,
                colors: [
                  const Color(0xFFFF6B35).withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Logo widget — white rounded card + glow halos
// ---------------------------------------------------------------------------

class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow halo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0066FF).withOpacity(0.55),
                blurRadius: 52,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.10),
                blurRadius: 28,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        // Inner glow ring
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF60A5FA).withOpacity(0.30),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        // Logo card
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(15),
          child: SvgPicture.asset('assets/images/logo.svg'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Particle data
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Network painter — dots + connecting lines
// ---------------------------------------------------------------------------

class _NetworkPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;     // 0-1: start → end positions
  final double lineOpacity;  // 0-1: line visibility

  const _NetworkPainter({
    required this.particles,
    required this.progress,
    required this.lineOpacity,
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
          linePaint.color = const Color(0xFF60A5FA).withOpacity(a.clamp(0, 1));
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

      // Glow — three concentric translucent rings (no MaskFilter for perf)
      fillPaint.color = const Color(0xFF93C5FD).withOpacity(0.10);
      canvas.drawCircle(pos, p.dotRadius + p.glowRadius, fillPaint);

      fillPaint.color = const Color(0xFF93C5FD).withOpacity(0.18);
      canvas.drawCircle(pos, p.dotRadius + p.glowRadius * 0.55, fillPaint);

      fillPaint.color = const Color(0xFFBAE6FD).withOpacity(0.28);
      canvas.drawCircle(pos, p.dotRadius + p.glowRadius * 0.25, fillPaint);

      // Core dot — bright white
      fillPaint.color = Colors.white.withOpacity(0.94);
      canvas.drawCircle(pos, p.dotRadius, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter old) =>
      old.progress != progress || old.lineOpacity != lineOpacity;
}
