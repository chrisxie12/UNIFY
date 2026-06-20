import 'package:flutter/material.dart';

import '../extensions/theme_extensions.dart';

/// Size variants for [UnifyWordmark].
enum WordmarkSize { small, medium, large }

/// Colour mode for [UnifyWordmark].
///
/// - [auto]   adapts to the current system theme (dark → white text, light → primary text)
/// - [light]  always renders in white — use on coloured/gradient backgrounds
/// - [primary] always renders in the theme primary colour — use on neutral backgrounds
enum WordmarkStyle { auto, light, primary }

/// UNIFY logo + wordmark lockup.
///
/// Displays the logo image if `assets/images/logo.png` exists; falls back to
/// a rounded "U" mark in the current primary colour. Use [WordmarkStyle.light]
/// when placing the wordmark on the branded gradient (welcome/splash screens).
///
/// ```dart
/// UnifyWordmark(size: WordmarkSize.large, style: WordmarkStyle.light)
/// UnifyWordmark(size: WordmarkSize.small, style: WordmarkStyle.auto)
/// UnifyWordmark(size: WordmarkSize.medium, showIcon: false)
/// ```
class UnifyWordmark extends StatelessWidget {
  const UnifyWordmark({
    super.key,
    this.size = WordmarkSize.medium,
    this.style = WordmarkStyle.auto,
    this.showIcon = true,
    this.showText = true,
  });

  final WordmarkSize size;
  final WordmarkStyle style;
  final bool showIcon;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final foreground = switch (style) {
      WordmarkStyle.light   => const Color(0xFFFFFFFF),
      WordmarkStyle.primary => context.primary,
      WordmarkStyle.auto    => context.isDark ? const Color(0xFFFFFFFF) : context.primary,
    };

    final (double iconSz, double fontSize, double gap) = switch (size) {
      WordmarkSize.small  => (22.0, 15.0, 6.0),
      WordmarkSize.medium => (34.0, 22.0, 8.0),
      WordmarkSize.large  => (52.0, 36.0, 12.0),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showIcon) ...[
          _LogoMark(size: iconSz, foreground: foreground, primary: context.primary),
          if (showText) SizedBox(width: gap),
        ],
        if (showText)
          Text(
            'UNIFY',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: foreground,
              letterSpacing: fontSize * 0.18,
              height: 1.0,
            ),
          ),
      ],
    );
  }
}

// ── Logo mark ─────────────────────────────────────────────────────────────────

class _LogoMark extends StatelessWidget {
  const _LogoMark({
    required this.size,
    required this.foreground,
    required this.primary,
  });

  final double size;
  final Color foreground;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      color: foreground,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (_, __, ___) => _FallbackMark(size: size, primary: primary),
    );
  }
}

/// Branded "U" container — shown when the logo asset is not available.
class _FallbackMark extends StatelessWidget {
  const _FallbackMark({required this.size, required this.primary});

  final double size;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      alignment: Alignment.center,
      child: Text(
        'U',
        style: TextStyle(
          fontSize: size * 0.60,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFFFFFF),
          height: 1.0,
        ),
      ),
    );
  }
}
