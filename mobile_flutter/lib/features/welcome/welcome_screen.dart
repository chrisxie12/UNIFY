import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/unify_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          _AnimatedBackground(),
          const _ConnectedParticles(count: 30),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                _LogoGlow(ctrl: _ctrl),
                const Spacer(),
                _TitleGroup(ctrl: _ctrl),
                const Spacer(flex: 3),
                _BottomCard(ctrl: _ctrl, bottom: bottom, onGetStarted: _onGetStarted),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated mesh gradient background ──────────────────────────────────────

class _AnimatedBackground extends StatefulWidget {
  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _MeshGradientPainter(_ctrl.value),
        size: Size.infinite,
      ),
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  final double progress;
  _MeshGradientPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = _createShader(size);
    canvas.drawRect(Offset.zero & size, paint);

    final shimmer = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..blendMode = BlendMode.overlay;
    final rng = math.Random(123);
    for (int i = 0; i < 200; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 1.8 + 0.3,
        shimmer,
      );
    }
  }

  Shader _createShader(Size size) {
    final t = progress * math.pi * 2;
    return LinearGradient(
      colors: const [
        Color(0xFF1E40AF),
        Color(0xFF2563EB),
        Color(0xFF1D4ED8),
        Color(0xFF1E3A8A),
        Color(0xFF172554),
        Color(0xFF0F1D3A),
      ],
      stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      begin: Alignment(
        -0.6 + math.sin(t * 0.3) * 0.3,
        -0.6 + math.cos(t * 0.2) * 0.3,
      ),
      end: Alignment(
        1.6 + math.sin(t * 0.4 + 1.5) * 0.3,
        1.6 + math.cos(t * 0.3 + 2.0) * 0.3,
      ),
    ).createShader(Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter old) =>
      old.progress != progress;
}

// ── Connected floating particles (network visual) ─────────────────────────

class _ConnectedParticles extends StatefulWidget {
  final int count;
  const _ConnectedParticles({required this.count});

  @override
  State<_ConnectedParticles> createState() => _ConnectedParticlesState();
}

class _ConnectedParticlesState extends State<_ConnectedParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 25))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _ParticleNetworkPainter(
          count: widget.count,
          progress: _ctrl.value,
          screenSize: MediaQuery.sizeOf(context),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ParticleNetworkPainter extends CustomPainter {
  final int count;
  final double progress;
  final Size screenSize;
  _ParticleNetworkPainter({
    required this.count,
    required this.progress,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final positions = List.generate(count, (_) {
      final p = rng.nextDouble() * 100;
      return Offset(
        (size.width * (rng.nextDouble() * 0.9 + 0.05) +
            math.sin(progress * math.pi * 2 + p) * 20),
        (size.height * (rng.nextDouble() * 0.9 + 0.05) +
            math.cos(progress * math.pi * 1.7 + p) * 15),
      );
    });

    final linePaint = Paint()..strokeWidth = 0.6;
    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        final dist = (positions[i] - positions[j]).distance;
        if (dist < 100) {
          final alpha = ((1 - dist / 100) * 0.12);
          linePaint.color = const Color(0xFF60A5FA).withValues(alpha: alpha);
          canvas.drawLine(positions[i], positions[j], linePaint);
        }
      }
    }

    for (final pos in positions) {
      final opacity = rng.nextDouble() * 0.3 + 0.1;
      final isLarge = rng.nextBool();
      if (isLarge) {
        final glow = Paint()
          ..color = const Color(0xFF3B82F6).withValues(alpha: opacity * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(pos, 5, glow);
      }
      final dot = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..blendMode = BlendMode.screen;
      canvas.drawCircle(pos, isLarge ? 2.0 : 1.2, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ── Logo with glow ────────────────────────────────────────────────────────

class _LogoGlow extends StatelessWidget {
  final AnimationController ctrl;
  const _LogoGlow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = Curves.easeOutBack.transform((ctrl.value / 0.5).clamp(0.0, 1.0));
        final fade = Curves.easeOut.transform((ctrl.value / 0.3).clamp(0.0, 1.0));
        return Opacity(
          opacity: fade,
          child: Transform.scale(
            scale: 0.5 + t * 0.5,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
                  stops: [0.3, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                    blurRadius: 35,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
                    blurRadius: 70,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: const Center(child: UnifyLogo(size: 68)),
            ),
          ),
        );
      },
    );
  }
}

// ── Title group ───────────────────────────────────────────────────────────

class _TitleGroup extends StatelessWidget {
  final AnimationController ctrl;
  const _TitleGroup({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = Curves.easeOutCubic.transform(
          ((ctrl.value - 0.25) / 0.45).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 25 * (1 - t)),
            child: Column(
              children: [
                  Text(
                    'UNIFY',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 5,
                      height: 1,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 14),
                Text(
                  'YOUR CAMPUS · CONNECTED',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Bottom glassmorphism card ──────────────────────────────────────────────

class _BottomCard extends StatelessWidget {
  final AnimationController ctrl;
  final double bottom;
  final VoidCallback onGetStarted;
  const _BottomCard({
    required this.ctrl,
    required this.bottom,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = Curves.easeOutCubic.transform(
          ((ctrl.value - 0.55) / 0.40).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - t)),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.fromLTRB(28, 32, 28, bottom + 28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 50,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to UNIFY',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Stay updated with campus announcements, connect with peers, and never miss what matters — all in one place.',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2563EB),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Get Started'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/auth'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'I already have an account',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'By continuing you agree to our Terms & Privacy Policy',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.35),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
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
