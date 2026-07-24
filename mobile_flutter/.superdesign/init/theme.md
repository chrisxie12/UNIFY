# Design System / Theme

## Design Tokens File
**File**: `lib/core/design/design_tokens.dart`

### UnifyColors (Brand Colors)
```dart
class UnifyColors {
  // Brand
  static const Color primaryBlue   = Color(0xFF2563EB);
  static const Color primaryDark   = Color(0xFF1D4ED8);
  static const Color primaryLight  = Color(0xFF3B82F6);
  static const Color accentPurple  = Color(0xFF7C3AED);
  static const Color accentTeal    = Color(0xFF14B8A6);

  // Surfaces
  static const Color surfaceWhite    = Color(0xFFFFFFFF);
  static const Color surfaceGrey     = Color(0xFFF8FAFC);
  static const Color surfaceElevated = Color(0xFFF1F5F9);
  static const Color surfaceDark     = Color(0xFF0F172A);
  static const Color surfaceDarker   = Color(0xFF1A1A2E);

  // Text
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary  = Color(0xFF94A3B8);
  static const Color textInverse   = Color(0xFFFFFFFF);
  static const Color textMuted     = Color(0xFF5A5A6E);

  // Functional
  static const Color divider      = Color(0xFFE2E8F0);
  static const Color success      = Color(0xFF10B981);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color error        = Color(0xFFEF4444);
  static const Color onlineGreen  = Color(0xFF22C55E);
}
```

### Typography (Space Grotesk — ALL text)
```dart
class UnifyTextStyle {
  display({color: textInverse})   → 40px, w700, -1.5ls, 1.0h
  h1({color: textPrimary})        → 32px, w700, -1.0ls, 1.2h
  h2({color: textPrimary})        → 24px, w700, -0.5ls, 1.3h
  h3({color: textPrimary})        → 20px, w600, -0.3ls, 1.4h
  h4({color: textPrimary})        → 18px, w600, -0.2ls, 1.4h
  body({color: textSecondary})    → 16px, w400,  0ls,  1.5h
  bodySm({color: textTertiary})   → 14px, w400,  0ls,  1.4h
  caption({color: textTertiary})  → 12px, w500,  0.5ls, 1.4h
  micro({color: textMuted})       → 11px, w600,  0.5ls, 1.3h
}
```

### Spacing
```dart
class UnifySpacing {
  s4=4,  s8=8,  s12=12,  s16=16,  s20=20,  s24=24,  s32=32,  s40=40,  s48=48
}
```

### Border Radius
```dart
class UnifyRadius {
  sm=8,  md=12,  lg=16,  xl=24,  xxl=32,  full=999
}
```

### Shadows
```dart
class UnifyShadows {
  sm:     0,1, blur 4,  rgba(0,0,0,0.06)
  md:     0,4, blur 8,  rgba(0,0,0,0.08)
  lg:     0,8, blur 20, rgba(0,0,0,0.10)
  float:  0,10, blur 25,rgba(0,0,0,0.12)
}
```

### Animation Tokens
```dart
class UnifyAnim {
  fast=150ms,  normal=250ms,  slow=400ms,  enter=500ms,  splash=3000ms
  easeOut: Curves.easeOutCubic
  easeInOut: Curves.easeInOutCubic
  spring: Curves.elasticOut
  decelerate: Curves.decelerate
}
```

## AppTheme (Material 3 Theme)
**File**: `lib/core/theme/app_theme.dart`

- Uses `ColorScheme.fromSeed(seedColor: preset.primary)`
- Light theme: clean, airy, premium (Telegram/LinkedIn grade)
- Dark theme: deep, rich, moody (Discord/Notion grade)
- All text: GoogleFonts.spaceGroteskTextTheme
- AppBar: transparent bg, no elevation, centered title
- Inputs: filled surfaceContainer bg, 14px border radius
- Buttons: full-width 52px height, 14px radius
- Nav bar: 50px height, 28px indicator radius
- ThemePreset system: 6 presets (ocean default), persisted via ThemeNotifier (Riverpod)

## Theme Extensions
**File**: `lib/core/extensions/theme_extensions.dart`

`UnifyThemeX` on `BuildContext`:
```dart
context.scheme        → ColorScheme
context.primary       → scheme.primary
context.surfaceBg     → scheme.surfaceBright
context.surfaceCard   → scheme.surface
context.textPrimary   → scheme.onSurface
context.textSecondary → scheme.onSurfaceVariant
context.success       → #10B981
context.warning       → #F59E0B
context.error         → #EF4444
context.isDark        → brightness == Brightness.dark
context.shadowSm      → List<BoxShadow>
context.shadowMd      → List<BoxShadow>
context.shadowLg      → List<BoxShadow>
// + shimmer, chat bubble colors, gradients, category colors
```

## Design System Summary
- **Font**: Space Grotesk (Google Fonts) — ALL text, EVERYWHERE
- **Primary Brand Color**: #2563EB (primaryBlue)
- **Secondary Brand**: #7C3AED (accentPurple), #14B8A6 (accentTeal)
- **Surfaces**: White, grey (#F8FAFC, #F1F5F9), dark (#0F172A, #1A1A2E)
- **Functional**: Green (#10B981), Orange (#F59E0B), Red (#EF4444)
- **Spacing**: 4/8/12/16/20/24/32/40/48 (NO 10)
- **Radius**: 8/12/16/24/32/999
- **Shadows**: Subtle elevation with dark mode adjustment
- **Animations**: 150/250/400/500ms, easeOutCubic, elasticOut spring
- **Layout**: SafeArea, Center/Column/Row, EdgeInsets symmetry
