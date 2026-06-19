import 'package:flutter/material.dart';
import '../theme/u_color_scheme.dart';

/// UNIFY premium semantic color tokens.
///
/// Every colour in the app should go through one of these accessors so that
/// light & dark mode changes propagate automatically via build() re-reads.
extension UnifyThemeX on BuildContext {
  // ── Scheme shortcuts ────────────────────────────────────────────────────
  ColorScheme get scheme     => Theme.of(this).colorScheme;
  TextTheme   get textTheme  => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme; // compat alias

  // ── Primary ─────────────────────────────────────────────────────────────
  Color get primary          => scheme.primary;
  Color get onPrimary        => scheme.onPrimary;
  Color get primaryContainer => scheme.primaryContainer;

  Color get primaryLight => Color.alphaBlend(
    Colors.white.withValues(alpha: 0.40), primary,
  );
  Color get primaryDark => Color.alphaBlend(
    Colors.black.withValues(alpha: 0.22), primary,
  );

  // ── Surface hierarchy ───────────────────────────────────────────────────
  /// Page background
  Color get surfaceBg       => scheme.surfaceBright;
  /// Card & sheet background
  Color get surfaceCard     => scheme.surface;
  /// Slightly elevated surface
  Color get surfaceElevated => scheme.surfaceContainerLow;
  /// Input, chip, tag fill
  Color get surfaceFill     => scheme.surfaceContainer;
  /// Muted surface for dividers
  Color get surfaceDivider  => scheme.surfaceContainerHighest;

  // Shorthand aliases used by existing screens
  Color get bg        => surfaceBg;
  Color get cardBg    => surfaceCard;
  Color get sheetBg   => scheme.surfaceContainerHigh;
  Color get dialogBg  => scheme.surfaceContainerHigh;
  Color get navBarBg  => surfaceCard;
  Color get appBarBg  => Theme.of(this).appBarTheme.backgroundColor ?? scheme.surface;
  Color get inputFill => surfaceFill;
  Color get borderCol => scheme.outline;
  Color get borderSubtle => scheme.outlineVariant;

  // ── Typography colours ──────────────────────────────────────────────────
  Color get textPrimary   => scheme.onSurface;
  Color get textSecondary => scheme.onSurfaceVariant;
  Color get textDisabled  => scheme.onSurfaceVariant.withValues(alpha: 0.6);
  Color get textInverse   => scheme.inverseSurface;

  // ── Status semantic colours ─────────────────────────────────────────────
  Color get success => const Color(0xFF10B981);
  Color get warning => const Color(0xFFF59E0B);
  Color get error   => const Color(0xFFEF4444);
  Color get info    => const Color(0xFF3B82F6);

  // compat aliases
  Color get successColor => success;
  Color get warningColor => warning;
  Color get errorColor   => error;
  Color get infoColor    => info;

  // Dark-mode-safe status backgrounds
  Color get successBg      => success.withValues(alpha: isDark ? 0.15 : 0.10);
  Color get warningBg      => warning.withValues(alpha: isDark ? 0.15 : 0.10);
  Color get errorBg        => error.withValues(alpha: isDark ? 0.15 : 0.08);
  Color get infoBg         => info.withValues(alpha: isDark ? 0.15 : 0.10);
  Color get successSurface => successBg;
  Color get warningSurface => warningBg;
  Color get errorSurface   => errorBg;
  Color get infoSurface    => infoBg;

  // ── Category colours ────────────────────────────────────────────────────
  Color get catUrgent   => const Color(0xFFEF4444);
  Color get catAcademic => primary;
  Color get catEvents   => const Color(0xFF8B5CF6);
  Color get catAdmin    => const Color(0xFFF59E0B);
  Color get catGeneral  => scheme.onSurfaceVariant;

  // ── Gradients ──────────────────────────────────────────────────────────
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

  // ── Shadows ─────────────────────────────────────────────────────────────
  List<BoxShadow> get shadowXs => [
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.06), blurRadius: 4, offset: const Offset(0, 1)),
  ];
  List<BoxShadow> get shadowSm => [
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.09), blurRadius: 8, offset: const Offset(0, 2)),
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04), blurRadius: 2),
  ];
  List<BoxShadow> get shadowMd => [
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12), blurRadius: 16, offset: const Offset(0, 4)),
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05), blurRadius: 4, offset: const Offset(0, 1)),
  ];
  List<BoxShadow> get shadowLg => [
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.16), blurRadius: 24, offset: const Offset(0, 8)),
    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06), blurRadius: 8, offset: const Offset(0, 2)),
  ];
  List<BoxShadow> get shadowCard => shadowSm;

  // ── Shimmer (from UColorScheme) ─────────────────────────────────────────
  UColorScheme get uColors =>
      Theme.of(this).extension<UColorScheme>() ?? UColorScheme.light;

  Color get shimmerBase      => uColors.shimmerBase;
  Color get shimmerHighlight => uColors.shimmerHighlight;

  // ── Chat bubbles ─────────────────────────────────────────────────────────
  Color get chatOwnBubble   => uColors.chatOwn;
  Color get chatOtherBubble => uColors.chatOther;
  Color get chatOwnText     => uColors.chatOwnText;
  Color get chatOtherText   => uColors.chatOtherText;

  // ── Utility ─────────────────────────────────────────────────────────────
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
