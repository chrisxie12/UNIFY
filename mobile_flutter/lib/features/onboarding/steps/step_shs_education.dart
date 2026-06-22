import 'package:flutter/material.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/unify_input_field.dart';
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

  final _years = List.generate(6, (i) => (2026 - i).toString());
  final _grades = ['A1', 'B2', 'B3', 'C4', 'C5', 'C6', 'D7', 'E8', 'F9'];

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
    widget.data.shsYearCompleted = _yearCompleted != null ? int.tryParse(_yearCompleted!) : null;
    widget.data.shsWassceGrades = _wassceGrade;
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: UnifySpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UnifySpacing.s32),
          Text('Education', style: UnifyTextStyle.h2()),
          const SizedBox(height: UnifySpacing.s8),
          Text('Tell us about your academic background.', style: UnifyTextStyle.body()),
          const SizedBox(height: UnifySpacing.s32),
          UnifyInputField(
            controller: _schoolCtrl,
            label: 'School Name',
            hint: 'Enter your senior high school',
            prefixIcon: const Icon(Icons.school_outlined, size: 20),
          ),
          const SizedBox(height: UnifySpacing.s16),
          Text('Year Completed', style: UnifyTextStyle.bodySm()),
          const SizedBox(height: UnifySpacing.s8),
          _DropdownField<String>(
            value: _yearCompleted,
            hint: 'Select year',
            items: _years,
            onChanged: (v) {
              setState(() { _yearCompleted = v; _save(); });
            },
          ),
          const SizedBox(height: UnifySpacing.s16),
          Text('Best WASSCE Grade', style: UnifyTextStyle.bodySm()),
          const SizedBox(height: UnifySpacing.s8),
          _DropdownField<String>(
            value: _wassceGrade,
            hint: 'Select grade',
            items: _grades,
            onChanged: (v) {
              setState(() { _wassceGrade = v; _save(); });
            },
          ),
        ],
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: UnifySpacing.s16),
      decoration: BoxDecoration(
        color: UnifyColors.surfaceElevated,
        borderRadius: BorderRadius.circular(UnifyRadius.lg),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: UnifyTextStyle.bodySm()),
          isExpanded: true,
          dropdownColor: UnifyColors.surfaceWhite,
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item.toString(), style: const TextStyle(fontFamily: 'SpaceGrotesk')),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
