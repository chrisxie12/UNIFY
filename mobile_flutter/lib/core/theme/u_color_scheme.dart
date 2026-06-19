import 'dart:ui';
import 'package:flutter/material.dart';

/// UNIFY semantic colour extension — attached to both light and dark [ThemeData].
///
/// Access via [BuildContext.uColors] (defined in theme_extensions.dart).
/// Flutter lerps between light and dark presets during animated theme switches.
@immutable
class UColorScheme extends ThemeExtension<UColorScheme> {
  const UColorScheme({
    required this.surface0,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.surface4,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textInverse,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.ripple,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.successSurface,
    required this.warningSurface,
    required this.errorSurface,
    required this.infoSurface,
    required this.navBar,
    required this.appBar,
    required this.inputFill,
    required this.chipFill,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.chatOwn,
    required this.chatOther,
    required this.chatOwnText,
    required this.chatOtherText,
  });

  // ── Surface hierarchy ─────────────────────────────────────────────────────
  /// Page / scaffold background. Bottommost layer.
  final Color surface0;

  /// Cards, list tiles, standard containers.
  final Color surface1;

  /// Bottom sheets, drawers, side panels.
  final Color surface2;

  /// Dialogs, popovers, modals.
  final Color surface3;

  /// Menus, tooltips, floating pickers.
  final Color surface4;

  // ── Text ──────────────────────────────────────────────────────────────────
  /// Headings, body copy, primary content text.
  final Color textPrimary;

  /// Subtitles, metadata, secondary content.
  final Color textSecondary;

  /// Placeholders, disabled labels.
  final Color textDisabled;

  /// Text drawn on coloured backgrounds (buttons, badges).
  final Color textInverse;

  // ── Borders / dividers ────────────────────────────────────────────────────
  /// Very light rule — separates list items.
  final Color borderSubtle;

  /// Standard card outline, form field border.
  final Color borderDefault;

  /// Focused / selected / active border.
  final Color borderStrong;

  // ── Interactive ───────────────────────────────────────────────────────────
  /// Tap ripple / press highlight.
  final Color ripple;

  // ── Status ────────────────────────────────────────────────────────────────
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  /// Low-saturation tinted backgrounds for status banners / chips.
  final Color successSurface;
  final Color warningSurface;
  final Color errorSurface;
  final Color infoSurface;

  // ── Named surfaces ────────────────────────────────────────────────────────
  final Color navBar;
  final Color appBar;
  final Color inputFill;
  final Color chipFill;

  // ── Shimmer ───────────────────────────────────────────────────────────────
  final Color shimmerBase;
  final Color shimmerHighlight;

  // ── Chat bubbles ──────────────────────────────────────────────────────────
  final Color chatOwn;
  final Color chatOther;
  final Color chatOwnText;
  final Color chatOtherText;

  // ── Presets ───────────────────────────────────────────────────────────────

  /// Premium light theme — clean whites, neutral surfaces, UNIFY blue accents.
  static const light = UColorScheme(
    // Surfaces
    surface0: Color(0xFFF5F7FA),
    surface1: Color(0xFFFFFFFF),
    surface2: Color(0xFFFFFFFF),
    surface3: Color(0xFFFFFFFF),
    surface4: Color(0xFFF8F9FB),
    // Text
    textPrimary: Color(0xFF0F1117),
    textSecondary: Color(0xFF6B7280),
    textDisabled: Color(0xFF9CA3AF),
    textInverse: Color(0xFFFFFFFF),
    // Borders
    borderSubtle: Color(0x0D000000),   // 5% black
    borderDefault: Color(0xFFE5E7EB),
    borderStrong: Color(0xFF0066FF),
    // Interactive
    ripple: Color(0x0A000000),          // 4% black
    // Status
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
    successSurface: Color(0xFFECFDF5),
    warningSurface: Color(0xFFFFFBEB),
    errorSurface: Color(0xFFFEF2F2),
    infoSurface: Color(0xFFEFF6FF),
    // Named
    navBar: Color(0xFFFFFFFF),
    appBar: Color(0xFFFFFFFF),
    inputFill: Color(0xFFF3F4F6),
    chipFill: Color(0xFFF0F2F5),
    // Shimmer
    shimmerBase: Color(0xFFE9EAEC),
    shimmerHighlight: Color(0xFFF6F7F8),
    // Chat
    chatOwn: Color(0xFF0066FF),
    chatOther: Color(0xFFFFFFFF),
    chatOwnText: Color(0xFFFFFFFF),
    chatOtherText: Color(0xFF0F1117),
  );

  /// Premium dark theme — deep charcoal surfaces, high-contrast text.
  /// Inspired by Telegram, Discord, and Notion dark modes.
  static const dark = UColorScheme(
    // Surfaces (each layer +6-8% lighter than previous)
    surface0: Color(0xFF0D0F14),   // page background
    surface1: Color(0xFF161920),   // cards, tiles
    surface2: Color(0xFF1C1F28),   // bottom sheets, drawers
    surface3: Color(0xFF22263A),   // dialogs
    surface4: Color(0xFF2A2E40),   // menus, tooltips
    // Text
    textPrimary: Color(0xFFECEEF4),
    textSecondary: Color(0xFF8892A4),
    textDisabled: Color(0xFF4B5568),
    textInverse: Color(0xFF0F1117),
    // Borders
    borderSubtle: Color(0x0CFFFFFF),   // 5% white
    borderDefault: Color(0xFF252B38),
    borderStrong: Color(0xFF4A90FF),
    // Interactive
    ripple: Color(0x0DFFFFFF),          // 5% white
    // Status (lighter/brighter for dark bg)
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    info: Color(0xFF60A5FA),
    successSurface: Color(0xFF0D2B22),
    warningSurface: Color(0xFF271E03),
    errorSurface: Color(0xFF2D0F0F),
    infoSurface: Color(0xFF0E1E35),
    // Named
    navBar: Color(0xFF161920),
    appBar: Color(0xFF161920),
    inputFill: Color(0xFF1C1F28),
    chipFill: Color(0xFF22263A),
    // Shimmer
    shimmerBase: Color(0xFF1C1F28),
    shimmerHighlight: Color(0xFF262B38),
    // Chat
    chatOwn: Color(0xFF1A5DC8),    // slightly muted blue — easier on eyes
    chatOther: Color(0xFF1C1F28),
    chatOwnText: Color(0xFFFFFFFF),
    chatOtherText: Color(0xFFECEEF4),
  );

  // ── ThemeExtension API ────────────────────────────────────────────────────

  @override
  UColorScheme copyWith({
    Color? surface0,
    Color? surface1,
    Color? surface2,
    Color? surface3,
    Color? surface4,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? textInverse,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? ripple,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? successSurface,
    Color? warningSurface,
    Color? errorSurface,
    Color? infoSurface,
    Color? navBar,
    Color? appBar,
    Color? inputFill,
    Color? chipFill,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? chatOwn,
    Color? chatOther,
    Color? chatOwnText,
    Color? chatOtherText,
  }) =>
      UColorScheme(
        surface0: surface0 ?? this.surface0,
        surface1: surface1 ?? this.surface1,
        surface2: surface2 ?? this.surface2,
        surface3: surface3 ?? this.surface3,
        surface4: surface4 ?? this.surface4,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textDisabled: textDisabled ?? this.textDisabled,
        textInverse: textInverse ?? this.textInverse,
        borderSubtle: borderSubtle ?? this.borderSubtle,
        borderDefault: borderDefault ?? this.borderDefault,
        borderStrong: borderStrong ?? this.borderStrong,
        ripple: ripple ?? this.ripple,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        error: error ?? this.error,
        info: info ?? this.info,
        successSurface: successSurface ?? this.successSurface,
        warningSurface: warningSurface ?? this.warningSurface,
        errorSurface: errorSurface ?? this.errorSurface,
        infoSurface: infoSurface ?? this.infoSurface,
        navBar: navBar ?? this.navBar,
        appBar: appBar ?? this.appBar,
        inputFill: inputFill ?? this.inputFill,
        chipFill: chipFill ?? this.chipFill,
        shimmerBase: shimmerBase ?? this.shimmerBase,
        shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
        chatOwn: chatOwn ?? this.chatOwn,
        chatOther: chatOther ?? this.chatOther,
        chatOwnText: chatOwnText ?? this.chatOwnText,
        chatOtherText: chatOtherText ?? this.chatOtherText,
      );

  @override
  UColorScheme lerp(UColorScheme? other, double t) {
    if (other == null) return this;
    return UColorScheme(
      surface0: Color.lerp(surface0, other.surface0, t)!,
      surface1: Color.lerp(surface1, other.surface1, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      surface4: Color.lerp(surface4, other.surface4, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      ripple: Color.lerp(ripple, other.ripple, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      errorSurface: Color.lerp(errorSurface, other.errorSurface, t)!,
      infoSurface: Color.lerp(infoSurface, other.infoSurface, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
      appBar: Color.lerp(appBar, other.appBar, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      chipFill: Color.lerp(chipFill, other.chipFill, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      chatOwn: Color.lerp(chatOwn, other.chatOwn, t)!,
      chatOther: Color.lerp(chatOther, other.chatOther, t)!,
      chatOwnText: Color.lerp(chatOwnText, other.chatOwnText, t)!,
      chatOtherText: Color.lerp(chatOtherText, other.chatOtherText, t)!,
    );
  }
}
