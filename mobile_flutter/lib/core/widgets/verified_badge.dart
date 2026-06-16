import 'package:flutter/material.dart';
import '../extensions/theme_extensions.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;
  final String tooltip;

  const VerifiedBadge({
    super.key,
    this.size = 16,
    this.tooltip = 'Verified Leader',
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Icon(
        Icons.verified_rounded,
        size: size,
        color: context.primary,
      ),
    );
  }
}
