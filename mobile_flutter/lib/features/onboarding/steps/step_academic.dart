import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design/design_tokens.dart';
import '../widgets/onboarding_select_card.dart';
import '../onboarding_screen.dart';

/// Step 3 — Academic info. Branches by path: University students enter
/// university / faculty / level; SHS students enter school / year / status.
class StepAcademic extends StatelessWidget {
  final OnboardingData data;
  final AnimationController animCtrl;
  final VoidCallback? onChanged;

  const StepAcademic({
    super.key,
    required this.data,
    required this.animCtrl,
    this.onChanged,
  });

  static const _universities = [
    'Ghana Communication Technology University (GCTU)',
    'University of Ghana (UG)',
    'Kwame Nkrumah University of Science and Technology (KNUST)',
    'University of Cape Coast (UCC)',
    'University of Professional Studies, Accra (UPSA)',
    'Ashesi University',
  ];
  static const _faculties = [
    'College of Engineering',
    'College of Basic & Applied Sciences',
    'College of Humanities',
    'Business School',
    'Faculty of Law',
    'College of Health Sciences',
  ];
  static const _levels = [
    'Level 100 (Freshman)',
    'Level 200 (Sophomore)',
    'Level 300 (Junior)',
    'Level 400 (Senior)',
    'Postgraduate',
  ];
  static const _schools = [
    'Accra Academy', 'Achimota School', 'Adisadel College', 'Prempeh College',
    'Mfantsipim School', "Wesley Girls' High School", 'Holy Child School',
    "St. Augustine's College", 'Opoku Ware School', 'PRESEC, Legon',
    "Aburi Girls' SHS", "St. Rose's SHS", "Yaa Asantewaa Girls' SHS",
    'Kumasi High School', 'Other School',
  ];
  static const _years = ['2025', '2024', '2023', '2022', '2021', '2020', '2019', '2018'];

  @override
  Widget build(BuildContext context) {
    return data.isSHS ? _buildShs(context) : _buildUni(context);
  }

  Widget _buildUni(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _heading('Your Academic Details'),
          const SizedBox(height: 12),
          _sub('Tell us where and what you are studying to get personalized resources.'),
          const SizedBox(height: 28),
          _Dropdown(
            label: 'UNIVERSITY',
            hint: 'Select your university',
            value: data.uniSelectedUniversity,
            items: _universities,
            onChanged: (v) { data.uniSelectedUniversity = v; onChanged?.call(); },
          ),
          const SizedBox(height: 20),
          _Dropdown(
            label: 'FACULTY / DEPARTMENT',
            hint: 'Select your faculty',
            value: data.uniFaculty,
            items: _faculties,
            onChanged: (v) { data.uniFaculty = v; onChanged?.call(); },
          ),
          const SizedBox(height: 20),
          _Dropdown(
            label: 'LEVEL OF STUDY',
            hint: 'Select your level',
            value: data.uniLevel,
            items: _levels,
            onChanged: (v) { data.uniLevel = v; onChanged?.call(); },
          ),
          const SizedBox(height: 24),
          _helper('This information ensures your UNIFY feed is relevant to your specific courses.'),
        ],
      ),
    );
  }

  Widget _buildShs(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _heading('Tell us about your SHS'),
          const SizedBox(height: 12),
          _sub('Help us connect you with the right community and resources.'),
          const SizedBox(height: 28),
          _Dropdown(
            label: 'SENIOR HIGH SCHOOL',
            hint: 'Select your school',
            value: data.shsSchoolName,
            items: _schools,
            onChanged: (v) { data.shsSchoolName = v; onChanged?.call(); },
          ),
          const SizedBox(height: 20),
          _Dropdown(
            label: 'GRADUATION YEAR',
            hint: 'Select year',
            value: data.shsYearCompleted?.toString(),
            items: _years,
            onChanged: (v) {
              data.shsYearCompleted = v == null ? null : int.tryParse(v);
              onChanged?.call();
            },
          ),
          const SizedBox(height: 24),
          Text(
            'CURRENT STATUS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13, fontWeight: FontWeight.w600,
              letterSpacing: 0.6, color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          OnboardingSelectCard(
            icon: Icons.menu_book_rounded,
            accent: UnifyColors.primaryBlue,
            title: 'Currently a Student',
            subtitle: 'Still attending SHS',
            selected: data.shsStatus == 'student',
            onTap: () { data.shsStatus = 'student'; onChanged?.call(); },
          ),
          const SizedBox(height: 12),
          OnboardingSelectCard(
            icon: Icons.workspace_premium_rounded,
            accent: UnifyColors.accentPurple,
            title: 'Graduated',
            subtitle: 'Completed SHS',
            selected: data.shsStatus == 'graduate',
            onTap: () { data.shsStatus = 'graduate'; onChanged?.call(); },
          ),
          const SizedBox(height: 24),
          _helper('Your school info helps us tailor study groups and recommendations for you.'),
        ],
      ),
    );
  }

  Widget _heading(String t) => Text(
        t,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 28, fontWeight: FontWeight.w700, height: 1.15,
          letterSpacing: -0.5, color: UnifyColors.textPrimary),
      );

  Widget _sub(String t) => Text(
        t,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 15, height: 1.5, color: UnifyColors.textSecondary),
      );

  Widget _helper(String t) => Center(
        child: Text(
          t,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13, height: 1.5, color: UnifyColors.textTertiary),
        ),
      );
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13, fontWeight: FontWeight.w600,
            letterSpacing: 0.6, color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: UnifyColors.textTertiary),
          hint: Text(
            hint,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15, fontWeight: FontWeight.w500,
              color: UnifyColors.textTertiary),
          ),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15, fontWeight: FontWeight.w500, color: UnifyColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: _border(const Color(0xFFF1F5F9)),
            enabledBorder: _border(const Color(0xFFF1F5F9)),
            focusedBorder: _border(UnifyColors.primaryBlue),
          ),
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: 2),
      );
}
