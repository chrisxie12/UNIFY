import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// UNIFY text styles — NO hardcoded colours. Colour is inherited from
/// DefaultTextStyle / TextTheme, or applied via .copyWith() at the call-site.
/// Prefer UText.* (core/design_system/typography.dart) for new code.
class AppTextStyles {
  AppTextStyles._();

  // Display
  static TextStyle get display => GoogleFonts.spaceGrotesk(
        fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.0, height: 1.1,
      );

  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
        fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.15,
      );

  // Headings
  static TextStyle get h1 => GoogleFonts.spaceGrotesk(
        fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.2,
      );

  static TextStyle get h2 => GoogleFonts.spaceGrotesk(
        fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3,
      );

  static TextStyle get h3 => GoogleFonts.spaceGrotesk(
        fontSize: 18, fontWeight: FontWeight.w700,
      );

  // Semantic aliases used by feed screen
  static TextStyle get headingXL => h1;
  static TextStyle get headingL => h2;
  static TextStyle get headingM => h3;
  static TextStyle get headingS => GoogleFonts.spaceGrotesk(
        fontSize: 16, fontWeight: FontWeight.w700,
      );

  // Body
  static TextStyle get bodyLarge => GoogleFonts.spaceGrotesk(
        fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
      );

  static TextStyle get body => GoogleFonts.spaceGrotesk(
        fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
      );

  static TextStyle get bodySemi => GoogleFonts.spaceGrotesk(
        fontSize: 14, fontWeight: FontWeight.w600,
      );

  // Semantic body aliases
  static TextStyle get bodyL => bodyLarge;
  static TextStyle get bodyM => body;
  static TextStyle get bodyS => GoogleFonts.spaceGrotesk(
        fontSize: 13, fontWeight: FontWeight.w400, height: 1.4,
      );

  // Labels
  static TextStyle get label => GoogleFonts.spaceGrotesk(
        fontSize: 13, fontWeight: FontWeight.w600,
      );

  static TextStyle get labelL => GoogleFonts.spaceGrotesk(
        fontSize: 15, fontWeight: FontWeight.w600,
      );

  static TextStyle get labelM => GoogleFonts.spaceGrotesk(
        fontSize: 13, fontWeight: FontWeight.w600,
      );

  static TextStyle get labelS => GoogleFonts.spaceGrotesk(
        fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3,
      );

  // Caption
  static TextStyle get caption => GoogleFonts.spaceGrotesk(
        fontSize: 11, fontWeight: FontWeight.w400, height: 1.4,
      );

  // Button
  static TextStyle get btn => GoogleFonts.spaceGrotesk(
        fontSize: 15, fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      );

  static TextStyle get buttonL => GoogleFonts.spaceGrotesk(
        fontSize: 15, fontWeight: FontWeight.w700,
      );

  static TextStyle get buttonM => GoogleFonts.spaceGrotesk(
        fontSize: 14, fontWeight: FontWeight.w600,
      );
}
