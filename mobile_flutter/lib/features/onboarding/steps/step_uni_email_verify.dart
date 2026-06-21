import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/unify_input_field.dart';
import '../../../core/widgets/unify_primary_button.dart';
import '../onboarding_screen.dart';

class StepUniEmailVerify extends StatefulWidget {
  final OnboardingData data;
  final AnimationController animCtrl;

  const StepUniEmailVerify({super.key, required this.data, required this.animCtrl});

  @override
  State<StepUniEmailVerify> createState() => _StepUniEmailVerifyState();
}

class _StepUniEmailVerifyState extends State<StepUniEmailVerify> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _codeSent = false;
  String? _sentCode;
  String? _error;

  final _validDomains = [
    '@gctu.edu.gh', '@knust.edu.gh', '@ug.edu.gh',
    '@ucc.edu.gh', '@st.ug.edu.gh', '@std.uew.edu.gh',
    '@uds.edu.gh', '@upsa.edu.gh', '@uenr.edu.gh',
  ];

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.data.uniEmail ?? '';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    final hasValid = _validDomains.any((d) => email.endsWith(d));
    if (!hasValid) return 'Please use your official university email';
    return null;
  }

  void _sendCode() {
    final err = _validateEmail(_emailCtrl.text.trim());
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    widget.data.uniEmail = _emailCtrl.text.trim();
    _sentCode = (100000 + Random().nextInt(900000)).toString();
    debugPrint('[OTP] Sent code $_sentCode to ${_emailCtrl.text.trim()}');
    setState(() {
      _codeSent = true;
      _error = null;
    });
  }

  void _verifyCode() {
    if (_otpCtrl.text.trim() == _sentCode) {
      widget.data.uniEmailVerified = true;
      setState(() => _error = null);
    } else {
      setState(() => _error = 'Invalid code. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: UnifySpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UnifySpacing.s32),
          Text('Verify Email', style: UnifyTextStyle.h2()),
          const SizedBox(height: UnifySpacing.s8),
          Text(
            'Enter your official university email to verify your campus identity.',
            style: UnifyTextStyle.body(),
          ),
          const SizedBox(height: UnifySpacing.s24),
          if (!_codeSent) ...[
            UnifyInputField(
              controller: _emailCtrl,
              label: 'University Email',
              hint: 'student@domain.edu.gh',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
            ),
            const SizedBox(height: UnifySpacing.s16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: UnifyTextStyle.caption(color: UnifyColors.error)),
              ),
            UnifyPrimaryButton(label: 'Send Verification Code', onPressed: _sendCode),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(UnifySpacing.s16),
              decoration: BoxDecoration(
                color: UnifyColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(UnifyRadius.md),
                border: Border.all(color: UnifyColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: UnifyColors.success, size: 24),
                  const SizedBox(width: UnifySpacing.s12),
                  Expanded(
                    child: Text(
                      'Code sent to ${_emailCtrl.text.trim()}',
                      style: UnifyTextStyle.bodySm(color: UnifyColors.success),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() { _codeSent = false; _error = null; }),
                    child: const Text('Change', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UnifySpacing.s24),
            Text('Enter verification code', style: UnifyTextStyle.bodySm()),
            const SizedBox(height: UnifySpacing.s8),
            UnifyInputField(
              controller: _otpCtrl,
              label: '6-digit code',
              hint: '000000',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
            ),
            const SizedBox(height: UnifySpacing.s16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: UnifyTextStyle.caption(color: UnifyColors.error)),
              ),
            UnifyPrimaryButton(label: 'Verify & Continue', onPressed: _verifyCode),
          ],
        ],
      ),
    );
  }
}
