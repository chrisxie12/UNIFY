import 'package:flutter/material.dart';

enum AppThemeId { ocean, violet, forest, sunset, rose, teal }

class ThemePreset {
  final AppThemeId id;
  final String name;
  final String emoji;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.emoji,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
  });

  LinearGradient get gradient => LinearGradient(
        colors: [primaryLight, primaryDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static const ocean = ThemePreset(
    id: AppThemeId.ocean,
    name: 'Ocean',
    emoji: '🌊',
    primary: Color(0xFF003F8A),
    primaryLight: Color(0xFF1D5BB5),
    primaryDark: Color(0xFF002D63),
  );
  static const violet = ThemePreset(
    id: AppThemeId.violet,
    name: 'Violet',
    emoji: '🔮',
    primary: Color(0xFF5B21B6),
    primaryLight: Color(0xFF7C3AED),
    primaryDark: Color(0xFF3B0764),
  );
  static const forest = ThemePreset(
    id: AppThemeId.forest,
    name: 'Forest',
    emoji: '🌿',
    primary: Color(0xFF065F46),
    primaryLight: Color(0xFF059669),
    primaryDark: Color(0xFF064E3B),
  );
  static const sunset = ThemePreset(
    id: AppThemeId.sunset,
    name: 'Sunset',
    emoji: '🌅',
    primary: Color(0xFFC2410C),
    primaryLight: Color(0xFFEA580C),
    primaryDark: Color(0xFF9A3412),
  );
  static const rose = ThemePreset(
    id: AppThemeId.rose,
    name: 'Rose',
    emoji: '🌸',
    primary: Color(0xFFBE185D),
    primaryLight: Color(0xFFDB2777),
    primaryDark: Color(0xFF831843),
  );
  static const teal = ThemePreset(
    id: AppThemeId.teal,
    name: 'Teal',
    emoji: '🌀',
    primary: Color(0xFF0F766E),
    primaryLight: Color(0xFF0D9488),
    primaryDark: Color(0xFF115E59),
  );

  static const all = [ocean, violet, forest, sunset, rose, teal];
}
