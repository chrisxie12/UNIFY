import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/design_tokens.dart';

class UnifyInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool autocorrect;
  final ValueChanged<String>? onChanged;

  const UnifyInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.enabled = true,
    this.autocorrect = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(UnifyRadius.lg),
      borderSide: BorderSide.none,
    );

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      autocorrect: autocorrect,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: UnifyColors.surfaceElevated,
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UnifyRadius.lg),
          borderSide: const BorderSide(color: UnifyColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UnifyRadius.lg),
          borderSide: const BorderSide(color: UnifyColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UnifyRadius.lg),
          borderSide: const BorderSide(color: UnifyColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UnifySpacing.s16,
          vertical: UnifySpacing.s16,
        ),
        labelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          color: UnifyColors.textTertiary,
        ),
        hintStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          color: UnifyColors.textTertiary,
        ),
      ),
      style: GoogleFonts.spaceGrotesk(
        fontSize: 15,
        color: UnifyColors.textPrimary,
      ),
    );
  }
}
