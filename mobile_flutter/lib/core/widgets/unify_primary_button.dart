import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/design_tokens.dart';

class UnifyPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double height;
  final Widget? prefixIcon;
  final bool loading;

  const UnifyPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.height = 52,
    this.prefixIcon,
    this.loading = false,
  });

  @override
  State<UnifyPrimaryButton> createState() => _UnifyPrimaryButtonState();
}

class _UnifyPrimaryButtonState extends State<UnifyPrimaryButton> {
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
            color: widget.onPressed != null
                ? (widget.backgroundColor ?? UnifyColors.primaryBlue)
                : UnifyColors.divider,
            borderRadius: BorderRadius.circular(UnifyRadius.lg),
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: UnifyColors.textInverse,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.prefixIcon != null) ...[
                        widget.prefixIcon!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.onPressed != null
                              ? UnifyColors.textInverse
                              : UnifyColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
