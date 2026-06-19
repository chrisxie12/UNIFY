import 'package:flutter/material.dart';
import '../theme/u_color_scheme.dart';

/// Convenience accessors so widgets write `context.primary` instead of
/// `Theme.of(context).colorScheme.primary` everywhere.
extension BuildContextThemeX on BuildContext {
  // ── Core Material 3 ───────────────────────────────────────────────────────
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Color get primary           => Theme.of(this).colorScheme.primary;
  Color get onPrimary         => Theme.of(this).colorScheme.onPrimary;
  Color get primaryContainer  => Theme.of(this).colorScheme.primaryContainer;
  TextTheme get textTheme     => Theme.of(this).textTheme;

  Color get primaryLight => Color.alphaBlend(
    Colors.white.withValues(alpha: 0.40),
    primary,
  );
  Color get primaryDark => Color.alphaBlend(
    Colors.black.withValues(alpha: 0.22),
    primary,
  );

  // ── UNIFY semantic colours (via ThemeExtension) ───────────────────────────
  /// Full UNIFY colour scheme. Prefer shortcuts below for common uses.
  UColorScheme get uColors =>
      Theme.of(this).extension<UColorScheme>() ?? UColorScheme.light;

  // ── Surfaces ──────────────────────────────────────────────────────────────
  /// Page / scaffold background.
  Color get bg => uColors.surface0;

  /// Card, tile, standard container background.
  Color get cardBg => uColors.surface1;

  /// Bottom sheet / drawer background.
  Color get sheetBg => uColors.surface2;

  /// Dialog background.
  Color get dialogBg => uColors.surface3;

  /// App-bar background.
  Color get appBarBg => uColors.appBar;

  /// Bottom nav bar background.
  Color get navBarBg => uColors.navBar;

  /// Text-field / input fill colour.
  Color get inputFill => uColors.inputFill;

  // ── Borders ───────────────────────────────────────────────────────────────
  /// Standard divider / card outline colour.
  Color get borderCol => uColors.borderDefault;

  /// Very light separator (list items).
  Color get borderSubtle => uColors.borderSubtle;

  // ── Text ──────────────────────────────────────────────────────────────────
  /// High-emphasis headings and body copy.
  Color get textPrimary => uColors.textPrimary;

  /// Medium-emphasis subtitles and metadata.
  Color get textSecondary => uColors.textSecondary;

  /// Placeholder / disabled text.
  Color get textDisabled => uColors.textDisabled;

  // ── Status ────────────────────────────────────────────────────────────────
  Color get successColor  => uColors.success;
  Color get warningColor  => uColors.warning;
  Color get errorColor    => uColors.error;
  Color get infoColor     => uColors.info;

  Color get successSurface => uColors.successSurface;
  Color get warningSurface => uColors.warningSurface;
  Color get errorSurface   => uColors.errorSurface;
  Color get infoSurface    => uColors.infoSurface;

  // ── Shimmer ───────────────────────────────────────────────────────────────
  Color get shimmerBase      => uColors.shimmerBase;
  Color get shimmerHighlight => uColors.shimmerHighlight;

  // ── Chat ──────────────────────────────────────────────────────────────────
  Color get chatOwnBubble   => uColors.chatOwn;
  Color get chatOtherBubble => uColors.chatOther;
  Color get chatOwnText     => uColors.chatOwnText;
  Color get chatOtherText   => uColors.chatOtherText;

  // ── Utility ───────────────────────────────────────────────────────────────
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
