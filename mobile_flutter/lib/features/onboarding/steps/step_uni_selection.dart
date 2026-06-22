import 'package:flutter/material.dart';
import '../../../core/design/design_tokens.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: UnifySpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UnifySpacing.s32),
          Text('Your University', style: UnifyTextStyle.h2()),
          const SizedBox(height: UnifySpacing.s8),
          Text('Select the institution you currently attend.', style: UnifyTextStyle.body()),
          const SizedBox(height: UnifySpacing.s24),
          ..._universities.map((uni) {
            final selected = data.uniSelectedUniversity == uni;
            return Padding(
              padding: const EdgeInsets.only(bottom: UnifySpacing.s8),
              child: GestureDetector(
                onTap: () {
                  data.uniSelectedUniversity = uni;
                  onChanged?.call();
                },
                child: AnimatedContainer(
                  duration: UnifyAnim.fast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: UnifySpacing.s16,
                    vertical: UnifySpacing.s16,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? UnifyColors.primaryBlue.withValues(alpha: 0.06)
                        : UnifyColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(UnifyRadius.md),
                    border: Border.all(
                      color: selected ? UnifyColors.primaryBlue : UnifyColors.divider,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: selected ? UnifyColors.primaryBlue : UnifyColors.textTertiary,
                        size: 22,
                      ),
                      const SizedBox(width: UnifySpacing.s12),
                      Expanded(
                        child: Text(
                          uni,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected ? UnifyColors.textPrimary : UnifyColors.textSecondary,
                            fontFamily: 'SpaceGrotesk',
                          ),
                        ),
                      ),
                      if (selected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: UnifyColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: UnifyColors.textInverse, size: 14),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
