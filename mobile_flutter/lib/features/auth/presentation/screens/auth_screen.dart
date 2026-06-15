import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final String mode; // 'signup' | 'login'
  const AuthScreen({super.key, required this.mode});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isSignup;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
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
    String? emailErr;
    String? passErr;
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty || !email.contains('@')) emailErr = 'Enter a valid email';
    if (pass.length < 6) passErr = 'Password must be at least 6 characters';

    setState(() {
      _emailError = emailErr;
      _passError = passErr;
    });
    return emailErr == null && passErr == null;
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
      error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      ),
    );
    // Router redirect handles navigation on success
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final loading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                _isSignup ? 'Create account' : 'Welcome back',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 8),
              Text(
                _isSignup
                    ? 'Sign up with your university email'
                    : 'Sign in to your UNIFY account',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 36),
              AppTextField(
                label: 'Email',
                hint: 'you@university.edu.gh',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passCtrl,
                obscure: true,
                errorText: _passError,
              ),
              if (!_isSignup) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {}, // TODO: forgot password flow
                    child: Text('Forgot password?', style: AppTextStyles.caption),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              AppButton(
                label: _isSignup ? 'Create Account' : 'Sign In',
                loading: loading,
                onTap: loading ? null : _submit,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSignup ? 'Already have an account? ' : "Don't have an account? ",
                    style: AppTextStyles.body,
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isSignup = !_isSignup),
                    child: Text(
                      _isSignup ? 'Sign In' : 'Sign Up',
                      style: AppTextStyles.bodySemi.copyWith(color: AppColors.primaryLight),
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
