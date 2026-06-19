import 'package:flutter/material.dart';

/// UNIFY premium semantic color tokens.
///
/// Every colour in the app should go through one of these accessors so that
/// light & dark mode changes propagate automatically via build() re-reads.
extension UnifyThemeX on BuildContext {
  // ── Scheme shortcuts ────────────────────────────────────────────────────
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get text     => Theme.of(this).textTheme;

  // ── Primary ─────────────────────────────────────────────────────────────
  Color get primary          => scheme.primary;
  Color get onPrimary        => scheme.onPrimary;
  Color get primaryContainer => scheme.primaryContainer;

  // Derived shades — always adapt to the current primary colour
  Color get primaryLight => Color.alphaBlend(
    Colors.white.withValues(alpha: 0.40), primary,
  );
  Color get primaryDark => Color.alphaBlend(
    Colors.black.withValues(alpha: 0.22), primary,
  );

  // ── Surface hierarchy ───────────────────────────────────────────────────
  /// Page background (light: #F8F9FB · dark: #0D0F13)
  Color get surfaceBg       => scheme.surfaceBright;
  /// Card & sheet background (light: #FFF · dark: #1E2128)
  Color get surfaceCard     => scheme.surface;
  /// Slightly elevated surface (light: #F4F5F8 · dark: #15171D)
  Color get surfaceElevated => scheme.surfaceContainerLow;
  /// Input, chip, tag fill (light: #F0F1F5 · dark: #1C1E26)
  Color get surfaceFill     => scheme.surfaceContainer;
  /// Muted surface for dividers (light: #E2E5EB · dark: #2B2F38)
  Color get surfaceDivider  => scheme.surfaceContainerHighest;
  /// Accent background for icons on tinted surfaces
  Color get surfaceAccent   => scheme.surfaceContainer;

  // Legacy aliases for migration
  Color get bg              => surfaceBg;
  Color get cardBg          => surfaceCard;
  Color get appBarBg        => Theme.of(this).appBarTheme.backgroundColor ?? scheme.surface;
  Color get borderCol       => scheme.outline;

  // ── Typography colours ──────────────────────────────────────────────────
  /// High-emphasis body text (light: #1A1D26 · dark: #E4E7ED)
  Color get textPrimary   => scheme.onSurface;
  /// Medium-emphasis / secondary text (light: #6C7284 · dark: #949BA8)
  Color get textSecondary => scheme.onSurfaceVariant;
  /// Inverse text (for snackbars, dark-on-light badges)
  Color get textInverse   => scheme.inverseSurface;
  /// Disabled / hint text
  Color get textDisabled  => scheme.onSurfaceVariant.withValues(alpha: 0.6);

  // ── Status semantic colours ─────────────────────────────────────────────
  Color get success => const Color(0xFF10B981);
  Color get warning => const Color(0xFFF59E0B);
  Color get error   => const Color(0xFFEF4444);
  Color get info    => const Color(0xFF3B82F6);

  // Dark-mode-safe status backgrounds
  Color get successBg => const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.10);
  Color get warningBg => const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.15 : 0.10);
  Color get errorBg   => const Color(0xFFEF4444).withValues(alpha: isDark ? 0.15 : 0.08);
  Color get infoBg    => const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.15 : 0.10);

  // ── Category colours ────────────────────────────────────────────────────
  Color get catUrgent   => const Color(0xFFEF4444);
  Color get catAcademic => primary;
  Color get catEvents   => const Color(0xFF8B5CF6);
  Color get catAdmin    => const Color(0xFFF59E0B);
  Color get catGeneral  => scheme.onSurfaceVariant;

  // ── Gradients — always use the current primary ──────────────────────────
  LinearGradient get gradientPrimary => LinearGradient(
    colors: [primaryLight, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get gradientHero => LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows — keyed by elevation level ──────────────────────────────────
  List<BoxShadow> get shadowXs => [
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.06), blurRadius: 4, offset: const Offset(0, 1)),
  ];
  List<BoxShadow> get shadowSm => [
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.09), blurRadius: 8, offset: const Offset(0, 2)),
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04), blurRadius: 2),
  ];
  List<BoxShadow> get shadowMd => [
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12), blurRadius: 16, offset: const Offset(0, 4)),
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 4, offset: const Offset(0, 1)),
  ];
  List<BoxShadow> get shadowLg => [
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.16), blurRadius: 24, offset: const Offset(0, 8)),
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06), blurRadius: 8, offset: const Offset(0, 2)),
  ];
  List<BoxShadow> get shadowCard => shadowSm;

  // ── Utility ─────────────────────────────────────────────────────────────
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
