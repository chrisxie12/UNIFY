import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/design_tokens.dart';

class UnifySecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final Color? borderColor;
  final Color? textColor;

  const UnifySecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 52,
    this.borderColor,
    this.textColor,
  });

  @override
  State<UnifySecondaryButton> createState() => _UnifySecondaryButtonState();
}

class _UnifySecondaryButtonState extends State<UnifySecondaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: UnifyAnim.fast,
        curve: UnifyAnim.easeOut,
        child: AnimatedContainer(
          duration: UnifyAnim.fast,
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(UnifyRadius.lg),
            border: Border.all(
              color: widget.onPressed != null
                  ? (widget.borderColor ?? UnifyColors.divider)
                  : UnifyColors.divider.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.onPressed != null
                    ? (widget.textColor ?? UnifyColors.textPrimary)
                    : UnifyColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
