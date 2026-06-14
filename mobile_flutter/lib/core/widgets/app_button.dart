import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final bool loading;
  final double height;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.height = 52,
    this.icon,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.height = 52,
    this.icon,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.height = 52,
    this.icon,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.height = 52,
    this.icon,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.height = 44,
    this.icon,
  }) : variant = AppButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;

    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = enabled ? AppColors.dark : AppColors.surface;
        fg = enabled ? AppColors.white : AppColors.grey3;
        border = null;
      case AppButtonVariant.secondary:
        bg = AppColors.surface;
        fg = AppColors.grey1;
        border = null;
      case AppButtonVariant.outlined:
        bg = AppColors.white;
        fg = AppColors.dark;
        border = Border.all(color: AppColors.border);
      case AppButtonVariant.text:
        bg = Colors.transparent;
        fg = AppColors.primary;
        border = null;
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
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: fg,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: AppTextStyles.buttonL.copyWith(color: fg),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
