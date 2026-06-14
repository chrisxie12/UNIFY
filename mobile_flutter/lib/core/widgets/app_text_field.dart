import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextCapitalization capitalization;
  final bool obscure;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.capitalization = TextCapitalization.none,
    this.obscure = false,
    this.errorText,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.capitalization,
          obscureText: widget.obscure && _obscured,
          onChanged: widget.onChanged,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          style: const TextStyle(fontSize: 14, color: AppColors.dark),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            suffixIcon: widget.obscure
                ? GestureDetector(
                    onTap: () => setState(() => _obscured = !_obscured),
                    child: Icon(
                      _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20, color: AppColors.grey3,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
