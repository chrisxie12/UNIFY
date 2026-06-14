import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/colors.dart';

const _levels = ['Level 100', 'Level 200', 'Level 300', 'Level 400'];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _saving = false;

  // Step 0
  final _nameCtrl      = TextEditingController();
  final _programmeCtrl = TextEditingController();
  String _level = '';

  // Step 1
  final _bioCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _programmeCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  bool get _canAdvance {
    if (_step == 0) return _nameCtrl.text.trim().length > 1 && _level.isNotEmpty;
    return true;
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final sb   = Supabase.instance.client;
    final user = sb.auth.currentUser;

    if (user != null) {
      final levelValue = _level.replaceAll('Level ', '').toLowerCase();
      await sb.from('profiles').update({
        'full_name':  _nameCtrl.text.trim(),
        'bio':        _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        'level':      levelValue,
        'programme':  _programmeCtrl.text.trim().isEmpty ? null : _programmeCtrl.text.trim(),
      }).eq('id', user.id);
    }

    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (_step > 0)
                    GestureDetector(
                      onTap: () => setState(() => _step--),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.arrow_back, size: 20, color: kDark),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _step ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i <= _step ? kBlue1 : kBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _step == 0 ? 'Who are you?' : 'A little more',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kDark, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Step ${_step + 1} of 2',
                      style: const TextStyle(fontSize: 13, color: kGrey2),
                    ),
                    const SizedBox(height: 28),

                    if (_step == 0) ...[
                      _label('Full name'),
                      _textField(_nameCtrl, 'e.g. Kwame Acheampong', cap: TextCapitalization.words),
                      const SizedBox(height: 20),
                      _label('Programme'),
                      _textField(_programmeCtrl, 'e.g. BSc Computer Engineering'),
                      const SizedBox(height: 20),
                      _label('Year'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: _levels.map((l) => GestureDetector(
                          onTap: () => setState(() => _level = l),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: _level == l ? kBlue1 : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: _level == l ? kBlue1 : kBorder),
                            ),
                            child: Text(
                              l,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _level == l ? Colors.white : kGrey1,
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ] else ...[
                      _label('Bio'),
                      TextField(
                        controller: _bioCtrl,
                        maxLines: 4,
                        maxLength: 200,
                        style: const TextStyle(fontSize: 14, color: kDark),
                        decoration: InputDecoration(
                          hintText: 'Tell others a little about yourself… (optional)',
                          hintStyle: const TextStyle(color: kGrey3, fontSize: 14),
                          filled: true,
                          fillColor: kSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 16),
              child: GestureDetector(
                onTap: _canAdvance
                    ? () {
                        if (_step < 1) {
                          setState(() => _step++);
                        } else {
                          _finish();
                        }
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 52,
                  decoration: BoxDecoration(
                    color: _canAdvance ? kDark : kSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _saving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _step < 1 ? 'Continue' : 'Finish Setup',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _canAdvance ? Colors.white : kGrey3,
                            ),
                          ),
                  ),
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
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDark)),
      );

  Widget _textField(TextEditingController ctrl, String hint, {TextCapitalization cap = TextCapitalization.none}) =>
      TextField(
        controller: ctrl,
        textCapitalization: cap,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 14, color: kDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kGrey3, fontSize: 14),
          filled: true,
          fillColor: kSurface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
