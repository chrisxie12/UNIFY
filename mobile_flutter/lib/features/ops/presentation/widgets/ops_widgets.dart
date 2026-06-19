import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';

/// Reusable stat card used across the OPS dashboards.
///
/// Designed to live inside a [Row]; it wraps itself in [Expanded].
class OpsStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const OpsStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: context.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: context.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single label/value row inside a grouped metric card.
class OpsMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? leading;

  const OpsMetricRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          if (leading != null) ...[
            Icon(leading, size: 16, color: context.textDisabled),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13.5, color: context.textPrimary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}

/// A white card with a section title and a column of child widgets.
class OpsSectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;

  const OpsSectionCard({
    super.key,
    required this.title,
    this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

/// Defensive numeric parsing helpers shared by the screens.
int opsInt(dynamic v) => (v as num?)?.toInt() ?? 0;
double opsDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;
