import 'dart:io';
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
    final isSHS = data.isSHS;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Header
          Text(
            'Review your profile',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.5,
              color: UnifyColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Everything look good? Tap Complete Setup to finish.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              height: 1.5,
              color: UnifyColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          // Avatar + name + badge
          _buildIdentityCard(isSHS),
          const SizedBox(height: 20),

          // Academic section
          _buildSection(
            icon: Icons.school_rounded,
            title: isSHS ? 'SHS Education' : 'University Details',
            rows: isSHS ? _shsAcademicRows() : _uniAcademicRows(),
          ),
          const SizedBox(height: 16),

          // Goals
          if (data.goals.isNotEmpty) ...[
            _buildChipSection(
              icon: Icons.flag_rounded,
              title: 'Study Goals',
              items: data.goals,
              color: UnifyColors.primaryBlue,
            ),
            const SizedBox(height: 16),
          ],

          // Interests
          if (data.interests.isNotEmpty) ...[
            _buildChipSection(
              icon: Icons.interests_rounded,
              title: 'Interests',
              items: data.interests,
              color: UnifyColors.accentPurple,
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 8),
          Center(
            child: Text(
              'You can update all of this later in your profile settings.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                height: 1.5,
                color: UnifyColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(bool isSHS) {
    final hasPhoto = data.photoPath != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UnifyColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasPhoto
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [UnifyColors.primaryBlue, UnifyColors.accentPurple],
                    ),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPhoto
                ? Image.file(File(data.photoPath!), fit: BoxFit.cover)
                : Center(
                    child: Text(
                      _initials,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.fullName ?? '—',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: UnifyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.email ?? '—',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: UnifyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Path badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [UnifyColors.primaryBlue, UnifyColors.accentPurple],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isSHS ? 'SHS Graduate' : 'University Student',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _initials {
    final name = data.fullName ?? '';
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  List<(String, String)> _shsAcademicRows() {
    return [
      if (data.shsSchoolName != null) ('School', data.shsSchoolName!),
      if (data.shsYearCompleted != null)
        ('Graduation Year', data.shsYearCompleted.toString()),
      if (data.shsStatus != null)
        ('Status', data.shsStatus == 'student' ? 'Current Student' : 'Graduate'),
    ];
  }

  List<(String, String)> _uniAcademicRows() {
    return [
      if (data.uniSelectedUniversity != null) ('University', data.uniSelectedUniversity!),
      if (data.uniFaculty != null) ('Faculty', data.uniFaculty!),
      if (data.uniLevel != null) ('Level', data.uniLevel!),
    ];
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<(String, String)> rows,
  }) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UnifyColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: UnifyColors.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 17, color: UnifyColors.primaryBlue),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: UnifyColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final row in rows) ...[
            _buildRow(row.$1, row.$2),
            if (row != rows.last)
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 108,
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: UnifyColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: UnifyColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipSection({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UnifyColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: UnifyColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in items)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: color.withValues(alpha: 0.20), width: 1),
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
