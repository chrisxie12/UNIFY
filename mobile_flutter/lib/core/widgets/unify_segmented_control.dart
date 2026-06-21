import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/design_tokens.dart';

class UnifySegmentedControl extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const UnifySegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: UnifyColors.surfaceElevated,
        borderRadius: BorderRadius.circular(UnifyRadius.full),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = selected == option;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: UnifyAnim.fast,
                curve: UnifyAnim.easeOut,
                decoration: BoxDecoration(
                  color: isSelected ? UnifyColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(UnifyRadius.full),
                ),
                child: Center(
                  child: Text(
                    option,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? UnifyColors.textInverse
                          : UnifyColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
