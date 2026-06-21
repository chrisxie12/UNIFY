import 'package:flutter/material.dart';
import '../design/design_tokens.dart';

/// Two white stick-figure people holding hands inside a blue circle.
/// Forms a "U" shape — the primary UNIFY brand mark.
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
