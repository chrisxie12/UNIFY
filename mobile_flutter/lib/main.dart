import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const UnifyApp());
}

class UnifyApp extends StatelessWidget {
  const UnifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const CreateAccountScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// APP STRINGS — all user-facing text, ready for localization
// ═══════════════════════════════════════════════════════════════════════════

class AppStrings {
  AppStrings._();
  static const String appTitle = 'UNIFY';
  static const String createAccount = 'Create Account';
  static const String subtitle =
      'Join 2,000+ GCTU students. One app for events, study groups, and campus news.';
  static const String trustVerified = '🔒 Student-verified';
  static const String trustCampus = '🎓 Campus-only';
  static const String trustInstant = '⚡ Instant access';
  static const String continueWithGoogle = 'Continue with Google';
  static const String orSignUpEmail = 'or sign up with email';
  static const String studentEmail = 'Student email';
  static const String emailHint = 'your.name@gctu.edu.gh';
  static const String password = 'Password';
  static const String passwordHint = 'Create a secure password';
  static const String alreadyOnUnify = 'Already on UNIFY? ';
  static const String signIn = 'Sign In';
  static const String chars8 = '8+ chars';
  static const String num1 = '1 number';
  static const String symbol1 = '1 symbol';
  static const String emailRequired = 'Email is required';
  static const String emailInvalid =
      'Use your GCTU student email (@gctu.edu.gh)';
  static const String passwordRequired = 'Password is required';
  static const String passwordWeak =
      'Must be at least 8 characters with a number and a symbol';
  static const String googleError = 'Google sign-in failed. Please try again.';
  static const String signUpSuccess = 'Account created! Welcome to UNIFY.';
  static const String signUpError = 'Could not create account. Please try again.';
}

// ═══════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════════════════

class UnifyColors {
  UnifyColors._();
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryDeeper = Color(0xFF1E3A8A);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = Color(0xFF2563EB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textDark = Color(0xFF374151);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color googleHover = Color(0xFFF9FAFB);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
}

class UnifyTextStyles {
  UnifyTextStyles._();
  static const TextStyle headline = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: UnifyColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: UnifyColors.textSecondary,
    height: 1.5,
  );
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: UnifyColors.textDark,
  );
  static const TextStyle buttonWhite = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static const TextStyle googleButton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: UnifyColors.textDark,
  );
  static const TextStyle footer = TextStyle(
    fontSize: 14,
    color: UnifyColors.textSecondary,
  );
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: UnifyColors.primary,
  );
  static const TextStyle trustPill = TextStyle(
    fontSize: 12,
    color: UnifyColors.textSecondary,
  );
  static const TextStyle dividerText = TextStyle(
    fontSize: 13,
    color: UnifyColors.textMuted,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle inputHint = TextStyle(
    fontSize: 15,
    color: UnifyColors.textMuted,
  );
  static const TextStyle checkText = TextStyle(
    fontSize: 12,
    color: UnifyColors.textSecondary,
  );
  static const TextStyle checkTextInactive = TextStyle(
    fontSize: 12,
    color: UnifyColors.textMuted,
  );
  static const TextStyle errorText = TextStyle(
    fontSize: 12,
    color: UnifyColors.error,
    fontWeight: FontWeight.w500,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// LOGO PAINTER — pixel-exact SVG geometry (#2563EB bg, white figures)
// ═══════════════════════════════════════════════════════════════════════════

class UnifyLogoPainter extends CustomPainter {
  const UnifyLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;

    // Blue rounded square background
    final bg = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20),
    );
    canvas.drawRRect(bg, Paint()..color = const Color(0xFF2563EB));

    // White figure paint
    final white = Paint()..color = Colors.white;

    // Left head (cx=32, cy=23, r=11)
    canvas.drawCircle(Offset(32 * s, 23 * s), 11 * s, white);

    // Right head (cx=68, cy=23, r=11)
    canvas.drawCircle(Offset(68 * s, 23 * s), 11 * s, white);

    // Left body path — evenodd fill rule (SVG geometry)
    final leftPath = Path()
      ..moveTo(13 * s, 34 * s)
      ..cubicTo(13 * s, 21 * s, 51 * s, 21 * s, 51 * s, 34 * s)
      ..lineTo(51 * s, 67 * s)
      ..cubicTo(51 * s, 80 * s, 43 * s, 88 * s, 32 * s, 88 * s)
      ..cubicTo(21 * s, 88 * s, 13 * s, 80 * s, 13 * s, 67 * s)
      ..close()
      ..moveTo(24 * s, 46 * s)
      ..cubicTo(24 * s, 33 * s, 44 * s, 33 * s, 44 * s, 46 * s)
      ..lineTo(44 * s, 67 * s)
      ..cubicTo(44 * s, 74 * s, 39 * s, 79 * s, 32 * s, 79 * s)
      ..cubicTo(25 * s, 79 * s, 24 * s, 74 * s, 24 * s, 67 * s)
      ..close();
    canvas.drawPath(leftPath, white);

    // Right body path — evenodd fill rule (SVG geometry)
    final rightPath = Path()
      ..moveTo(87 * s, 34 * s)
      ..cubicTo(87 * s, 21 * s, 49 * s, 21 * s, 49 * s, 34 * s)
      ..lineTo(49 * s, 67 * s)
      ..cubicTo(49 * s, 80 * s, 57 * s, 88 * s, 68 * s, 88 * s)
      ..cubicTo(79 * s, 88 * s, 87 * s, 80 * s, 87 * s, 67 * s)
      ..close()
      ..moveTo(76 * s, 46 * s)
      ..cubicTo(76 * s, 33 * s, 56 * s, 33 * s, 56 * s, 46 * s)
      ..lineTo(56 * s, 67 * s)
      ..cubicTo(56 * s, 74 * s, 61 * s, 79 * s, 68 * s, 79 * s)
      ..cubicTo(75 * s, 79 * s, 76 * s, 74 * s, 76 * s, 67 * s)
      ..close();
    canvas.drawPath(rightPath, white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// CREATE ACCOUNT SCREEN — FIXED
// ═══════════════════════════════════════════════════════════════════════════

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscurePassword = true;
  String _password = '';
  int _passwordStrength = 0;
  bool _googleLoading = false;
  bool _submitting = false;
  String? _emailErrorText;
  String? _passErrorText;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_clearEmailError);
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_clearEmailError);
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _clearEmailError() {
    if (_emailErrorText != null) setState(() => _emailErrorText = null);
  }

  bool _validateEmail(String? value) {
    final email = (value ?? _emailCtrl.text).trim();
    if (email.isEmpty) {
      setState(() => _emailErrorText = AppStrings.emailRequired);
      return false;
    }
    if (!email.endsWith('@gctu.edu.gh')) {
      setState(() => _emailErrorText = AppStrings.emailInvalid);
      return false;
    }
    setState(() => _emailErrorText = null);
    return true;
  }

  bool _validatePassword(String? value) {
    final pass = value ?? _password;
    if (pass.isEmpty) {
      setState(() => _passErrorText = AppStrings.passwordRequired);
      return false;
    }
    if (pass.length < 8 ||
        !pass.contains(RegExp(r'[0-9]')) ||
        !pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      setState(() => _passErrorText = AppStrings.passwordWeak);
      return false;
    }
    setState(() => _passErrorText = null);
    return true;
  }

  bool _validate() {
    final emailValid = _validateEmail(null);
    final passValid = _validatePassword(null);
    return emailValid && passValid;
  }

  void _checkPasswordStrength(String value) {
    int strength = 0;
    if (value.length >= 8) strength++;
    if (value.contains(RegExp(r'[0-9]'))) strength++;
    if (value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    setState(() {
      _password = value;
      _passwordStrength = strength;
      if (_passErrorText != null && strength >= 3) _passErrorText = null;
    });
  }

  Color _barColor(int index) {
    if (index >= _passwordStrength) return UnifyColors.border;
    if (_passwordStrength <= 1) return UnifyColors.error;
    if (_passwordStrength == 2) return UnifyColors.warning;
    return UnifyColors.success;
  }

  Future<void> _onGoogleSignIn() async {
    setState(() => _googleLoading = true);
    try {
      // Simulate auth delay — replace with real Google sign-in
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      _showSnackBar(AppStrings.continueWithGoogle, UnifyColors.success);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(AppStrings.googleError, UnifyColors.error);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _onSubmit() async {
    if (!_validate()) return;
    setState(() => _submitting = true);
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      _showSnackBar(AppStrings.signUpSuccess, UnifyColors.success);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(AppStrings.signUpError, UnifyColors.error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  bool get _canSubmit =>
      _emailCtrl.text.trim().endsWith('@gctu.edu.gh') &&
      _passwordStrength >= 3 &&
      !_submitting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifyColors.surfaceWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Progress Steps
              const _ProgressSteps(key: ValueKey('progress_steps')),

              const SizedBox(height: 16),

              // Back button — 48dp touch target
              Semantics(
                label: 'Go back',
                button: true,
                child: IconButton(
                  key: const ValueKey('back_button'),
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Logo — flat, no shadow
              Semantics(
                label: 'UNIFY logo',
                child: Center(
                  child: Container(
                    key: const ValueKey('unify_logo'),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const CustomPaint(
                      size: Size(80, 80),
                      painter: UnifyLogoPainter(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Headline
              Semantics(
                header: true,
                child: const Center(
                  child: Text(
                    AppStrings.createAccount,
                    style: UnifyTextStyles.headline,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              const Center(
                child: Text(
                  AppStrings.subtitle,
                  style: UnifyTextStyles.subtitle,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // Trust pills
              Semantics(
                label: 'Trust signals',
                excludeSemantics: true,
                child: const _TrustPillsRow(key: ValueKey('trust_pills')),
              ),

              const SizedBox(height: 28),

              // Google sign-in button
              Semantics(
                label: AppStrings.continueWithGoogle,
                button: true,
                child: _GoogleButton(
                  key: const ValueKey('google_button'),
                  loading: _googleLoading,
                  onPressed: _googleLoading ? null : _onGoogleSignIn,
                ),
              ),

              const SizedBox(height: 20),

              // Divider
              Semantics(
                label: 'or sign up with email',
                excludeSemantics: true,
                child: const _DividerRow(key: ValueKey('divider')),
              ),

              const SizedBox(height: 20),

              // Email input
              Semantics(
                label: AppStrings.studentEmail,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 6),
                      child: Text(AppStrings.studentEmail, style: UnifyTextStyles.label),
                    ),
                    TextField(
                      key: const ValueKey('email_input'),
                      controller: _emailCtrl,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      onChanged: (_) {
                        if (_emailErrorText != null) _validateEmail(null);
                      },
                      decoration: _inputDecoration(
                        hint: AppStrings.emailHint,
                        errorText: _emailErrorText,
                      ),
                    ),
                    if (_emailErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 4),
                        child: Text(
                          _emailErrorText!,
                          style: UnifyTextStyles.errorText,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Password input
              Semantics(
                label: AppStrings.password,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 6),
                      child: Text(AppStrings.password, style: UnifyTextStyles.label),
                    ),
                    TextField(
                      key: const ValueKey('password_input'),
                      controller: _passCtrl,
                      focusNode: _passFocus,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: _checkPasswordStrength,
                      decoration: _inputDecoration(
                        hint: AppStrings.passwordHint,
                        errorText: _passErrorText,
                        suffix: IconButton(
                          key: const ValueKey('password_toggle'),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: UnifyColors.textMuted,
                            size: 20,
                          ),
                          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ),
                    if (_passErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 4),
                        child: Text(
                          _passErrorText!,
                          style: UnifyTextStyles.errorText,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Password strength bar
              Semantics(
                label: 'Password strength: $_passwordStrength of 3',
                child: _StrengthBar(
                  key: const ValueKey('strength_bar'),
                  strength: _passwordStrength,
                  barColor: _barColor,
                ),
              ),

              const SizedBox(height: 8),

              // Password checklist
              const _PasswordChecklist(key: ValueKey('password_checklist')),

              const SizedBox(height: 24),

              // Primary CTA
              Semantics(
                label: AppStrings.createAccount,
                button: true,
                child: _PrimaryButton(
                  key: const ValueKey('create_account_button'),
                  loading: _submitting,
                  enabled: _canSubmit,
                  onPressed: _canSubmit ? _onSubmit : null,
                ),
              ),

              const SizedBox(height: 24),

              // Footer
              Semantics(link: true, child: const _FooterRow(key: ValueKey('footer'))),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    String? errorText,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: UnifyTextStyles.inputHint,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorText: null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText != null ? UnifyColors.error : UnifyColors.border,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText != null ? UnifyColors.error : UnifyColors.border,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText != null ? UnifyColors.error : UnifyColors.borderFocus,
          width: 2,
        ),
      ),
      suffixIcon: suffix,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUB-WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stepBar(true),
        const SizedBox(width: 8),
        _stepBar(false),
        const SizedBox(width: 8),
        _stepBar(false),
      ],
    );
  }

  Widget _stepBar(bool active) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: active ? UnifyColors.primary : UnifyColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _TrustPillsRow extends StatelessWidget {
  const _TrustPillsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppStrings.trustVerified, style: UnifyTextStyles.trustPill),
        SizedBox(width: 16),
        Text(AppStrings.trustCampus, style: UnifyTextStyles.trustPill),
        SizedBox(width: 16),
        Text(AppStrings.trustInstant, style: UnifyTextStyles.trustPill),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: UnifyColors.surfaceWhite,
          disabledBackgroundColor: UnifyColors.googleHover,
          side: const BorderSide(color: UnifyColors.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/google.svg',
                    width: 20,
                    height: 20,
                    placeholderBuilder: (_) => const SizedBox(width: 20, height: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(AppStrings.continueWithGoogle, style: UnifyTextStyles.googleButton),
                ],
              ),
      ),
    );
  }
}

class _DividerRow extends StatelessWidget {
  const _DividerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: UnifyColors.border, thickness: 0.5)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(AppStrings.orSignUpEmail, style: UnifyTextStyles.dividerText),
        ),
        Expanded(child: Divider(color: UnifyColors.border, thickness: 0.5)),
      ],
    );
  }
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({
    super.key,
    required this.strength,
    required this.barColor,
  });

  final int strength;
  final Color Function(int index) barColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: barColor(index),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _PasswordChecklist extends StatelessWidget {
  const _PasswordChecklist({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild when password changes via a ListenableBuilder wrapping a parent
    return const _ChecklistRow();
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _CheckItem(text: AppStrings.chars8),
        SizedBox(width: 16),
        _CheckItem(text: AppStrings.num1),
        SizedBox(width: 16),
        _CheckItem(text: AppStrings.symbol1),
      ],
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.circle_outlined,
          size: 14,
          color: UnifyColors.textMuted,
        ),
        const SizedBox(width: 4),
        Text(text, style: UnifyTextStyles.checkTextInactive),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    super.key,
    required this.loading,
    required this.enabled,
    required this.onPressed,
  });

  final bool loading;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: UnifyColors.primary,
          disabledBackgroundColor: UnifyColors.primary.withValues(alpha: 0.5),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          elevation: enabled ? 4 : 0,
          shadowColor: UnifyColors.primary.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(AppStrings.createAccount),
      ),
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: const TextSpan(
          style: UnifyTextStyles.footer,
          children: [
            TextSpan(text: AppStrings.alreadyOnUnify),
            TextSpan(
              text: AppStrings.signIn,
              style: UnifyTextStyles.link,
              recognizer: null,
            ),
          ],
        ),
      ),
    );
  }
}
