import 'package:flutter/material.dart';

/// UNIFY branded snackbar variants with consistent styling.
///
/// Usage:
/// ```dart
/// UnifySnackbar.success(context, 'Profile updated!');
/// UnifySnackbar.error(context, 'Something went wrong.');
/// UnifySnackbar.warning(context, 'Your session is about to expire.');
/// UnifySnackbar.info(context, 'New features available.');
///
/// // With retry action:
/// UnifySnackbar.error(context, 'Failed to load feed.', actionLabel: 'Retry', onAction: () => refreshFeed());
/// ```
class UnifySnackbar {
  UnifySnackbar._();

  static void success(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    _show(context, message, _Severity.success, actionLabel: actionLabel, onAction: onAction);
  }

  static void error(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    _show(context, message, _Severity.error, actionLabel: actionLabel, onAction: onAction);
  }

  static void warning(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    _show(context, message, _Severity.warning, actionLabel: actionLabel, onAction: onAction);
  }

  static void info(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    _show(context, message, _Severity.info, actionLabel: actionLabel, onAction: onAction);
  }

  static void _show(BuildContext context, String message, _Severity severity,
      {String? actionLabel, VoidCallback? onAction}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor;
    final Color iconColor;
    final IconData icon;

    switch (severity) {
      case _Severity.success:
        bgColor = isDark ? const Color(0xFF065F46) : const Color(0xFFD1FAE5);
        iconColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669);
        icon = Icons.check_circle_rounded;
      case _Severity.error:
        bgColor = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
        iconColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
        icon = Icons.error_rounded;
      case _Severity.warning:
        bgColor = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        iconColor = isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706);
        icon = Icons.warning_amber_rounded;
      case _Severity.info:
        bgColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE);
        iconColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB);
        icon = Icons.info_rounded;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 4),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: iconColor,
                onPressed: onAction,
              )
            : null,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}

enum _Severity { success, error, warning, info }
