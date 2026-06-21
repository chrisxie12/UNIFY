import 'package:flutter/material.dart';
import '../../../core/design/design_tokens.dart';
import '../onboarding_screen.dart';

class StepIdentity extends StatelessWidget {
  final OnboardingData data;
  final AnimationController animCtrl;

  const StepIdentity({super.key, required this.data, required this.animCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: UnifySpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UnifySpacing.s32),
          Text('Who are you?', style: UnifyTextStyle.h2()),
          const SizedBox(height: UnifySpacing.s8),
          Text(
            'Select your current status to personalize your UNIFY experience.',
            style: UnifyTextStyle.body(),
          ),
          const SizedBox(height: UnifySpacing.s32),
          _OptionCard(
            icon: Icons.school_outlined,
            title: 'SHS Graduate',
            subtitle: 'Completed senior high school, exploring university options',
            selected: data.identity == UserIdentity.shs,
            onTap: () => data.identity = UserIdentity.shs,
          ),
          const SizedBox(height: UnifySpacing.s12),
          _OptionCard(
            icon: Icons.auto_stories_outlined,
            title: 'University Student',
            subtitle: 'Currently enrolled at a tertiary institution',
            selected: data.identity == UserIdentity.uni,
            onTap: () => data.identity = UserIdentity.uni,
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: UnifyAnim.fast,
        padding: const EdgeInsets.all(UnifySpacing.s20),
        decoration: BoxDecoration(
          color: selected
              ? UnifyColors.primaryBlue.withValues(alpha: 0.06)
              : UnifyColors.surfaceWhite,
          borderRadius: BorderRadius.circular(UnifyRadius.lg),
          border: Border.all(
            color: selected ? UnifyColors.primaryBlue : UnifyColors.divider,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? UnifyShadows.md : [],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected
                    ? UnifyColors.primaryBlue.withValues(alpha: 0.12)
                    : UnifyColors.surfaceElevated,
                borderRadius: BorderRadius.circular(UnifyRadius.md),
              ),
              child: Icon(icon,
                color: selected ? UnifyColors.primaryBlue : UnifyColors.textTertiary,
                size: 26,
              ),
            ),
            const SizedBox(width: UnifySpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: selected ? UnifyColors.textPrimary : UnifyColors.textSecondary,
                      fontFamily: 'SpaceGrotesk',
                    ),
                  ),
                  const SizedBox(height: UnifySpacing.s4),
                  Text(subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: UnifyColors.textTertiary,
                      fontFamily: 'SpaceGrotesk',
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: UnifyColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: UnifyColors.textInverse, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
