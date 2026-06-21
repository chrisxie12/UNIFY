import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/design_tokens.dart';

class UnifySelectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;
  final double height;

  const UnifySelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: UnifyAnim.fast,
        height: height,
        padding: const EdgeInsets.all(UnifySpacing.s20),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.08)
              : UnifyColors.surfaceWhite,
          borderRadius: BorderRadius.circular(UnifyRadius.lg),
          border: Border.all(
            color: isSelected ? accentColor : UnifyColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? UnifyShadows.md : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.15)
                    : UnifyColors.surfaceElevated,
                borderRadius: BorderRadius.circular(UnifyRadius.md),
              ),
              child: Icon(
                icon,
                color: isSelected ? accentColor : UnifyColors.textTertiary,
                size: 24,
              ),
            ),
            const SizedBox(width: UnifySpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? UnifyColors.textPrimary
                          : UnifyColors.textSecondary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: UnifySpacing.s4),
                    Text(
                      subtitle!,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: UnifyColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.0,
              duration: UnifyAnim.normal,
              curve: UnifyAnim.spring,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: UnifyColors.textInverse,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
