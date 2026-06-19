import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'theme_preset.dart';
import 'u_color_scheme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => buildFrom(ThemePreset.ocean);
  static ThemeData get dark  => buildDark(ThemePreset.ocean);

  // ── Light ─────────────────────────────────────────────────────────────────

  static ThemeData buildFrom(ThemePreset preset) {
    final uc = UColorScheme.light.copyWith(borderStrong: preset.primary);

    final cs = ColorScheme.fromSeed(
      seedColor: preset.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: preset.primary,
      onPrimary: uc.textInverse,
      surface: uc.surface1,
      onSurface: uc.textPrimary,
      onSurfaceVariant: uc.textSecondary,
      surfaceContainerLowest: uc.surface0,
      surfaceContainer: uc.surface1,
      surfaceContainerHigh: uc.surface2,
      surfaceContainerHighest: uc.surface2,
      error: uc.error,
      outline: uc.borderDefault,
      outlineVariant: uc.borderSubtle,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: uc.surface0,
      canvasColor: uc.surface1,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      extensions: [uc],
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: uc.textPrimary,
        displayColor: uc.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: uc.appBar,
        surfaceTintColor: uc.appBar,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: uc.textPrimary),
        titleTextStyle: TextStyle(
          color: uc.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: uc.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: uc.borderDefault, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: preset.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: uc.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: uc.error, width: 1.5),
        ),
        hintStyle: TextStyle(color: uc.textDisabled, fontSize: 14),
        labelStyle: TextStyle(color: uc.textSecondary, fontSize: 14),
        errorStyle: TextStyle(color: uc.error, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: preset.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: uc.borderDefault,
          disabledForegroundColor: uc.textDisabled,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: preset.primary,
          side: BorderSide(color: preset.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: preset.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: uc.surface1,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: uc.borderDefault, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: uc.borderDefault,
        thickness: 0.5,
        space: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: uc.surface3,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: uc.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
        contentTextStyle: TextStyle(
          color: uc.textSecondary,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: uc.surface2,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        modalElevation: 0,
        dragHandleColor: uc.borderDefault,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: uc.navBar,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        indicatorColor: preset.primary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: preset.primary, size: 24);
          }
          return IconThemeData(color: uc.textSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: preset.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: uc.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: uc.chipFill,
        selectedColor: preset.primary.withValues(alpha: 0.12),
        labelStyle: TextStyle(color: uc.textPrimary, fontSize: 13),
        side: BorderSide(color: uc.borderDefault, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.white : uc.textDisabled),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? preset.primary : uc.borderDefault),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? preset.primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: BorderSide(color: uc.borderDefault, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: preset.primary,
        linearTrackColor: uc.borderDefault,
        circularTrackColor: uc.borderDefault,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: preset.primary,
        unselectedLabelColor: uc.textSecondary,
        indicatorColor: preset.primary,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        dividerColor: uc.borderDefault,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: uc.textPrimary,
        contentTextStyle: TextStyle(color: uc.textInverse, fontSize: 13),
        actionTextColor: preset.primaryLight,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: uc.surface4,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: uc.borderDefault, width: 0.5),
        ),
        textStyle: TextStyle(color: uc.textPrimary, fontSize: 12),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: preset.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
        iconColor: uc.textSecondary,
        textColor: uc.textPrimary,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: uc.surface4,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: uc.borderDefault, width: 0.5),
        ),
        textStyle: TextStyle(color: uc.textPrimary, fontSize: 14),
      ),
    );
  }

  // ── Dark ──────────────────────────────────────────────────────────────────

  static ThemeData buildDark(ThemePreset preset) {
    final uc = UColorScheme.dark.copyWith(borderStrong: preset.primaryLight);

    final cs = ColorScheme.fromSeed(
      seedColor: preset.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: preset.primaryLight,
      onPrimary: uc.textInverse,
      surface: uc.surface1,
      onSurface: uc.textPrimary,
      onSurfaceVariant: uc.textSecondary,
      surfaceContainerLowest: uc.surface0,
      surfaceContainer: uc.surface1,
      surfaceContainerHigh: uc.surface2,
      surfaceContainerHighest: uc.surface3,
      error: uc.error,
      outline: uc.borderDefault,
      outlineVariant: uc.borderSubtle,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: uc.surface0,
      canvasColor: uc.surface1,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      extensions: [uc],
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: uc.textPrimary,
        displayColor: uc.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: uc.appBar,
        surfaceTintColor: uc.appBar,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: uc.textPrimary),
        titleTextStyle: TextStyle(
          color: uc.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: uc.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: uc.borderDefault, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: preset.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: uc.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: uc.error, width: 1.5),
        ),
        hintStyle: TextStyle(color: uc.textDisabled, fontSize: 14),
        labelStyle: TextStyle(color: uc.textSecondary, fontSize: 14),
        errorStyle: TextStyle(color: uc.error, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: preset.primaryLight,
          foregroundColor: uc.textInverse,
          disabledBackgroundColor: uc.borderDefault,
          disabledForegroundColor: uc.textDisabled,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: preset.primaryLight,
          side: BorderSide(color: preset.primaryLight, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: preset.primaryLight,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: uc.surface1,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: uc.borderDefault, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: uc.borderDefault,
        thickness: 0.5,
        space: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: uc.surface3,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: uc.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
        contentTextStyle: TextStyle(
          color: uc.textSecondary,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: uc.surface2,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        modalElevation: 0,
        dragHandleColor: uc.borderDefault,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: uc.navBar,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        indicatorColor: preset.primaryLight.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: preset.primaryLight, size: 24);
          }
          return IconThemeData(color: uc.textSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: preset.primaryLight,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: uc.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: uc.chipFill,
        selectedColor: preset.primaryLight.withValues(alpha: 0.20),
        labelStyle: TextStyle(color: uc.textPrimary, fontSize: 13),
        side: BorderSide(color: uc.borderDefault, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? uc.textInverse : uc.textDisabled),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? preset.primaryLight : uc.borderDefault),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? preset.primaryLight : Colors.transparent),
        checkColor: WidgetStateProperty.all(uc.textInverse),
        side: BorderSide(color: uc.borderDefault, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: preset.primaryLight,
        linearTrackColor: uc.borderDefault,
        circularTrackColor: uc.borderDefault,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: preset.primaryLight,
        unselectedLabelColor: uc.textSecondary,
        indicatorColor: preset.primaryLight,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        dividerColor: uc.borderDefault,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: uc.surface3,
        contentTextStyle: TextStyle(color: uc.textPrimary, fontSize: 13),
        actionTextColor: preset.primaryLight,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: uc.surface4,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: uc.borderDefault, width: 0.5),
        ),
        textStyle: TextStyle(color: uc.textPrimary, fontSize: 12),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: preset.primaryLight,
        foregroundColor: uc.textInverse,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
        iconColor: uc.textSecondary,
        textColor: uc.textPrimary,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: uc.surface4,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: uc.borderDefault, width: 0.5),
        ),
        textStyle: TextStyle(color: uc.textPrimary, fontSize: 14),
      ),
    );
  }
}
