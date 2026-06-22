import 'package:flutter/material.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/unify_input_field.dart';
import '../onboarding_screen.dart';

class StepUniAcademicDetails extends StatefulWidget {
  final OnboardingData data;
  final AnimationController animCtrl;
  final VoidCallback? onChanged;

  const StepUniAcademicDetails({
    super.key,
    required this.data,
    required this.animCtrl,
    this.onChanged,
  });

  @override
  State<StepUniAcademicDetails> createState() => _StepUniAcademicDetailsState();
}

class _StepUniAcademicDetailsState extends State<StepUniAcademicDetails> {
  late final TextEditingController _deptCtrl;
  late final TextEditingController _levelCtrl;
  late final TextEditingController _idCtrl;

  @override
  void initState() {
    super.initState();
    _deptCtrl = TextEditingController(text: widget.data.uniDepartment ?? '');
    _levelCtrl = TextEditingController(text: widget.data.uniLevel ?? '');
    _idCtrl = TextEditingController(text: widget.data.uniStudentId ?? '');
    _deptCtrl.addListener(_save);
    _levelCtrl.addListener(_save);
    _idCtrl.addListener(_save);
  }

  @override
  void dispose() {
    _deptCtrl.dispose();
    _levelCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.data.uniDepartment = _deptCtrl.text.trim();
    widget.data.uniLevel = _levelCtrl.text.trim();
    widget.data.uniStudentId = _idCtrl.text.trim();
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
          Text('Academic Details', style: UnifyTextStyle.h2()),
          const SizedBox(height: UnifySpacing.s8),
          Text('Tell us about your program of study.', style: UnifyTextStyle.body()),
          const SizedBox(height: UnifySpacing.s32),
          UnifyInputField(
            controller: _deptCtrl,
            label: 'Department / Programme',
            hint: 'e.g. Computer Science',
            prefixIcon: const Icon(Icons.menu_book_outlined, size: 20),
          ),
          const SizedBox(height: UnifySpacing.s16),
          UnifyInputField(
            controller: _levelCtrl,
            label: 'Current Level',
            hint: 'e.g. Level 200',
            prefixIcon: const Icon(Icons.trending_up_outlined, size: 20),
          ),
          const SizedBox(height: UnifySpacing.s16),
          UnifyInputField(
            controller: _idCtrl,
            label: 'Student ID Number',
            hint: 'e.g. 20241001',
            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}
