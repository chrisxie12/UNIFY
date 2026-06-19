import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/unify_snackbar.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.mode});

  final String mode; // 'signup' | 'login'

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isSignup;
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscurePass = true;
  String? _emailError;
  String? _passError;

  @override
  void initState() {
    super.initState();
    _isSignup = widget.mode == 'signup';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;
    final emailErr = (email.isEmpty || !email.contains('@')) ? 'Enter a valid email' : null;
    final passErr  = pass.length < 6 ? 'At least 6 characters' : null;
    setState(() {
      _emailError = emailErr;
      _passError  = passErr;
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
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Enter your email and we'll send a password reset link."),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', hintText: 'you@university.edu'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: sending
                  ? null
                  : () async {
                      final email = emailCtrl.text.trim();
                      if (email.isEmpty || !email.contains('@')) return;
                      setS(() => sending = true);
                      try {
                        await ref.read(authNotifierProvider.notifier).resetPassword(email);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Check your inbox for a reset link.')),
                          );
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          setS(() => sending = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                          );
                        }
                      }
                    },
              child: sending
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Send Link'),
            ),
          ],
        ),
      ),
    );
    emailCtrl.dispose();
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    if (_isSignup) {
      await notifier.signUp(email: _emailCtrl.text.trim(), password: _passCtrl.text);
    } else {
      await notifier.signIn(email: _emailCtrl.text.trim(), password: _passCtrl.text);
    }
    final state = ref.read(authNotifierProvider);
    if (!mounted) return;
    state.whenOrNull(
      error: (e, _) => UnifySnackbar.error(context, ErrorMapper.toUserMessage(e)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: context.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand mark
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'U',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Heading
              Text(
                _isSignup ? 'Create account' : 'Welcome back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isSignup
                    ? 'Sign up with your university email'
                    : 'Sign in to your UNIFY account',
                style: TextStyle(fontSize: 14, color: context.textSecondary),
              ),
              const SizedBox(height: 32),

              // Email field
              _Label('Email'),
              const SizedBox(height: 6),
              _InputField(
                controller: _emailCtrl,
                hint: 'you@university.edu.gh',
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 16),

              // Password field
              _Label('Password'),
              const SizedBox(height: 6),
              _InputField(
                controller: _passCtrl,
                hint: '••••••••',
                obscure: _obscurePass,
                errorText: _passError,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: context.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
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
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.primary,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: context.primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isSignup ? 'Create Account' : 'Sign In'),
                ),
              ),

              const SizedBox(height: 24),

              // Toggle mode
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSignup ? 'Already have an account? ' : "Don't have an account? ",
                    style: TextStyle(fontSize: 14, color: context.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isSignup = !_isSignup),
                    child: Text(
                      _isSignup ? 'Sign In' : 'Sign Up',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable form helpers ──────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary),
  );
}

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
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: TextStyle(fontSize: 15, color: context.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.textSecondary),
        errorText: errorText,
        suffixIcon: suffix,
        filled: true,
        fillColor: context.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderCol, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderCol, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.primary, width: 1.5),
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
