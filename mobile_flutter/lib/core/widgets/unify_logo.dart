import 'package:flutter/material.dart';
import '../design/design_tokens.dart';

/// The UNIFY brand mark — two people holding hands inside a blue circle.
///
/// Displays `assets/images/logo.png`. Falls back to a blue "U" circle
/// when the asset is not available.
class UnifyLogo extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color figureColor;

  const UnifyLogo({
    super.key,
    required this.size,
    this.backgroundColor = UnifyColors.primaryBlue,
    this.figureColor = UnifyColors.textInverse,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _FallbackMark(
          size: size,
          backgroundColor: backgroundColor,
          figureColor: figureColor,
        ),
      ),
    );
  }
}

/// Shown when the logo asset is unavailable.
class _FallbackMark extends StatelessWidget {
  const _FallbackMark({
    required this.size,
    required this.backgroundColor,
    required this.figureColor,
  });

  final double size;
  final Color backgroundColor;
  final Color figureColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(-size * 0.06, 0),
            child: Icon(Icons.person, size: size * 0.5, color: figureColor),
          ),
          Transform.translate(
            offset: Offset(size * 0.06, 0),
            child: Icon(Icons.person, size: size * 0.5, color: figureColor),
          ),
        ],
      ),
    );
  }
}
