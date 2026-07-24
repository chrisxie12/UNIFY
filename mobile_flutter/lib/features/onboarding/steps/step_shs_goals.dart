import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design/design_tokens.dart';
import '../onboarding_screen.dart';

class StepShsGoals extends StatelessWidget {
  final OnboardingData data;
  final AnimationController animCtrl;
  final VoidCallback? onChanged;

  const StepShsGoals({
    super.key,
    required this.data,
    required this.animCtrl,
    this.onChanged,
  });

  static const _allGoals = [
    (
      'Explore University Admissions',
      Icons.school_outlined,
      'Research and apply to your dream university',
    ),
    (
      'Join Prep Communities',
      Icons.groups_outlined,
      'Connect with peers preparing for university',
    ),
    (
      'Find Student Freelancers',
      Icons.work_outline,
      'Discover talented students for your projects',
    ),
    (
      'Connect with Peers',
      Icons.people_outline,
      'Build your network and make new friends',
    ),
    (
      'Discover Campus Events',
      Icons.event_outlined,
      'Stay updated with campus activities',
    ),
    (
      'Access Study Resources',
      Icons.library_books_outlined,
      'Get notes, past questions and more',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: UnifySpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UnifySpacing.s32),
          Text('Your Goals', style: UnifyTextStyle.h2()),
          const SizedBox(height: UnifySpacing.s8),
          Text(
            'What do you hope to achieve on UNIFY? (Select all that apply)',
            style: UnifyTextStyle.body(),
          ),
          const SizedBox(height: UnifySpacing.s24),
          ..._allGoals.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: UnifySpacing.s12),
            child: GestureDetector(
              onTap: () {
                if (data.goals.contains(g.$1)) {
                  data.goals.remove(g.$1);
                } else {
                  data.goals.add(g.$1);
                }
                onChanged?.call();
              },
              child: AnimatedContainer(
                duration: UnifyAnim.fast,
                padding: const EdgeInsets.all(UnifySpacing.s16),
                decoration: BoxDecoration(
                  color: data.goals.contains(g.$1)
                      ? primary.withValues(alpha: 0.08)
                      : UnifyColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(UnifyRadius.lg),
                  border: Border.all(
                    color: data.goals.contains(g.$1)
                        ? primary
                        : UnifyColors.divider,
                    width: data.goals.contains(g.$1) ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: data.goals.contains(g.$1)
                            ? primary.withValues(alpha: 0.15)
                            : UnifyColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(UnifyRadius.md),
                      ),
                      child: Icon(
                        g.$2,
                        color: data.goals.contains(g.$1)
                            ? primary
                            : UnifyColors.textTertiary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: UnifySpacing.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.$1,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: data.goals.contains(g.$1)
                                  ? UnifyColors.textPrimary
                                  : UnifyColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: UnifySpacing.s4),
                          Text(
                            g.$3,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: UnifyColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedScale(
                      scale: data.goals.contains(g.$1) ? 1.0 : 0.0,
                      duration: UnifyAnim.normal,
                      curve: UnifyAnim.spring,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: data.goals.contains(g.$1)
                              ? primary
                              : UnifyColors.surfaceElevated,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          data.goals.contains(g.$1)
                              ? Icons.check
                              : Icons.circle_outlined,
                          color: data.goals.contains(g.$1)
                              ? UnifyColors.textInverse
                              : UnifyColors.textTertiary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
