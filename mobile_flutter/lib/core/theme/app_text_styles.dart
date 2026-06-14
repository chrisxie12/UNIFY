import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get display => GoogleFonts.inter(
        fontSize: 34, fontWeight: FontWeight.w900,
        color: AppColors.dark, letterSpacing: -0.8, height: 1.1,
      );

  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 28, fontWeight: FontWeight.w800,
        color: AppColors.dark, letterSpacing: -0.5, height: 1.2,
      );

  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.w800,
        color: AppColors.dark, letterSpacing: -0.3,
      );

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 17, fontWeight: FontWeight.w700,
        color: AppColors.dark,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: AppColors.grey1, height: 1.5,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.grey2, height: 1.5,
      );

  static TextStyle get bodySemi => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: AppColors.dark,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: AppColors.grey3,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: AppColors.dark,
      );

  static TextStyle get btn => GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      );
}
