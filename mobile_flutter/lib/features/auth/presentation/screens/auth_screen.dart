import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../../../core/widgets/unify_logo.dart';
import '../../../../core/extensions/theme_extensions.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.mode});

  final String mode; // 'signup' | 'login'

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late bool _isSignup;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  String? _emailError;
  String? _passError;
  bool _googleLoading = false;
  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _isSignup = widget.mode == 'signup';
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final emailErr =
        (email.isEmpty || !email.contains('@')) ? 'Enter a valid email' : null;
    final passErr = pass.length < 6 ? 'At least 6 characters' : null;
    setState(() {
      _emailError = emailErr;
      _passError = passErr;
    });
    return emailErr == null && passErr == null;
  }

  Future<void> _showForgotPassword() async {
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    bool sending = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Reset Password',
              style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter your email and we'll send a password reset link.",
                style: GoogleFonts.spaceGrotesk(color: ctx.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email', hintText: 'you@university.edu'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600)),
            ),
            FilledButton(
              onPressed: sending
                  ? null
                  : () async {
                      final email = emailCtrl.text.trim();
                      if (email.isEmpty || !email.contains('@')) return;
                      setS(() => sending = true);
                      try {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .resetPassword(email);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          UnifySnackbar.success(
                              ctx, 'Check your inbox for a reset link.');
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          setS(() => sending = false);
                          UnifySnackbar.error(
                              ctx, ErrorMapper.toUserMessage(e));
                        }
                      }
                    },
              child: sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Send Link',
                      style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
    emailCtrl.dispose();
  }

  Future<void> _signInWithGoogle() async {
    debugPrint('[Auth] Google sign-in requested');
    setState(() => _googleLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    } catch (e) {
      debugPrint('[Auth] Google sign-in error: $e');
      if (!mounted) return;
      UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    if (_isSignup) {
      await notifier.signUp(
          email: _emailCtrl.text.trim(), password: _passCtrl.text);
    } else {
      await notifier.signIn(
          email: _emailCtrl.text.trim(), password: _passCtrl.text);
    }
    final state = ref.read(authNotifierProvider);
    if (!mounted) return;
    state.whenOrNull(
      error: (e, _) =>
          UnifySnackbar.error(context, ErrorMapper.toUserMessage(e)),
      data: (_) {
        if (_isSignup) {
          UnifySnackbar.success(
            context,
            'Account created! Check your inbox for a confirmation link, then sign in.',
          );
          setState(() => _isSignup = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authNotifierProvider.select((s) => s.isLoading));
    final primary = context.primary;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              painter: _AuthBgPainter(progress: _bgCtrl.value, isDark: isDark),
              size: Size.infinite,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Glowing logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.25),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const UnifyLogo(size: 80),
                      ),
                      const SizedBox(height: 28),

                      // Heading
                      Text(
                        _isSignup ? 'Create Account' : 'Welcome Back',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSignup
                            ? 'Join the campus community and stay\nconnected with your peers.'
                            : 'Sign in to continue with your UNIFY account.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          color: textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Google sign-in
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed:
                              _googleLoading ? null : _signInWithGoogle,
                          icon: _googleLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Image.asset(
                                  'assets/google_logo.png',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.g_mobiledata_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                          label: Text(
                            'Continue with Google',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            disabledBackgroundColor: primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // OR divider
                      Row(
                        children: [
                          const Expanded(child: _OrLine()),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textSecondary.withValues(alpha: 0.4),
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const Expanded(child: _OrLine()),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Email field
                      _InputField(
                        controller: _emailCtrl,
                        hint: 'Email address',
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                      ),
                      const SizedBox(height: 14),

                      // Password field
                      _InputField(
                        controller: _passCtrl,
                        hint: 'Password',
                        obscure: _obscurePass,
                        errorText: _passError,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                            color: textSecondary,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),

                      if (!_isSignup) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _showForgotPassword,
                            child: Text(
                              'Forgot password?',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                primary.withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isSignup ? 'Create Account' : 'Sign In',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Toggle mode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSignup
                                ? 'Already have an account?'
                                : "Don't have an account?",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isSignup = !_isSignup),
                            child: Text(
                              _isSignup ? 'Sign In' : 'Sign Up',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated background painter ──────────────────────────────────────────────

class _AuthBgPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _AuthBgPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    final baseColor = isDark ? const Color(0xFF0D0F13) : const Color(0xFFFFFFFF);
    final accentColor = isDark
        ? const Color(0xFF1E3A5F)
        : const Color(0xFFEBF0FF);

    canvas.drawRect(Offset.zero & size, Paint()..color = baseColor);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: 0.6),
          accentColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width * (0.4 + math.sin(t * 0.2) * 0.2),
          size.height * (0.3 + math.cos(t * 0.15) * 0.15),
        ),
        radius: size.width * 0.7,
      ));
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _AuthBgPainter old) => old.progress != progress;
}

// ── OR divider line ─────────────────────────────────────────────────────────

class _OrLine extends StatelessWidget {
  const _OrLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            context.textSecondary.withValues(alpha: 0.15),
            context.textSecondary.withValues(alpha: 0.15),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}

// ── Reusable form helpers ──────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.errorText,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? errorText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 15,
        color: theme.colorScheme.onSurface,
      ),
      cursorColor: theme.colorScheme.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.spaceGrotesk(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          fontSize: 15,
        ),
        errorText: errorText,
        suffixIcon: suffix,
        filled: true,
        fillColor: context.inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            color: context.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }
}
