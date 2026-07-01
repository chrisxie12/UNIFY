import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design/design_tokens.dart';
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
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.data.shsFullName ?? '');
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController(text: widget.data.shsPhone ?? '');
    _locationCtrl = TextEditingController(text: widget.data.shsLocation ?? '');
    _nameCtrl.addListener(_save);
    _phoneCtrl.addListener(_save);
    _locationCtrl.addListener(_save);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: UnifyColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: UnifySpacing.s8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            color: UnifyColors.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: UnifyColors.surfaceElevated,
            hintText: hint,
            hintStyle: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: UnifyColors.textTertiary,
            ),
            prefixIcon: Icon(icon, size: 20, color: UnifyColors.textTertiary),
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
      ],
    );
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
          Text(
            'Help us get to know you better.',
            style: UnifyTextStyle.body(),
          ),
          const SizedBox(height: UnifySpacing.s32),
          _buildField(
            controller: _nameCtrl,
            label: 'FULL NAME',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: UnifySpacing.s16),
          _buildField(
            controller: _emailCtrl,
            label: 'EMAIL ADDRESS',
            hint: 'e.g. you@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: UnifySpacing.s16),
          _buildField(
            controller: _phoneCtrl,
            label: 'PHONE NUMBER',
            hint: 'e.g. 024xxxxxxx',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: UnifySpacing.s16),
          _buildField(
            controller: _locationCtrl,
            label: 'LOCATION (OPTIONAL)',
            hint: 'e.g. Accra, Ghana',
            icon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }
}
