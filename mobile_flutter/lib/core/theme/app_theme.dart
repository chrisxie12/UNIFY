import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_preset.dart';
import 'u_color_scheme.dart';

/// Premium Material 3 theme system for UNIFY.
///
/// Light theme → clean, airy, premium (Telegram/LinkedIn grade)
/// Dark theme  → deep, rich, moody (Discord/Notion grade)
class AppTheme {
  AppTheme._();

  // ── Light theme ──────────────────────────────────────────────────────────
  static ThemeData get light => buildFrom(ThemePreset.ocean);

  static ThemeData buildFrom(ThemePreset preset) {
    final cs = ColorScheme.fromSeed(
      seedColor: preset.primary,
      brightness: Brightness.light,
    ).copyWith(
      onSurface: const Color(0xFF1A1D26),
      onSurfaceVariant: const Color(0xFF6C7284),
      outline: const Color(0xFFE2E5EB),
      surface: const Color(0xFFFFFFFF),
      surfaceBright: const Color(0xFFF8F9FB),
      surfaceContainerLow: const Color(0xFFF4F5F8),
      surfaceContainer: const Color(0xFFF0F1F5),
      surfaceContainerHigh: const Color(0xFFEDEEF2),
      surfaceContainerHighest: const Color(0xFFE2E5EB),
      surfaceTint: Colors.transparent,
    );

    final textTheme = GoogleFonts.spaceGroteskTextTheme(ThemeData(colorScheme: cs).textTheme);

    final ucLight = UColorScheme.light.copyWith(borderStrong: preset.primary);
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: textTheme,
      scaffoldBackgroundColor: cs.surfaceBright,
      extensions: [ucLight],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,

      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E5EB), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: preset.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: preset.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ).copyWith(
          shadowColor: WidgetStatePropertyAll(preset.primary.withValues(alpha: 0.28)),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 50,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      cardTheme: CardThemeData(
        color: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outline, width: 0.5),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      dividerTheme: DividerThemeData(
        color: cs.outline,
        thickness: 0.5,
        space: 0,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: cs.inverseSurface,
        contentTextStyle: TextStyle(color: cs.onInverseSurface, fontSize: 13),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: cs.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainer,
        labelStyle: TextStyle(color: cs.onSurface, fontSize: 13),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: preset.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      badgeTheme: BadgeThemeData(
        backgroundColor: const Color(0xFFEF4444),
        textColor: Colors.white,
        smallSize: 8,
        largeSize: 18,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: preset.primary,
        inactiveTrackColor: cs.surfaceContainerHighest,
        thumbColor: preset.primary,
        overlayColor: preset.primary.withValues(alpha: 0.12),
        trackHeight: 4,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return preset.primary;
          return cs.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return preset.primary.withValues(alpha: 0.5);
          return cs.surfaceContainerHighest;
        }),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: preset.primary,
        linearTrackColor: cs.surfaceContainerHighest,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: preset.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorColor: preset.primary,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(cs.onSurfaceVariant.withValues(alpha: 0.3)),
        thickness: WidgetStatePropertyAll(4),
        radius: const Radius.circular(4),
      ),
    );
  }

  // ── Dark theme ────────────────────────────────────────────────────────────
  // Premium dark palette — Discord/Notion inspired depth
  static const Color _bg        = Color(0xFF0D0F13);
  static const Color _surface   = Color(0xFF15171D);
  static const Color _surface2  = Color(0xFF1C1E26);
  static const Color _card      = Color(0xFF1E2128);
  static const Color _border    = Color(0xFF2B2F38);
  static const Color _text      = Color(0xFFE4E7ED);
  static const Color _muted     = Color(0xFF949BA8);
  static const Color _accentBg  = Color(0xFF2A2F3A);

  static ThemeData get dark => buildDark(ThemePreset.ocean);

  static ThemeData buildDark(ThemePreset preset) {
    final cs = ColorScheme(
      brightness: Brightness.dark,
      primary: preset.primary,
      onPrimary: Colors.white,
      primaryContainer: preset.primary.withValues(alpha: 0.2),
      onPrimaryContainer: preset.primaryLight,
      secondary: const Color(0xFF9BA4B5),
      onSecondary: const Color(0xFF1A1D26),
      secondaryContainer: const Color(0xFF2B2F38),
      onSecondaryContainer: const Color(0xFFD0D5E0),
      tertiary: const Color(0xFFB4A0E8),
      onTertiary: const Color(0xFF2D1B4E),
      error: const Color(0xFFF87171),
      onError: const Color(0xFF290000),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: _surface,
      onSurface: _text,
      onSurfaceVariant: _muted,
      outline: _border,
      surfaceVariant: _surface2,
      inverseSurface: const Color(0xFFE4E7ED),
      onInverseSurface: const Color(0xFF0D0F13),
      inversePrimary: preset.primary,
      shadow: const Color(0xFF000000),
      surfaceTint: Colors.transparent,
    );

    final textTheme = GoogleFonts.spaceGroteskTextTheme(ThemeData(colorScheme: cs).textTheme)
        .apply(bodyColor: _text, displayColor: Colors.white);

    final ucDark = UColorScheme.dark.copyWith(borderStrong: preset.primaryLight);
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: textTheme,
      scaffoldBackgroundColor: _bg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      extensions: [ucDark],

      appBarTheme: AppBarTheme(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: _text,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: _text),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: preset.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1),
        ),
        hintStyle: TextStyle(color: _muted, fontSize: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: preset.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ).copyWith(
          shadowColor: WidgetStatePropertyAll(preset.primary.withValues(alpha: 0.3)),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 50,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      cardTheme: CardThemeData(
        color: _card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      dividerTheme: DividerThemeData(
        color: _border,
        thickness: 0.5,
        space: 0,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: _surface2,
        contentTextStyle: TextStyle(color: _text, fontSize: 13),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: _surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: _surface2,
        labelStyle: TextStyle(color: _text, fontSize: 13),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: preset.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      badgeTheme: BadgeThemeData(
        backgroundColor: const Color(0xFFF87171),
        textColor: Colors.white,
        smallSize: 8,
        largeSize: 18,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: preset.primary,
        inactiveTrackColor: _accentBg,
        thumbColor: preset.primary,
        overlayColor: preset.primary.withValues(alpha: 0.12),
        trackHeight: 4,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return preset.primary;
          return _muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return preset.primary.withValues(alpha: 0.5);
          return _accentBg;
        }),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: preset.primary,
        linearTrackColor: _accentBg,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: preset.primary,
        unselectedLabelColor: _muted,
        indicatorColor: preset.primary,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(_muted.withValues(alpha: 0.3)),
        thickness: WidgetStatePropertyAll(4),
        radius: const Radius.circular(4),
      ),
    );
  }
}
