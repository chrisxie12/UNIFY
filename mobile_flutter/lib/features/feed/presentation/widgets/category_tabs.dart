import 'package:flutter/material.dart';
import '../../../../core/extensions/theme_extensions.dart';

/// Horizontally-scrollable pill-shaped animated category tabs.
///
/// Selected tab gets a solid [primary] background with white text.
/// Unselected tabs are outlined with a border.
class CategoryTabs extends StatelessWidget {
  const CategoryTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => _PillTab(
          label: tabs[i],
          selected: selectedIndex == i,
          onTap: () => onSelect(i),
        ),
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? context.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? context.primary : context.borderCol,
            width: 1,
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : context.textSecondary,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
