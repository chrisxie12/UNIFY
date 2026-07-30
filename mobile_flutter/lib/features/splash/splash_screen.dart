import 'dart:math';
import 'dart:ui' show lerpDouble;
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
  late final AnimationController _ctrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textSlide;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    _logoScale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.58, 0.80, curve: Curves.elasticOut),
    );

    _logoFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.58, 0.75, curve: Curves.easeIn),
    );

    _textSlide = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.78, 0.95, curve: Curves.easeOutCubic),
    );

    _textFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.78, 0.95, curve: Curves.easeIn),
    );

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 4200), _navigate);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    try {
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
    } catch (e) {
      debugPrint('[Splash] Navigation failed: $e');
      if (mounted) {
        context.go('/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : UnifyColors.primaryBlue;
    const figureColor = Colors.white;
    const logoBg = Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final phase = _ctrl.value;

          return Stack(
            children: [
              // ── Background figure canvas ───────────────────────
              Positioned.fill(
                child: CustomPaint(
                  painter: _FigurePainter(
                    phase: phase,
                    figureColor: figureColor,
                    figureAlpha: _figureAlpha(phase),
                  ),
                ),
              ),

              // ── Logo ────────────────────────────────────────────
              Center(
                child: Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: logoBg,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const UnifyLogo(size: 100),
                    ),
                  ),
                ),
              ),

              // ── UNIFY text ──────────────────────────────────────
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 160),
                  child: Opacity(
                    opacity: _textFade.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _textSlide.value)),
                      child: Text(
                        'UNIFY',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _figureAlpha(double phase) {
    if (phase < 0.58) return 1.0;
    if (phase < 0.72) return 1.0 - (phase - 0.58) / 0.14;
    return 0.0;
  }
}

// ── Figure Painter ──────────────────────────────────────────────────────────

class _FigurePainter extends CustomPainter {
  final double phase;
  final Color figureColor;
  final double figureAlpha;

  _FigurePainter({
    required this.phase,
    required this.figureColor,
    required this.figureAlpha,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (figureAlpha <= 0) return;

    final paint = Paint()
      ..color = figureColor.withValues(alpha: figureAlpha)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = size.shortestSide / 600;

    // ── Walking phase 0.0-0.50 ──────────────────────────────────
    final walkProgress = (phase.clamp(0.0, 0.50) / 0.50);
    final smoothWalk = Curves.easeInOut.transform(walkProgress);

    final meetPause = (phase.clamp(0.48, 0.58) - 0.48) / 0.10;
    final smoothMeet = Curves.easeInOut.transform(meetPause.clamp(0.0, 1.0));

    final legSwing = sin(walkProgress * pi * 4);
    final bob = (sin(walkProgress * pi * 4)).abs() * 4 * scale;

    // ── Figure positions ─────────────────────────────────────────
    final startLeft = -size.width * 0.25;
    final startRight = size.width * 1.25;
    final meetX = cx;

    final lx = lerpDouble(startLeft, meetX - 28 * scale, smoothWalk)!;
    final rx = lerpDouble(startRight, meetX + 28 * scale, smoothWalk)!;
    final baseY = cy + 20 * scale;

    // Handshake phase (0.48-0.58) - slight arm movement
    final shakeX = sin(phase * 40) * 2.0 * smoothMeet;

    // ── Girl figure (left side) ─────────────────────────────────
    final gx = lx + shakeX;
    final gy = baseY - bob;

    paintFigure(canvas, gx, gy, scale, legSwing, true, paint);

    // ── Boy figure (right side) ─────────────────────────────────
    final bx = rx - shakeX;
    final by = baseY - bob;

    paintFigure(canvas, bx, by, scale, -legSwing, false, paint);

    // ── Handshake connection ─────────────────────────────────────
    if (phase >= 0.48 && phase <= 0.65) {
      final connectionAlpha = (phase - 0.48) / 0.05;
      final shakePhase = (phase - 0.52).clamp(0.0, 0.13);
      final shakeOffset = sin(shakePhase * pi * 8) * 3 * scale;

      final handX = meetX - shakeOffset;
      final handY = cy - 18 * scale;

      final connPaint = Paint()
        ..color = figureColor.withValues(alpha: figureAlpha * connectionAlpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(Offset(handX, handY), 4 * scale, connPaint);
    }
  }

  void paintFigure(
    Canvas canvas,
    double x,
    double y,
    double scale,
    double legPhase,
    bool isGirl,
    Paint paint,
  ) {
    final paint2 = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4 * scale;

    final headR = (isGirl ? 11 : 12) * scale;
    final bodyW = (isGirl ? 12 : 14) * scale;
    final bodyH = (isGirl ? 26 : 30) * scale;
    final legL = (isGirl ? 20 : 22) * scale;
    final armL = (isGirl ? 16 : 18) * scale;

    // Head
    canvas.drawCircle(Offset(x, y - bodyH / 2 - headR - 2 * scale), headR, paint);

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, y - 2 * scale),
          width: bodyW,
          height: bodyH,
        ),
        Radius.circular(bodyW / 2),
      ),
      paint2..style = PaintingStyle.fill,
    );

    // Legs
    final legAngle = legPhase * 0.5;
    paint2.strokeWidth = 3.5 * scale;
    paint2.style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(x - bodyW * 0.25, y + bodyH / 2),
      Offset(
        x - bodyW * 0.25 - sin(legAngle) * legL,
        y + bodyH / 2 + cos(legAngle) * legL,
      ),
      paint2,
    );
    canvas.drawLine(
      Offset(x + bodyW * 0.25, y + bodyH / 2),
      Offset(
        x + bodyW * 0.25 + sin(legAngle) * legL,
        y + bodyH / 2 + cos(-legAngle) * legL,
      ),
      paint2,
    );

    // Arms
    paint2.strokeWidth = 3 * scale;
    final armSwing = -legPhase * 0.3;

    if (isGirl) {
      canvas.drawLine(
        Offset(x - bodyW / 2, y - bodyH * 0.3),
        Offset(
          x - bodyW / 2 - cos(armSwing) * armL,
          y + sin(armSwing) * armL,
        ),
        paint2,
      );
      canvas.drawLine(
        Offset(x + bodyW / 2, y - bodyH * 0.3),
        Offset(
          x + bodyW / 2 + cos(armSwing) * armL,
          y + sin(-armSwing) * armL,
        ),
        paint2,
      );
    } else {
      canvas.drawLine(
        Offset(x + bodyW / 2, y - bodyH * 0.3),
        Offset(
          x + bodyW / 2 + cos(armSwing) * armL,
          y + sin(-armSwing) * armL,
        ),
        paint2,
      );
      canvas.drawLine(
        Offset(x - bodyW / 2, y - bodyH * 0.3),
        Offset(
          x - bodyW / 2 - cos(armSwing) * armL,
          y + sin(armSwing) * armL,
        ),
        paint2,
      );
    }
  }

  @override
  bool shouldRepaint(_FigurePainter old) => old.phase != phase;
}
