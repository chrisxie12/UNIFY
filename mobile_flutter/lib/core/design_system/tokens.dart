import 'package:flutter/material.dart';

/// UNIFY Design System — Spacing, Radius, Shadows, Motion tokens.
/// Every screen must use these constants instead of raw numeric literals.

// ── Spacing ──────────────────────────────────────────────────────────────────
class USpacing {
  USpacing._();
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double base = 16;
  static const double lg   = 20;
  static const double xl   = 24;
  static const double x2   = 32;
  static const double x3   = 48;
  static const double x4   = 64;

  // Named page insets
  static const EdgeInsets page    = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets pageV   = EdgeInsets.all(base);
  static const EdgeInsets cardPad = EdgeInsets.all(base);
  static const EdgeInsets listBottom = EdgeInsets.only(bottom: x4);
}

// ── Border Radius ─────────────────────────────────────────────────────────────
class URadius {
  URadius._();
  static const double xs   = 6;
  static const double sm   = 8;
  static const double md   = 12;
  static const double base = 16;
  static const double lg   = 20;
  static const double xl   = 24;
  static const double pill = 100;

  static BorderRadius get xsAll   => BorderRadius.circular(xs);
  static BorderRadius get smAll   => BorderRadius.circular(sm);
  static BorderRadius get mdAll   => BorderRadius.circular(md);
  static BorderRadius get baseAll => BorderRadius.circular(base);
  static BorderRadius get lgAll   => BorderRadius.circular(lg);
  static BorderRadius get xlAll   => BorderRadius.circular(xl);
  static BorderRadius get pillAll => BorderRadius.circular(pill);

  // Specific shapes
  static const BorderRadius topLg = BorderRadius.vertical(top: Radius.circular(lg));
  static const BorderRadius topXl = BorderRadius.vertical(top: Radius.circular(xl));
}

// ── Shadows ───────────────────────────────────────────────────────────────────
class UShadow {
  UShadow._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x07000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x09000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x04000000), blurRadius: 2, offset: Offset(0, 0)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x10000000), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  // Standard card shadow (replaces AppColors.cardShadow)
  static const List<BoxShadow> card = sm;

  // Coloured primary shadow for action buttons
  static List<BoxShadow> primaryGlow(Color primary) => [
    BoxShadow(color: primary.withValues(alpha: 0.28), blurRadius: 16, offset: const Offset(0, 6)),
  ];
}

// ── Motion / Animation ────────────────────────────────────────────────────────
class UMotion {
  UMotion._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast    = Duration(milliseconds: 150);
  static const Duration normal  = Duration(milliseconds: 250);
  static const Duration slow    = Duration(milliseconds: 400);
  static const Duration xslow  = Duration(milliseconds: 600);

  static const Curve enter  = Curves.easeOut;
  static const Curve exit   = Curves.easeIn;
  static const Curve inOut  = Curves.easeInOut;
  static const Curve spring = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;
}

// ── Icon Sizes ────────────────────────────────────────────────────────────────
class UIcon {
  UIcon._();
  static const double xs   = 14;
  static const double sm   = 16;
  static const double md   = 18;
  static const double base = 20;
  static const double lg   = 24;
  static const double xl   = 28;
  static const double x2   = 32;
  static const double x3   = 40;
  static const double x4   = 48;
}

// ── Touch Target Sizes ────────────────────────────────────────────────────────
class UTouch {
  UTouch._();
  static const double min     = 44; // WCAG minimum
  static const double button  = 52;
  static const double fab     = 56;
  static const double appBar  = 58;
  static const double navBar  = 60;
  static const double listRow = 64;
}
