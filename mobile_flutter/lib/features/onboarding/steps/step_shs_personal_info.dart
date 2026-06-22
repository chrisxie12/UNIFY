import 'package:flutter/material.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/unify_input_field.dart';
import '../onboarding_screen.dart';

class StepShsPersonalInfo extends StatefulWidget {
  final OnboardingData data;
  final AnimationController animCtrl;
  final VoidCallback? onChanged;

  const StepShsPersonalInfo({
    super.key,
    required this.data,
    required this.animCtrl,
    this.onChanged,
  });

  @override
  State<StepShsPersonalInfo> createState() => _StepShsPersonalInfoState();
}

class _StepShsPersonalInfoState extends State<StepShsPersonalInfo> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.data.shsFullName ?? '');
    _phoneCtrl = TextEditingController(text: widget.data.shsPhone ?? '');
    _locationCtrl = TextEditingController(text: widget.data.shsLocation ?? '');
    _nameCtrl.addListener(_save);
    _phoneCtrl.addListener(_save);
    _locationCtrl.addListener(_save);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.data.shsFullName = _nameCtrl.text.trim();
    widget.data.shsPhone = _phoneCtrl.text.trim();
    widget.data.shsLocation = _locationCtrl.text.trim();
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
          Text('About you', style: UnifyTextStyle.h2()),
          const SizedBox(height: UnifySpacing.s8),
          Text('Help us get to know you better.', style: UnifyTextStyle.body()),
          const SizedBox(height: UnifySpacing.s32),
          UnifyInputField(
            controller: _nameCtrl,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: const Icon(Icons.person_outline, size: 20),
          ),
          const SizedBox(height: UnifySpacing.s16),
          UnifyInputField(
            controller: _phoneCtrl,
            label: 'Phone Number',
            hint: 'e.g. 024xxxxxxx',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
          ),
          const SizedBox(height: UnifySpacing.s16),
          UnifyInputField(
            controller: _locationCtrl,
            label: 'Location (optional)',
            hint: 'e.g. Accra, Ghana',
            prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}
