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
}
