import 'package:flutter/material.dart';
import '../onboarding_screen.dart';

class StepUniSelection extends StatelessWidget {
  final OnboardingData data;
  final AnimationController animCtrl;
  final VoidCallback? onChanged;

  const StepUniSelection({
    super.key,
    required this.data,
    required this.animCtrl,
    this.onChanged,
  });

  static const _universities = [
    'Ghana Communication Technology University (GCTU)',
    'Kwame Nkrumah University of Science and Technology (KNUST)',
    'University of Ghana (UG)',
    'University of Cape Coast (UCC)',
    'University of Education, Winneba (UEW)',
    'University for Development Studies (UDS)',
    'University of Professional Studies, Accra (UPSA)',
    'University of Energy and Natural Resources (UENR)',
    'Ho Technical University (HTU)',
    'Takoradi Technical University (TTU)',
    'Accra Technical University (ATU)',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('Your University',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the institution you currently attend.',
            style: TextStyle(
              fontSize: 15,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _universities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final uni = _universities[i];
                final selected = data.uniSelectedUniversity == uni;
                return GestureDetector(
                  onTap: () {
                    data.uniSelectedUniversity = uni;
                    onChanged?.call();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? primary.withValues(alpha: 0.04)
                           : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? primary
                            : theme.colorScheme.outlineVariant,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            color: selected ? primary : textSecondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            uni,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? textPrimary : textSecondary,
                            ),
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? primary : Colors.transparent,
                            border: Border.all(
                              color: selected
                                  ? primary
                                  : theme.colorScheme.outlineVariant,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 14)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
