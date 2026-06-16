import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outlined, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final bool loading;
  final IconData? icon;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;

    Color bg, fg;
    Border? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = enabled ? AppColors.primary : AppColors.surface;
        fg = enabled ? AppColors.white : AppColors.grey3;
      case AppButtonVariant.secondary:
        bg = AppColors.surface;
        fg = AppColors.grey1;
      case AppButtonVariant.outlined:
        bg = AppColors.white;
        fg = AppColors.dark;
        border = Border.all(color: AppColors.border);
      case AppButtonVariant.danger:
        bg = AppColors.white;
        fg = AppColors.error;
        border = Border.all(color: AppColors.border);
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: border,
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(
                    color: fg, strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: fg, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: fg)),
                  ],
                ),
        ),
      ),
    );
  }
}
