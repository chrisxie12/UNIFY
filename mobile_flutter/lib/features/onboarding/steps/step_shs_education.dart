import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design/design_tokens.dart';
import '../onboarding_screen.dart';

class StepShsEducation extends StatefulWidget {
  final OnboardingData data;
  final AnimationController animCtrl;
  final VoidCallback? onChanged;

  const StepShsEducation({
    super.key,
    required this.data,
    required this.animCtrl,
    this.onChanged,
  });

  @override
  State<StepShsEducation> createState() => _StepShsEducationState();
}

class _StepShsEducationState extends State<StepShsEducation> {
  late final TextEditingController _schoolCtrl;
  String? _yearCompleted;
  String? _wassceGrade;
  String? _status;

  final _years = List.generate(6, (i) => (2026 - i).toString());
  final _grades = ['A1', 'B2', 'B3', 'C4', 'C5', 'C6', 'D7', 'E8', 'F9'];

  static const _statusOptions = [
    ('Completed', Icons.check_circle_outline, 'Finished SHS'),
    ('In Progress', Icons.trending_up, 'Currently enrolled'),
    ('Not Yet', Icons.schedule, 'Haven\'t started'),
  ];

  @override
  void initState() {
    super.initState();
    _schoolCtrl = TextEditingController(text: widget.data.shsSchoolName ?? '');
    _schoolCtrl.addListener(_save);
    _yearCompleted = widget.data.shsYearCompleted?.toString();
    _wassceGrade = widget.data.shsWassceGrades;
  }

  @override
  void dispose() {
    _schoolCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.data.shsSchoolName = _schoolCtrl.text.trim();
    widget.data.shsYearCompleted =
        _yearCompleted != null ? int.tryParse(_yearCompleted!) : null;
    widget.data.shsWassceGrades = _wassceGrade;
    widget.onChanged?.call();
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: UnifySpacing.s16),
      decoration: BoxDecoration(
        color: UnifyColors.surfaceElevated,
        borderRadius: BorderRadius.circular(UnifyRadius.md),
        border: Border.all(color: UnifyColors.divider, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: UnifyColors.textTertiary,
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: UnifyColors.textTertiary),
          dropdownColor: UnifyColors.surfaceWhite,
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(
              item.toString(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                color: UnifyColors.textPrimary,
              ),
            ),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
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
          Text('Education', style: UnifyTextStyle.h2()),
          const SizedBox(height: UnifySpacing.s8),
          Text(
            'Tell us about your academic background.',
            style: UnifyTextStyle.body(),
          ),
          const SizedBox(height: UnifySpacing.s32),
          Text(
            'SCHOOL NAME',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: UnifyColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: UnifySpacing.s8),
          TextFormField(
            controller: _schoolCtrl,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: UnifyColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: UnifyColors.surfaceElevated,
              hintText: 'Enter your senior high school',
              hintStyle: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: UnifyColors.textTertiary,
              ),
              prefixIcon: const Icon(Icons.school_outlined,
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
          const SizedBox(height: UnifySpacing.s16),
          Text(
            'STATUS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: UnifyColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: UnifySpacing.s8),
          ..._statusOptions.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: UnifySpacing.s8),
            child: GestureDetector(
              onTap: () {
                setState(() => _status = s.$1);
                _save();
              },
              child: AnimatedContainer(
                duration: UnifyAnim.fast,
                padding: const EdgeInsets.all(UnifySpacing.s16),
                decoration: BoxDecoration(
                  color: _status == s.$1
                      ? primary.withValues(alpha: 0.08)
                      : UnifyColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(UnifyRadius.lg),
                  border: Border.all(
                    color: _status == s.$1
                        ? primary
                        : UnifyColors.divider,
                    width: _status == s.$1 ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _status == s.$1
                            ? primary.withValues(alpha: 0.15)
                            : UnifyColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(UnifyRadius.md),
                      ),
                      child: Icon(
                        s.$2,
                        color: _status == s.$1
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
                            s.$1,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _status == s.$1
                                  ? UnifyColors.textPrimary
                                  : UnifyColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: UnifySpacing.s4),
                          Text(
                            s.$3,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: UnifyColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedScale(
                      scale: _status == s.$1 ? 1.0 : 0.0,
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
          Text(
            'YEAR COMPLETED',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: UnifyColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: UnifySpacing.s8),
          _buildDropdown<String>(
            value: _yearCompleted,
            hint: 'Select year',
            items: _years,
            onChanged: (v) {
              setState(() {
                _yearCompleted = v;
                _save();
              });
            },
          ),
          const SizedBox(height: UnifySpacing.s16),
          Text(
            'BEST WASSCE GRADE',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: UnifyColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: UnifySpacing.s8),
          _buildDropdown<String>(
            value: _wassceGrade,
            hint: 'Select grade',
            items: _grades,
            onChanged: (v) {
              setState(() {
                _wassceGrade = v;
                _save();
              });
            },
          ),
          const SizedBox(height: UnifySpacing.s24),
        ],
      ),
    );
  }
}
