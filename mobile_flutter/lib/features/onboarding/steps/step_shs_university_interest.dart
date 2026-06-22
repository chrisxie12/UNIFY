import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design/design_tokens.dart';
import '../onboarding_screen.dart';

class StepShsUniversityInterest extends StatefulWidget {
  final OnboardingData data;
  final AnimationController animCtrl;
  final VoidCallback? onChanged;

  const StepShsUniversityInterest({
    super.key,
    required this.data,
    required this.animCtrl,
    this.onChanged,
  });

  @override
  State<StepShsUniversityInterest> createState() =>
      _StepShsUniversityInterestState();
}

class _StepShsUniversityInterestState extends State<StepShsUniversityInterest> {
  final _uniCtrl = TextEditingController();
  final _progCtrl = TextEditingController();

  final _universities = [
    'University of Ghana (UG)',
    'Kwame Nkrumah University of Science and Technology (KNUST)',
    'University of Cape Coast (UCC)',
    'University of Education, Winneba (UEW)',
    'University for Development Studies (UDS)',
    'University of Professional Studies, Accra (UPSA)',
    'Ghana Communication Technology University (GCTU)',
    'University of Energy and Natural Resources (UENR)',
    'Ho Technical University (HTU)',
    'Takoradi Technical University (TTU)',
    'Accra Technical University (ATU)',
  ];

  @override
  void initState() {
    super.initState();
    _uniCtrl.text = widget.data.shsPreferredUniversity ?? '';
    _progCtrl.text = widget.data.shsIntendedProgram ?? '';
    _progCtrl.addListener(_save);
  }

  @override
  void dispose() {
    _uniCtrl.dispose();
    _progCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.data.shsPreferredUniversity = _uniCtrl.text.trim();
    widget.data.shsIntendedProgram = _progCtrl.text.trim();
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: UnifySpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UnifySpacing.s32),
          Text('University Interest', style: UnifyTextStyle.h2()),
          const SizedBox(height: UnifySpacing.s8),
          Text(
            'Which university are you interested in?',
            style: UnifyTextStyle.body(),
          ),
          const SizedBox(height: UnifySpacing.s24),
          Text(
            'CHOOSE A UNIVERSITY',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: UnifyColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: UnifySpacing.s12),
          ..._universities.map((uni) => Padding(
            padding: const EdgeInsets.only(bottom: UnifySpacing.s8),
            child: GestureDetector(
              onTap: () {
                setState(() => _uniCtrl.text = uni);
                _save();
              },
              child: AnimatedContainer(
                duration: UnifyAnim.fast,
                padding: const EdgeInsets.symmetric(
                  horizontal: UnifySpacing.s16,
                  vertical: UnifySpacing.s12,
                ),
                decoration: BoxDecoration(
                  color: _uniCtrl.text == uni
                      ? primary.withValues(alpha: 0.08)
                      : UnifyColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(UnifyRadius.lg),
                  border: Border.all(
                    color: _uniCtrl.text == uni
                        ? primary
                        : UnifyColors.divider,
                    width: _uniCtrl.text == uni ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _uniCtrl.text == uni
                            ? primary.withValues(alpha: 0.15)
                            : UnifyColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(UnifyRadius.md),
                      ),
                      child: Icon(
                        Icons.school_outlined,
                        color: _uniCtrl.text == uni
                            ? primary
                            : UnifyColors.textTertiary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: UnifySpacing.s16),
                    Expanded(
                      child: Text(
                        uni,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: _uniCtrl.text == uni
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _uniCtrl.text == uni
                              ? UnifyColors.textPrimary
                              : UnifyColors.textSecondary,
                        ),
                      ),
                    ),
                    AnimatedScale(
                      scale: _uniCtrl.text == uni ? 1.0 : 0.0,
                      duration: UnifyAnim.normal,
                      curve: UnifyAnim.spring,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: UnifyColors.textInverse,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
          const SizedBox(height: UnifySpacing.s20),
          Text(
            'INTENDED PROGRAM (OPTIONAL)',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: UnifyColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: UnifySpacing.s8),
          TextFormField(
            controller: _progCtrl,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: UnifyColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: UnifyColors.surfaceElevated,
              hintText: 'e.g. Computer Science',
              hintStyle: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: UnifyColors.textTertiary,
              ),
              prefixIcon: const Icon(Icons.menu_book_outlined,
                  size: 20, color: UnifyColors.textTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UnifyRadius.md),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UnifyRadius.md),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UnifyRadius.md),
                borderSide: BorderSide(color: primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: UnifySpacing.s16,
                vertical: 14.0,
              ),
            ),
          ),
          const SizedBox(height: UnifySpacing.s24),
        ],
      ),
    );
  }
}
