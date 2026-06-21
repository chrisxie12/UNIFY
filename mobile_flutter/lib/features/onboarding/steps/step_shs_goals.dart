import 'package:flutter/material.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/unify_selection_card.dart';
import '../onboarding_screen.dart';

class StepShsGoals extends StatelessWidget {
  final OnboardingData data;
  final AnimationController animCtrl;

  const StepShsGoals({super.key, required this.data, required this.animCtrl});

  static const _allGoals = [
    ('Explore University Admissions', Icons.school_outlined, UnifyColors.accentPurple),
    ('Join Prep Communities', Icons.groups_outlined, UnifyColors.primaryBlue),
    ('Find Student Freelancers', Icons.work_outline, UnifyColors.success),
    ('Connect with Peers', Icons.people_outline, UnifyColors.accentTeal),
    ('Discover Campus Events', Icons.event_outlined, UnifyColors.warning),
    ('Access Study Resources', Icons.library_books_outlined, UnifyColors.primaryLight),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: UnifySpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UnifySpacing.s32),
          Text('Your Goals', style: UnifyTextStyle.h2()),
          const SizedBox(height: UnifySpacing.s8),
          Text('What do you hope to achieve on UNIFY? (Select all that apply)', style: UnifyTextStyle.body()),
          const SizedBox(height: UnifySpacing.s24),
          ..._allGoals.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: UnifySpacing.s12),
            child: UnifySelectionCard(
              title: g.$1,
              icon: g.$2,
              accentColor: g.$3,
              isSelected: data.goals.contains(g.$1),
              onTap: () {
                if (data.goals.contains(g.$1)) {
                  data.goals.remove(g.$1);
                } else {
                  data.goals.add(g.$1);
                }
              },
              height: 90,
            ),
          )),
        ],
      ),
    );
  }
}
