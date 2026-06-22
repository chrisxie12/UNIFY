import 'dart:math';
import 'package:flutter/material.dart';
import '../onboarding_screen.dart';

class StepUniEmailVerify extends StatefulWidget {
  final OnboardingData data;
  final AnimationController animCtrl;
  final VoidCallback? onChanged;

  const StepUniEmailVerify({
    super.key,
    required this.data,
    required this.animCtrl,
    this.onChanged,
  });

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
    setState(() { _codeSent = true; _error = null; });
  }

  void _verifyCode() {
    if (_otpCtrl.text.trim() == _sentCode) {
      widget.data.uniEmailVerified = true;
      widget.onChanged?.call();
      setState(() => _error = null);
    } else {
      setState(() => _error = 'Invalid code. Please try again.');
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    Widget? prefixIcon,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 15,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('Verify Email',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your official university email to verify your campus identity.',
            style: TextStyle(
              fontSize: 15,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (!_codeSent) ...[
            _buildField(
              controller: _emailCtrl,
              hint: 'student@domain.edu.gh',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _sendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: primary.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Send Verification Code'),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Code sent to ${_emailCtrl.text.trim()}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _codeSent = false;
                      _error = null;
                    }),
                    child: Text(
                      'Change',
                      style: TextStyle(
                        fontSize: 13,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Enter verification code',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildField(
              controller: _otpCtrl,
              hint: '000000',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: primary.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Verify & Continue'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
