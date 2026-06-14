import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Display
  static TextStyle get display => GoogleFonts.inter(
        fontSize: 40, fontWeight: FontWeight.w900,
        color: AppColors.dark, letterSpacing: -1.0, height: 1.1,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 32, fontWeight: FontWeight.w800,
        color: AppColors.dark, letterSpacing: -0.5, height: 1.15,
      );

  // Headings
  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 28, fontWeight: FontWeight.w800,
        color: AppColors.dark, letterSpacing: -0.5, height: 1.2,
      );

  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.w800,
        color: AppColors.dark, letterSpacing: -0.3,
      );

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: AppColors.dark,
      );

  // Semantic aliases used by feed screen
  static TextStyle get headingXL => h1;
  static TextStyle get headingL => h2;
  static TextStyle get headingM => h3;
  static TextStyle get headingS => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w700,
        color: AppColors.dark,
      );

  // Body
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: AppColors.grey1, height: 1.5,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.grey1, height: 1.5,
      );

  static TextStyle get bodySemi => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: AppColors.dark,
      );

  // Semantic body aliases
  static TextStyle get bodyL => bodyLarge;
  static TextStyle get bodyM => body;
  static TextStyle get bodyS => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: AppColors.grey2, height: 1.4,
      );

  // Labels
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: AppColors.dark,
      );

  static TextStyle get labelL => GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: AppColors.dark,
      );

  static TextStyle get labelM => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: AppColors.dark,
      );

  static TextStyle get labelS => GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w600,
        color: AppColors.grey2, letterSpacing: 0.3,
      );

  // Caption
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w400,
        color: AppColors.grey3, height: 1.4,
      );

  // Button
  static TextStyle get btn => GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      );

  static TextStyle get buttonL => GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w700,
        color: AppColors.white,
      );

  static TextStyle get buttonM => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: AppColors.white,
      );
}
