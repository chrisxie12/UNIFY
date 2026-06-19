import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// UNIFY Design System — Typography scale.
/// Always use context.textTheme or UText.* rather than raw TextStyle literals.
/// All styles use Space Grotesk. Colours are intentionally omitted so they
/// inherit from ThemeData.textTheme (which handles dark mode automatically).
class UText {
  UText._();

  // ── Display ──────────────────────────────────────────────────────────────
  /// 40px · w900 · -1.0 tracking · 1.1 height
  static TextStyle get displayXL => GoogleFonts.spaceGrotesk(
        fontSize: 40, fontWeight: FontWeight.w900,
        letterSpacing: -1.0, height: 1.1,
      );

  /// 32px · w800 · -0.5 tracking · 1.15 height
  static TextStyle get display => GoogleFonts.spaceGrotesk(
        fontSize: 32, fontWeight: FontWeight.w800,
        letterSpacing: -0.5, height: 1.15,
      );

  // ── Headings ─────────────────────────────────────────────────────────────
  /// 24px · w800 · -0.3 tracking
  static TextStyle get h1 => GoogleFonts.spaceGrotesk(
        fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.3,
      );

  /// 20px · w700
  static TextStyle get h2 => GoogleFonts.spaceGrotesk(
        fontSize: 20, fontWeight: FontWeight.w700,
      );

  /// 18px · w700
  static TextStyle get h3 => GoogleFonts.spaceGrotesk(
        fontSize: 18, fontWeight: FontWeight.w700,
      );

  /// 16px · w600
  static TextStyle get h4 => GoogleFonts.spaceGrotesk(
        fontSize: 16, fontWeight: FontWeight.w600,
      );

  // ── Body ─────────────────────────────────────────────────────────────────
  /// 16px · w400 · 1.55 height
  static TextStyle get bodyL => GoogleFonts.spaceGrotesk(
        fontSize: 16, fontWeight: FontWeight.w400, height: 1.55,
      );

  /// 15px · w400 · 1.5 height  — primary body copy
  static TextStyle get body => GoogleFonts.spaceGrotesk(
        fontSize: 15, fontWeight: FontWeight.w400, height: 1.5,
      );

  /// 14px · w400 · 1.5 height
  static TextStyle get bodyS => GoogleFonts.spaceGrotesk(
        fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
      );

  /// 13px · w400 · 1.4 height  — fine print / metadata
  static TextStyle get bodyXS => GoogleFonts.spaceGrotesk(
        fontSize: 13, fontWeight: FontWeight.w400, height: 1.4,
      );

  // ── Labels ───────────────────────────────────────────────────────────────
  /// 15px · w600 — strong label
  static TextStyle get labelL => GoogleFonts.spaceGrotesk(
        fontSize: 15, fontWeight: FontWeight.w600,
      );

  /// 14px · w600 — standard label / subtitle
  static TextStyle get label => GoogleFonts.spaceGrotesk(
        fontSize: 14, fontWeight: FontWeight.w600,
      );

  /// 13px · w600 — small label
  static TextStyle get labelS => GoogleFonts.spaceGrotesk(
        fontSize: 13, fontWeight: FontWeight.w600,
      );

  /// 12px · w700 · 0.4 tracking — overline / badge text
  static TextStyle get overline => GoogleFonts.spaceGrotesk(
        fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4,
      );

  // ── Caption / Meta ────────────────────────────────────────────────────────
  /// 12px · w500 · 0.2 tracking
  static TextStyle get caption => GoogleFonts.spaceGrotesk(
        fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.2,
      );

  /// 11px · w500
  static TextStyle get tiny => GoogleFonts.spaceGrotesk(
        fontSize: 11, fontWeight: FontWeight.w500,
      );

  // ── Buttons ───────────────────────────────────────────────────────────────
  /// 15px · w700 — primary button label
  static TextStyle get btnL => GoogleFonts.spaceGrotesk(
        fontSize: 15, fontWeight: FontWeight.w700,
      );

  /// 14px · w600 — secondary / small button
  static TextStyle get btnS => GoogleFonts.spaceGrotesk(
        fontSize: 14, fontWeight: FontWeight.w600,
      );
}
