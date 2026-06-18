import 'package:flutter/material.dart';

/// Convenience accessors so widgets write `context.primary` instead of
/// `Theme.of(context).colorScheme.primary` everywhere — and theme changes
/// propagate automatically because build() re-reads the value on every frame.
extension BuildContextThemeX on BuildContext {
  ColorScheme get colorScheme   => Theme.of(this).colorScheme;
  Color get primary             => Theme.of(this).colorScheme.primary;
  Color get onPrimary           => Theme.of(this).colorScheme.onPrimary;
  Color get primaryContainer    => Theme.of(this).colorScheme.primaryContainer;
  TextTheme get textTheme       => Theme.of(this).textTheme;

  // Lighter / darker shades derived from the current primary colour so that
  // gradients and focus rings also respond to theme changes.
  Color get primaryLight => Color.alphaBlend(
    Colors.white.withValues(alpha: 0.40),
    primary,
  );
  Color get primaryDark => Color.alphaBlend(
    Colors.black.withValues(alpha: 0.22),
    primary,
  );

  // ── Adaptive surface colours ─────────────────────────────────────────────
  // Use these instead of AppColors.* constants so the UI responds to dark mode.

  /// Page / scaffold background (light: #F5F7FA · dark: #0E1014)
  Color get bg => Theme.of(this).scaffoldBackgroundColor;

  /// Card and sheet background (light: white · dark: #1E222A)
  Color get cardBg => Theme.of(this).cardColor;

  /// App-bar background (light: white · dark: #181B21)
  Color get appBarBg =>
      Theme.of(this).appBarTheme.backgroundColor ??
      Theme.of(this).colorScheme.surface;

  /// Divider / border colour (light: #E5E7EB · dark: #2C313B)
  Color get borderCol => Theme.of(this).dividerColor;

  // ── Adaptive text colours ────────────────────────────────────────────────

  /// High-emphasis text (light: #0A0A1A · dark: #E7E9EE)
  Color get textPrimary => Theme.of(this).colorScheme.onSurface;

  /// Medium-emphasis text (light: #6B7280 · dark: #9BA1AD)
  Color get textSecondary => Theme.of(this).colorScheme.onSurfaceVariant;

  // ── Utility ──────────────────────────────────────────────────────────────
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
