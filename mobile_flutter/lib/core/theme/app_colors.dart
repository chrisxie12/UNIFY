import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand — UNIFY Blue
  static const Color primary      = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark  = Color(0xFF1D4ED8);

  // Accent (alias for primary in this design)
  static const Color accent = primary;

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF3B82F6);

  // Neutrals
  static const Color dark       = Color(0xFF0A0A1A);
  static const Color grey1      = Color(0xFF374151);
  static const Color grey2      = Color(0xFF6B7280);
  static const Color grey3      = Color(0xFF9CA3AF);
  static const Color grey4      = Color(0xFFD1D5DB);
  static const Color border     = Color(0xFFE5E7EB);
  static const Color surface    = Color(0xFFF3F4F6);
  static const Color background = Color(0xFFF5F7FA);
  static const Color white      = Color(0xFFFFFFFF);

  // Legacy aliases
  static const Color surfaceAlt = background;

  // Reusable card shadow used across all card widgets
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x09000000), blurRadius: 12, offset: Offset(0, 3)),
    BoxShadow(color: Color(0x05000000), blurRadius: 4),
  ];

  // Category colours
  static const Color catUrgent   = Color(0xFFEF4444);
  static const Color catAcademic = primary;
  static const Color catEvents   = Color(0xFF8B5CF6);
  static const Color catAdmin    = Color(0xFFF59E0B);
  static const Color catGeneral  = Color(0xFF6B7280);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient brandGradientDiag = LinearGradient(
    colors: [primaryLight, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy alias
  static const LinearGradient gradient = brandGradient;

  static Color categoryColor(String category) {
    switch (category) {
      case 'urgent':   return catUrgent;
      case 'academic': return catAcademic;
      case 'events':   return catEvents;
      case 'admin':    return catAdmin;
      default:         return catGeneral;
    }
  }

  static String categoryIcon(String category) {
    switch (category) {
      case 'academic': return '📚';
      case 'events':   return '🎉';
      case 'admin':    return '🏛️';
      case 'urgent':   return '🚨';
      default:         return '📢';
    }
  }
}
