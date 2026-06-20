import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/extensions/theme_extensions.dart';

// ── Welcome Screen ────────────────────────────────────────────────────────────

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.46;

    return Scaffold(
      body: Stack(
        children: [
          // ── Branded gradient background (full screen) ─────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [context.primary, context.primaryDark],
              ),
            ),
          ),

          // ── Decorative circles ────────────────────────────────────────
          Positioned(
            top: -60,
            right: -40,
            child: _DecorativeCircle(size: 220),
          ),
          Positioned(
            top: 80,
            left: -60,
            child: _DecorativeCircle(size: 160),
          ),
          Positioned(
            top: topHeight - 80,
            right: 20,
            child: _DecorativeCircle(size: 100),
          ),

          // ── Safe-area content ─────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top half: logo + branding
                SizedBox(
                  height: topHeight - MediaQuery.of(context).padding.top,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 120,
                          height: 120,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.hub_rounded,
                            size: 80,
                            color: context.onPrimary.withValues(alpha: 0.90),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _sg(
                          'UNIFY',
                          size: 40,
                          weight: FontWeight.w700,
                          color: context.onPrimary,
                          letterSpacing: 8,
                        ),
                        const SizedBox(height: 12),
                        _sg(
                          'Your campus, connected.',
                          size: 16,
                          weight: FontWeight.w400,
                          color: context.onPrimary.withValues(alpha: 0.80),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom half: surface card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.surfaceCard,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sg('Welcome to',
                              size: 32, weight: FontWeight.w700, color: context.textPrimary),
                          _sg('UNIFY',
                              size: 32, weight: FontWeight.w700, color: context.textPrimary),
                          const SizedBox(height: 16),
                          _sg(
                            'Stay updated with announcements, connect with peers, '
                            'and never miss what matters on campus.',
                            size: 15,
                            weight: FontWeight.w400,
                            color: context.textSecondary,
                            height: 1.55,
                          ),
                          const SizedBox(height: 32),

                          // Get Started button
                          _CTA(
                            label: 'Get Started',
                            bg: context.primary,
                            fg: context.onPrimary,
                            onTap: () => context.push('/auth?mode=signup'),
                          ),
                          const SizedBox(height: 12),

                          // Sign-in button
                          _CTA(
                            label: 'I already have an account',
                            bg: context.surfaceFill,
                            fg: context.textPrimary,
                            onTap: () => context.push('/auth?mode=login'),
                          ),
                          const SizedBox(height: 20),

                          // Terms
                          Center(
                            child: GestureDetector(
                              onTap: () {},
                              child: _sg(
                                'By continuing you agree to our Terms & Privacy Policy',
                                size: 12,
                                weight: FontWeight.w400,
                                color: context.textDisabled,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _sg(
  String text, {
  required double size,
  required FontWeight weight,
  required Color color,
  double? letterSpacing,
  double? height,
  TextAlign? textAlign,
}) =>
    Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      ),
    );

// ── Decorative faint circle ───────────────────────────────────────────────────

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.onPrimary.withValues(alpha: 0.08),
      ),
    );
  }
}

// ── CTA button ────────────────────────────────────────────────────────────────

class _CTA extends StatelessWidget {
  const _CTA({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
