import 'package:flutter/material.dart';
import '../../../core/design/design_tokens.dart';
import '../onboarding_screen.dart';

class StepInterests extends StatelessWidget {
  final OnboardingData data;
  final AnimationController animCtrl;
  final VoidCallback? onChanged;

  const StepInterests({
    super.key,
    required this.data,
    required this.animCtrl,
    this.onChanged,
  });

  static const _allInterests = [
    'Technology', 'Music', 'Sports', 'Art & Design',
    'Business', 'Science', 'Literature', 'Gaming',
    'Photography', 'Fashion', 'Cooking', 'Travel',
    'Fitness', 'Movies', 'Volunteering', 'Entrepreneurship',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: UnifySpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UnifySpacing.s32),
          Text('Your Interests', style: UnifyTextStyle.h2()),
          const SizedBox(height: UnifySpacing.s8),
          Text('Select topics you care about. (Tap to select)', style: UnifyTextStyle.body()),
          const SizedBox(height: UnifySpacing.s24),
          Wrap(
            spacing: UnifySpacing.s8,
            runSpacing: UnifySpacing.s8,
            children: _allInterests.map((interest) {
              final selected = data.interests.contains(interest);
              return GestureDetector(
                onTap: () {
                  if (selected) {
                    data.interests.remove(interest);
                  } else {
                    data.interests.add(interest);
                  }
                  onChanged?.call();
                },
                child: AnimatedContainer(
                  duration: UnifyAnim.fast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: UnifySpacing.s16,
                    vertical: UnifySpacing.s8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? UnifyColors.primaryBlue : UnifyColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(UnifyRadius.full),
                    border: Border.all(
                      color: selected ? UnifyColors.primaryBlue : UnifyColors.divider,
                    ),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selected ? UnifyColors.textInverse : UnifyColors.textSecondary,
                      fontFamily: 'SpaceGrotesk',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
