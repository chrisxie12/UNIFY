import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // GCTU Brand
  static const primary     = Color(0xFF003F8A);  // GCTU navy
  static const primaryLight= Color(0xFF1D4ED8);
  static const primaryDark = Color(0xFF1E3A8A);

  // Gradient
  static const gradientStart = Color(0xFF1D4ED8);
  static const gradientEnd   = Color(0xFF003F8A);

  // Neutrals
  static const dark      = Color(0xFF111827);
  static const grey1     = Color(0xFF374151);
  static const grey2     = Color(0xFF6B7280);
  static const grey3     = Color(0xFF9CA3AF);
  static const border    = Color(0xFFE5E7EB);
  static const surface   = Color(0xFFF3F4F6);
  static const surfaceAlt= Color(0xFFF9FAFB);
  static const white     = Color(0xFFFFFFFF);

  // Semantic
  static const success   = Color(0xFF10B981);
  static const warning   = Color(0xFFF59E0B);
  static const error     = Color(0xFFEF4444);
  static const info      = Color(0xFF3B82F6);

  // Category colours (announcements)
  static const catAcademic = Color(0xFF1D4ED8);
  static const catEvents   = Color(0xFF8B5CF6);
  static const catAdmin    = Color(0xFFF59E0B);
  static const catGeneral  = Color(0xFF6B7280);
  static const catUrgent   = Color(0xFFEF4444);

  static const gradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static Color categoryColor(String cat) => switch (cat) {
    'academic' => catAcademic,
    'events'   => catEvents,
    'admin'    => catAdmin,
    'urgent'   => catUrgent,
    _          => catGeneral,
  };
}
