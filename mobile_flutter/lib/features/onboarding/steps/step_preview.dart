import 'package:flutter/material.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/unify_logo.dart';
import '../onboarding_screen.dart';

class StepPreview extends StatelessWidget {
  final OnboardingData data;
  final AnimationController animCtrl;

  const StepPreview({super.key, required this.data, required this.animCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: UnifySpacing.s24),
      child: Column(
        children: [
          const SizedBox(height: UnifySpacing.s32),
          const UnifyLogo(size: 64, backgroundColor: UnifyColors.primaryBlue),
          const SizedBox(height: UnifySpacing.s16),
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
                if (data.shsIntendedProgram != null && data.shsIntendedProgram!.isNotEmpty)
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
    return Padding(
      padding: const EdgeInsets.only(bottom: UnifySpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: UnifyTextStyle.h4(color: UnifyColors.primaryBlue)),
          const SizedBox(height: UnifySpacing.s8),
          ...children,
          const Divider(height: UnifySpacing.s24, color: UnifyColors.divider),
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
      padding: const EdgeInsets.symmetric(vertical: UnifySpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: UnifyTextStyle.bodySm(color: UnifyColors.textTertiary)),
          ),
          Expanded(
            child: Text(value, style: UnifyTextStyle.body(color: UnifyColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
