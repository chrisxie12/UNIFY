import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/colors.dart';

class AuthScreen extends StatefulWidget {
  final String mode;
  const AuthScreen({super.key, required this.mode});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late String _mode;
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final emailOk = _emailCtrl.text.contains('@');
    final passOk  = _passCtrl.text.length >= 6;
    final nameOk  = _mode == 'login' || _nameCtrl.text.trim().length > 1;
    return emailOk && passOk && nameOk && !_loading;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _loading = true);
    final sb = Supabase.instance.client;

    try {
      if (_mode == 'login') {
        await sb.auth.signInWithPassword(
          email: _emailCtrl.text.trim().toLowerCase(),
          password: _passCtrl.text,
        );
        if (mounted) context.go('/home');
      } else {
        await sb.auth.signUp(
          email: _emailCtrl.text.trim().toLowerCase(),
          password: _passCtrl.text,
          data: {'full_name': _nameCtrl.text.trim()},
        );
        if (mounted) context.go('/onboarding');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: kRed),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.arrow_back, size: 20, color: kDark),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _mode == 'login' ? 'Welcome back' : 'Create account',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: kDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _mode == 'login'
                          ? 'Sign in to your UNIFY account.'
                          : 'Join GCTU — your campus hub awaits.',
                      style: const TextStyle(fontSize: 14, color: kGrey2),
                    ),
                    const SizedBox(height: 28),

                    // Mode toggle
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        children: [
                          _Tab(
                            label: 'Sign Up',
                            active: _mode == 'signup',
                            onTap: () => setState(() => _mode = 'signup'),
                          ),
                          _Tab(
                            label: 'Log In',
                            active: _mode == 'login',
                            onTap: () => setState(() => _mode = 'login'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name (signup only)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: _mode == 'signup'
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Full name'),
                                _field(
                                  ctrl: _nameCtrl,
                                  hint: 'e.g. Kwame Acheampong',
                                  cap: TextCapitalization.words,
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 16),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    _label('Email'),
                    _field(
                      ctrl: _emailCtrl,
                      hint: 'you@students.gctu.edu.gh',
                      type: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    _label('Password'),
                    _passField(),
                    const SizedBox(height: 32),

                    // Submit
                    GestureDetector(
                      onTap: _canSubmit ? _submit : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 52,
                        decoration: BoxDecoration(
                          color: _canSubmit ? kDark : kSurface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _mode == 'login' ? 'Sign In' : 'Create Account',
                                  style: TextStyle(
                                    color: _canSubmit ? Colors.white : kGrey3,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDark),
        ),
      );

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    TextInputType type = TextInputType.text,
    TextCapitalization cap = TextCapitalization.none,
    ValueChanged<String>? onChanged,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        textCapitalization: cap,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: kDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: kGrey3, fontSize: 14),
          filled: true,
          fillColor: kSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  Widget _passField() => TextField(
        controller: _passCtrl,
        obscureText: _obscure,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 14, color: kDark),
        decoration: InputDecoration(
          hintText: _mode == 'signup' ? 'At least 6 characters' : '••••••••',
          hintStyle: TextStyle(color: kGrey3, fontSize: 14),
          filled: true,
          fillColor: kSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: kGrey3),
          ),
        ),
      );
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              boxShadow: active
                  ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 1))]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? kDark : kGrey3,
                ),
              ),
            ),
          ),
        ),
      );
}
