import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────

const _primaryBlue   = Color(0xFF2563EB);
const _accentPurple  = Color(0xFF6B5B95);
const _purpleLight   = Color(0xFF8B7CB3);
const _surfaceGrey   = Color(0xFFF8FAFC);
const _textDark      = Color(0xFF0F172A);
const _textBody      = Color(0xFF475569);
const _textMuted     = Color(0xFF94A3B8);

TextStyle _sg(double size, FontWeight w, Color c, {double? ls, double? h}) =>
    GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: w,
      color: c,
      letterSpacing: ls,
      height: h,
    );

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
          // ── Purple gradient background (full screen) ──────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [_accentPurple, _purpleLight],
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
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'UNIFY',
                          style: _sg(40, FontWeight.w700, Colors.white, ls: 8),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your campus, connected.',
                          style: _sg(16, FontWeight.w400,
                              Colors.white.withValues(alpha: 0.80)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom half: white card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome to',
                              style: _sg(32, FontWeight.w700, _textDark)),
                          Text('UNIFY',
                              style: _sg(32, FontWeight.w700, _textDark)),
                          const SizedBox(height: 16),
                          Text(
                            'Stay updated with announcements, connect with peers, '
                            'and never miss what matters on campus.',
                            style: _sg(15, FontWeight.w400, _textBody, h: 1.55),
                          ),
                          const SizedBox(height: 32),

                          // Get Started button
                          _CTA(
                            label: 'Get Started',
                            bg: _accentPurple,
                            fg: Colors.white,
                            onTap: () => context.push('/auth?mode=signup'),
                          ),
                          const SizedBox(height: 12),

                          // Sign-in button
                          _CTA(
                            label: 'I already have an account',
                            bg: _surfaceGrey,
                            fg: _textDark,
                            onTap: () => context.push('/auth?mode=login'),
                          ),
                          const SizedBox(height: 20),

                          // Terms
                          Center(
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                'By continuing you agree to our Terms & Privacy Policy',
                                style: _sg(12, FontWeight.w400, _textMuted),
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

// ── Two-person UNIFY logo ─────────────────────────────────────────────────────

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
        color: Colors.white.withValues(alpha: 0.08),
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
          child: Text(label, style: _sg(16, FontWeight.w600, fg)),
        ),
      ),
    );
  }
}
