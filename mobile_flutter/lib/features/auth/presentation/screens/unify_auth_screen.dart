import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/survey_state_provider.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/unify_input_field.dart';
import '../../../../core/widgets/unify_logo.dart';
import '../../../../core/widgets/unify_primary_button.dart';
import '../../../../core/widgets/unify_secondary_button.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/unify_snackbar.dart';

class UnifyAuthScreen extends ConsumerStatefulWidget {
  final String mode;

  const UnifyAuthScreen({super.key, this.mode = 'signup'});

  @override
  ConsumerState<UnifyAuthScreen> createState() => _UnifyAuthScreenState();
}

class _UnifyAuthScreenState extends ConsumerState<UnifyAuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _loading = false;
  String? _error;
  bool _isSignup = true;
  bool _showPasswordForm = false;

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

  UserType? get _userType => ref.watch(surveyStateProvider).userType;

  bool get _isSHS => _userType == UserType.shsGraduate;
  bool get _isUni => _userType == UserType.universityStudent;

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email is required';
    if (_isUni) {
      final validDomains = [
        '@gctu.edu.gh', '@knust.edu.gh', '@ug.edu.gh',
        '@ucc.edu.gh', '@st.ug.edu.gh', '@std.uew.edu.gh',
        '@uds.edu.gh', '@upsa.edu.gh',
      ];
      final hasValidDomain = validDomains.any((d) => value.endsWith(d));
      if (!hasValidDomain) return 'Please use your official university email';
    }
    if (!value.contains('@')) return 'Enter a valid email address';
    return null;
  }

  String? _validatePass(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'At least 6 characters';
    return null;
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.gctu.unify://auth/callback',
      );
      if (!mounted) return;
      context.go('/app/feed');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Google sign-in failed. Please try again.');
      debugPrint('[UnifyAuth] Google error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signUp() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final emailErr = _validateEmail(email);
    final passErr = _validatePass(pass);
    if (emailErr != null || passErr != null) {
      setState(() => _error = emailErr ?? passErr);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email, password: pass,
      );
      if (res.user == null) throw Exception('Sign up failed');
      await _upsertProfile(res.user!.id);
      if (!mounted) return;
      if (res.session != null) {
        context.go('/app/feed');
      } else {
        _showConfirmationNotice();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = ErrorMapper.toUserMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final emailErr = _validateEmail(email);
    final passErr = _validatePass(pass);
    if (emailErr != null || passErr != null) {
      setState(() => _error = emailErr ?? passErr);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email, password: pass,
      );
      if (res.user == null) throw Exception('Sign in failed');
      await _upsertProfile(res.user!.id);
      if (!mounted) return;
      context.go('/app/feed');
    } catch (e) {
      if (!mounted) return;
      if (mounted) UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _upsertProfile(String userId) async {
    final payload = ref.read(surveyStateProvider).preProfilePayload;
    if (payload.isEmpty) return;
    await Supabase.instance.client.from('profiles').upsert({
      'id': userId,
      ...payload,
    });
  }

  void _showConfirmationNotice() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UnifyRadius.lg)),
        title: const Text('Check Your Inbox', style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700)),
        content: const Text(
          'Account created! Please check your email for a confirmation link, then sign in.',
          style: TextStyle(fontFamily: 'SpaceGrotesk', color: UnifyColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.of(ctx).pop(); },
            child: const Text('OK', style: TextStyle(fontFamily: 'SpaceGrotesk', color: UnifyColors.primaryBlue, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isSignup = !_isSignup;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifyColors.surfaceWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            UnifySpacing.s24,
            MediaQuery.of(context).padding.top + UnifySpacing.s32,
            UnifySpacing.s24,
            UnifySpacing.s24,
          ),
          child: Column(
            children: [
              UnifyLogo(size: 72, backgroundColor: UnifyColors.primaryBlue),
              const SizedBox(height: UnifySpacing.s16),
              Text(
                _isSignup ? 'Create Account' : 'Welcome Back',
                style: UnifyTextStyle.h2(),
              ),
              const SizedBox(height: UnifySpacing.s8),
              Text(
                _isSHS
                    ? 'SHS Graduates can quickly register with Google.'
                    : _isUni
                        ? 'Use your official university email to sign in.'
                        : 'Sign in to continue your UNIFY experience.',
                style: UnifyTextStyle.body(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UnifySpacing.s32),

              if (_isSHS) _buildSHSForm(),
              if (_isUni) _buildUniForm(),
              if (_userType == null) _buildFallback(),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: UnifySpacing.s16),
                  child: Text(
                    _error!,
                    style: UnifyTextStyle.caption(color: UnifyColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: UnifySpacing.s24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSignup ? 'Already have an account? ' : "Don't have an account? ",
                    style: UnifyTextStyle.bodySm(),
                  ),
                  GestureDetector(
                    onTap: _toggleMode,
                    child: Text(
                      _isSignup ? 'Sign In' : 'Sign Up',
                      style: UnifyTextStyle.bodySm(color: UnifyColors.primaryBlue),
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

  Widget _buildSHSForm() {
    if (!_showPasswordForm) {
      return Column(
        children: [
          UnifyPrimaryButton(
            label: 'Continue with Google',
            prefixIcon: const Icon(Icons.android, color: UnifyColors.textInverse, size: 20),
            loading: _loading,
            onPressed: _signInWithGoogle,
          ),
          const SizedBox(height: UnifySpacing.s12),
          UnifySecondaryButton(
            label: 'Use email instead',
            onPressed: () => setState(() => _showPasswordForm = true),
          ),
        ],
      );
    }
    return _buildEmailPassForm();
  }

  Widget _buildUniForm() {
    return _buildEmailPassForm();
  }

  Widget _buildEmailPassForm() {
    return Column(
      children: [
        UnifyInputField(
          controller: _emailCtrl,
          label: 'Email',
          hint: _isUni ? 'student@domain.edu.gh' : 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined, size: 20),
        ),
        const SizedBox(height: UnifySpacing.s16),
        UnifyInputField(
          controller: _passCtrl,
          label: 'Password',
          obscureText: _obscurePass,
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          suffixIcon: IconButton(
            icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 20, color: UnifyColors.textTertiary),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
        ),
        const SizedBox(height: UnifySpacing.s20),
        UnifyPrimaryButton(
          label: _isSignup ? 'Create Account' : 'Sign In',
          loading: _loading,
          onPressed: _isSignup ? _signUp : _signIn,
        ),
      ],
    );
  }

  Widget _buildFallback() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(UnifySpacing.s20),
          decoration: BoxDecoration(
            color: UnifyColors.warning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(UnifyRadius.md),
            border: Border.all(color: UnifyColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: UnifyColors.warning),
              const SizedBox(width: UnifySpacing.s12),
              Expanded(
                child: Text(
                  'Please complete the onboarding survey first.',
                  style: UnifyTextStyle.bodySm(color: UnifyColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: UnifySpacing.s16),
        UnifySecondaryButton(
          label: 'Go to Onboarding',
          onPressed: () => context.go('/onboarding'),
        ),
      ],
    );
  }
}
