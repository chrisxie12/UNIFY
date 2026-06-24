import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design/design_tokens.dart';
import '../onboarding_screen.dart';

bool isValidOnboardingEmail(String? email) {
  if (email == null || email.trim().isEmpty) return false;
  final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  return re.hasMatch(email.trim());
}

class StepPersonalDetails extends StatefulWidget {
  final OnboardingData data;
  final AnimationController animCtrl;
  final VoidCallback? onChanged;

  const StepPersonalDetails({
    super.key,
    required this.data,
    required this.animCtrl,
    this.onChanged,
  });

  @override
  State<StepPersonalDetails> createState() => _StepPersonalDetailsState();
}

class _StepPersonalDetailsState extends State<StepPersonalDetails> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  bool _nameTouched = false;
  bool _emailTouched = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.data.fullName ?? '');
    _emailCtrl = TextEditingController(text: widget.data.email ?? '');
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) setState(() => _nameTouched = true);
      setState(() {});
    });
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) setState(() => _emailTouched = true);
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  bool get _nameInvalid => _nameTouched && _nameCtrl.text.trim().length < 2;
  bool get _emailInvalid => _emailTouched && !isValidOnboardingEmail(_emailCtrl.text);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Tell us about yourself',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.5,
              color: UnifyColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We need a few details to set up your UNIFY profile and verify your university status.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              height: 1.5,
              color: UnifyColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          _LabeledField(
            label: 'Full Name',
            controller: _nameCtrl,
            focusNode: _nameFocus,
            hint: 'Enter your full name',
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            error: _nameInvalid,
            errorText: 'Please enter your full name (at least 2 characters)',
            onChanged: (v) {
              widget.data.fullName = v.trim();
              if (_nameTouched) setState(() {});
              widget.onChanged?.call();
            },
            onSubmitted: (_) => _emailFocus.requestFocus(),
          ),
          const SizedBox(height: 24),

          _LabeledField(
            label: 'University Email',
            controller: _emailCtrl,
            focusNode: _emailFocus,
            hint: 'e.g., student@university.edu.gh',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            error: _emailInvalid,
            errorText: 'Please enter a valid university email address',
            onChanged: (v) {
              widget.data.email = v.trim();
              if (_emailTouched) setState(() {});
              widget.onChanged?.call();
            },
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user_outlined,
                  size: 15, color: UnifyColors.textTertiary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "We'll use this to verify your university status",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    height: 1.4,
                    color: UnifyColors.textTertiary,
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

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool error;
  final String errorText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.keyboardType,
    required this.textInputAction,
    required this.error,
    required this.errorText,
    required this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;
    final labelColor = error
        ? UnifyColors.error
        : focused
            ? UnifyColors.primaryBlue
            : const Color(0xFF374151); // gray-700

    final borderColor = error
        ? UnifyColors.error
        : focused
            ? UnifyColors.primaryBlue
            : const Color(0xFFF1F5F9); // gray-100

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC), // gray-50
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: (focused || error)
                ? [
                    BoxShadow(
                      color: (error ? UnifyColors.error : UnifyColors.primaryBlue)
                          .withValues(alpha: 0.10),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: UnifyColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: UnifyColors.textTertiary,
                    ),
                  ),
                ),
              ),
              if (error)
                const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(Icons.error_outline_rounded,
                      size: 20, color: UnifyColors.error),
                ),
            ],
          ),
        ),
        if (error)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: UnifyColors.error,
              ),
            ),
          ),
      ],
    );
  }
}
