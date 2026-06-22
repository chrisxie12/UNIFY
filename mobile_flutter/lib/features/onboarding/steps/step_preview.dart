import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design/design_tokens.dart';
import '../onboarding_screen.dart';

class StepPreview extends StatelessWidget {
  final OnboardingData data;
  final AnimationController animCtrl;

  const StepPreview({super.key, required this.data, required this.animCtrl});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: UnifySpacing.s24),
      child: Column(
        children: [
          const SizedBox(height: UnifySpacing.s32),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(UnifyRadius.xl),
            ),
            child: Icon(
              Icons.celebration_outlined,
              color: primary,
              size: 36,
            ),
          ),
          const SizedBox(height: UnifySpacing.s20),
          Text("You're all set!", style: UnifyTextStyle.h2()),
          const SizedBox(height: UnifySpacing.s8),
          Text(
            'Review your information before we finalize.',
            style: UnifyTextStyle.body(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UnifySpacing.s32),
          _PreviewSection(
            title: 'Identity',
            children: [
              _PreviewRow('Type', data.isSHS ? 'SHS Graduate' : 'University Student'),
            ],
          ),
          if (data.isSHS) ...[
            _PreviewSection(
              title: 'Personal Info',
              children: [
                _PreviewRow('Name', data.shsFullName ?? ''),
                _PreviewRow('Phone', data.shsPhone ?? ''),
                if (data.shsLocation != null && data.shsLocation!.isNotEmpty)
                  _PreviewRow('Location', data.shsLocation!),
              ],
            ),
            _PreviewSection(
              title: 'Education',
              children: [
                _PreviewRow('School', data.shsSchoolName ?? ''),
                if (data.shsYearCompleted != null)
                  _PreviewRow('Year', data.shsYearCompleted.toString()),
                if (data.shsWassceGrades != null)
                  _PreviewRow('Grade', data.shsWassceGrades!),
              ],
            ),
            _PreviewSection(
              title: 'University Interest',
              children: [
                _PreviewRow('University', data.shsPreferredUniversity ?? ''),
                if (data.shsIntendedProgram != null &&
                    data.shsIntendedProgram!.isNotEmpty)
                  _PreviewRow('Program', data.shsIntendedProgram!),
              ],
            ),
          ] else ...[
            _PreviewSection(
              title: 'University',
              children: [
                _PreviewRow('Institution', data.uniSelectedUniversity ?? ''),
                _PreviewRow('Email', data.uniEmail ?? ''),
                _PreviewRow('Verified', data.uniEmailVerified ? 'Yes' : 'No'),
              ],
            ),
            _PreviewSection(
              title: 'Academic Details',
              children: [
                _PreviewRow('Department', data.uniDepartment ?? ''),
                _PreviewRow('Level', data.uniLevel ?? ''),
                _PreviewRow('Student ID', data.uniStudentId ?? ''),
              ],
            ),
          ],
          _PreviewSection(
            title: 'Goals',
            children: data.goals.map((g) => _PreviewRow('•', g)).toList(),
          ),
          _PreviewSection(
            title: 'Interests',
            children: data.interests.map((i) => _PreviewRow('•', i)).toList(),
          ),
          const SizedBox(height: UnifySpacing.s24),
        ],
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _PreviewSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: UnifySpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: UnifySpacing.s8),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: UnifyColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: UnifySpacing.s12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(UnifySpacing.s16),
            decoration: BoxDecoration(
              color: UnifyColors.surfaceGrey,
              borderRadius: BorderRadius.circular(UnifyRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
          const SizedBox(height: UnifySpacing.s8),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: UnifyColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: UnifyColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
