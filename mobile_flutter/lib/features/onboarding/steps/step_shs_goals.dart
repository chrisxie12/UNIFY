import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design/design_tokens.dart';
import '../widgets/onboarding_select_card.dart';
import '../onboarding_screen.dart';

/// Shared "Study Goals" step (flow position 4). University students may pick
/// several goals; SHS students pick the single area they want to focus on.
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

  // (title, subtitle, icon, accent)
  static const _uniGoals = <(String, String, IconData, Color)>[
    ('Networking', 'Connect with peers and build relationships',
        Icons.group_rounded, UnifyColors.primaryBlue),
    ('Academic Help', 'Get help with courses and assignments',
        Icons.menu_book_rounded, UnifyColors.primaryBlue),
    ('Events Discovery', 'Find events and activities on campus',
        Icons.event_rounded, UnifyColors.accentPurple),
    ('Professional Development', 'Build skills and prepare for your career',
        Icons.work_outline_rounded, UnifyColors.accentPurple),
  ];

  static const _shsGoals = <(String, String, IconData, Color)>[
    ('University Preparation', 'Prepare for entrance exams and admissions',
        Icons.apartment_rounded, UnifyColors.primaryBlue),
    ('Exam Preparation', 'WASSCE, BECE, and other standardized test prep',
        Icons.menu_book_rounded, UnifyColors.primaryBlue),
    ('Career Guidance', 'Explore career paths and discover your strengths',
        Icons.explore_rounded, UnifyColors.accentPurple),
    ('Networking with Alumni', 'Connect with graduates for mentorship',
        Icons.group_rounded, UnifyColors.accentPurple),
  ];

  @override
  Widget build(BuildContext context) {
    final isSHS = data.isSHS;
    final goals = isSHS ? _shsGoals : _uniGoals;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'What are your study goals?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.5,
              color: UnifyColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isSHS
                ? "Pick the area you want to focus on. We'll tailor your UNIFY experience to help you get there."
                : "Select what you're looking to achieve on UNIFY. You can choose more than one.",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              height: 1.5,
              color: UnifyColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          for (final g in goals) ...[
            OnboardingSelectCard(
              icon: g.$3,
              accent: g.$4,
              title: g.$1,
              subtitle: g.$2,
              selected: data.goals.contains(g.$1),
              onTap: () {
                if (isSHS) {
                  data.goals
                    ..clear()
                    ..add(g.$1);
                } else if (data.goals.contains(g.$1)) {
                  data.goals.remove(g.$1);
                } else {
                  data.goals.add(g.$1);
                }
                onChanged?.call();
              },
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          Center(
            child: Text(
              'You can always update your goals later in your profile settings.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                height: 1.5,
                color: UnifyColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
