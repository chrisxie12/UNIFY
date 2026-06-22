import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design/design_tokens.dart';
import '../widgets/onboarding_select_card.dart';
import '../onboarding_screen.dart';

/// Shared "Interests" step (flow position 5). University students pick field
/// cards; SHS students pick subject/career chips (minimum three).
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

  static const _uniFields = <(String, String, IconData, Color)>[
    ('Computer Science', 'Programming, AI, and software engineering',
        Icons.memory_rounded, UnifyColors.primaryBlue),
    ('Engineering', 'Mechanical, civil, electrical, and systems',
        Icons.build_rounded, UnifyColors.primaryBlue),
    ('Business', 'Finance, marketing, entrepreneurship, and management',
        Icons.work_outline_rounded, UnifyColors.accentPurple),
    ('Medicine', 'Health sciences, nursing, and medical research',
        Icons.monitor_heart_rounded, UnifyColors.accentPurple),
    ('Arts & Humanities', 'Literature, history, philosophy, and design',
        Icons.palette_rounded, UnifyColors.accentPurple),
    ('Natural Sciences', 'Biology, chemistry, physics, and environment',
        Icons.science_rounded, UnifyColors.primaryBlue),
    ('Social Sciences', 'Psychology, sociology, economics, and politics',
        Icons.groups_rounded, UnifyColors.accentPurple),
    ('Law', 'Legal studies, governance, and human rights',
        Icons.balance_rounded, UnifyColors.primaryBlue),
  ];

  static const _shsSubjects = [
    'Core Mathematics', 'Elective Mathematics', 'English Language',
    'Integrated Science', 'Social Studies', 'Physics', 'Chemistry',
    'Biology', 'Economics', 'Geography', 'History', 'Literature', 'ICT', 'French',
  ];

  static const _shsCareers = [
    'Engineering', 'Medicine', 'Business', 'Law', 'Teaching', 'Technology',
    'Arts & Design', 'Agriculture', 'Media & Communication', 'Accounting',
    'Entrepreneurship', 'Research',
  ];

  void _toggle(String value) {
    if (data.interests.contains(value)) {
      data.interests.remove(value);
    } else {
      data.interests.add(value);
    }
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return data.isSHS ? _buildShs() : _buildUni();
  }

  Widget _buildUni() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _heading('What are you interested in?'),
          const SizedBox(height: 12),
          _sub('Select the fields you want to study or explore. Pick as many as you like.'),
          const SizedBox(height: 28),
          for (final f in _uniFields) ...[
            OnboardingSelectCard(
              icon: f.$3,
              accent: f.$4,
              title: f.$1,
              subtitle: f.$2,
              selected: data.interests.contains(f.$1),
              onTap: () => _toggle(f.$1),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          Center(
            child: Text(
              'You can update these interests anytime in your profile.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13, height: 1.5, color: UnifyColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShs() {
    final count = data.interests.length;
    final enough = count >= 3;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _heading('Select Your Interests'),
          const SizedBox(height: 12),
          _sub("Choose subjects you enjoy and career paths you're curious about. We'll personalize your content."),
          const SizedBox(height: 28),
          _sectionLabel('Academic Subjects'),
          const SizedBox(height: 14),
          _chips(_shsSubjects),
          const SizedBox(height: 28),
          _sectionLabel('Career Interests'),
          const SizedBox(height: 14),
          _chips(_shsCareers),
          const SizedBox(height: 24),
          Center(
            child: Text(
              enough ? '$count interests selected'
                     : 'Select at least 3 interests to continue ($count/3)',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: enough ? UnifyColors.primaryBlue : UnifyColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String text) => Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          height: 1.15,
          letterSpacing: -0.5,
          color: UnifyColors.textPrimary,
        ),
      );

  Widget _sub(String text) => Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 15, height: 1.5, color: UnifyColors.textSecondary),
      );

  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: UnifyColors.textSecondary,
        ),
      );

  Widget _chips(List<String> items) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final item in items)
          _InterestChip(
            label: item,
            selected: data.interests.contains(item),
            onTap: () => _toggle(item),
          ),
      ],
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _InterestChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [UnifyColors.primaryBlue, UnifyColors.accentPurple],
                )
              : null,
          color: selected ? null : UnifyColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF374151),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check, size: 15, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
