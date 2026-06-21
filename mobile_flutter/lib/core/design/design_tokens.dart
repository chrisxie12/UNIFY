import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════════
// UNIFY Design System — Tokens
// ═══════════════════════════════════════════════════════════════════════════

// ── Colors ────────────────────────────────────────────────────────────────

class UnifyColors {
  UnifyColors._();

  // Brand
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentTeal = Color(0xFF14B8A6);

  // Surfaces
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF8FAFC);
  static const Color surfaceElevated = Color(0xFFF1F5F9);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceDarker = Color(0xFF1A1A2E);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF5A5A6E);

  // Functional
  static const Color divider = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color onlineGreen = Color(0xFF22C55E);
}

// ── Spacing ───────────────────────────────────────────────────────────────

class UnifySpacing {
  UnifySpacing._();
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
}

// ── Radius ────────────────────────────────────────────────────────────────

class UnifyRadius {
  UnifyRadius._();
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 999.0;
}

// ── Shadows ───────────────────────────────────────────────────────────────

class UnifyShadows {
  UnifyShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> float = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 25, offset: Offset(0, 10)),
  ];
}

// ── Animation Tokens ──────────────────────────────────────────────────────

class UnifyAnim {
  UnifyAnim._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration enter = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 3000);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve spring = Curves.elasticOut;
  static const Curve decelerate = Curves.decelerate;
}

// ── Typography ────────────────────────────────────────────────────────────

class UnifyTextStyle {
  UnifyTextStyle._();

  static TextStyle display({Color color = UnifyColors.textInverse}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        height: 1.0,
        color: color,
      );

  static TextStyle h1({Color color = UnifyColors.textPrimary}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.2,
        color: color,
      );

  static TextStyle h2({Color color = UnifyColors.textPrimary}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.3,
        color: color,
      );

  static TextStyle h3({Color color = UnifyColors.textPrimary}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.4,
        color: color,
      );

  static TextStyle h4({Color color = UnifyColors.textPrimary}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.4,
        color: color,
      );

  static TextStyle body({Color color = UnifyColors.textSecondary}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodySm({Color color = UnifyColors.textTertiary}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  static TextStyle caption({Color color = UnifyColors.textTertiary}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
        color: color,
      );

  static TextStyle micro({Color color = UnifyColors.textMuted}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.3,
        color: color,
      );
}
