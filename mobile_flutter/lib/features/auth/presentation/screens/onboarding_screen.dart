import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

const _levels = ['Level 100', 'Level 200', 'Level 300', 'Level 400', 'PG'];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  bool _saving = false;

  // Step 0
  final _nameCtrl = TextEditingController();
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
    if (_step == 0) {
      return _nameCtrl.text.trim().length > 1 && _level.isNotEmpty;
    }
    return true;
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final sb = Supabase.instance.client;
    final user = sb.auth.currentUser;

    if (user != null) {
      final levelValue = _level
          .replaceAll('Level ', '')
          .toLowerCase();
      await sb.from('profiles').update({
        'full_name': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        'level': levelValue,
        'programme': _programmeCtrl.text.trim().isEmpty
            ? null
            : _programmeCtrl.text.trim(),
      }).eq('id', user.id);
    }

    if (mounted) context.go('/app/feed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Step indicator header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (_step > 0)
                    GestureDetector(
                      onTap: () => setState(() => _step--),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: AppColors.dark,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        2,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _step ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i <= _step
                                ? AppColors.primary
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
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
                      style: AppTextStyles.headingXL,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Step ${_step + 1} of 2',
                      style:
                          AppTextStyles.bodyS.copyWith(color: AppColors.grey2),
                    ),
                    const SizedBox(height: 28),

                    if (_step == 0) ...[
                      _label('Full name'),
                      _textField(
                        _nameCtrl,
                        'e.g. Kwame Acheampong',
                        cap: TextCapitalization.words,
                      ),
                      const SizedBox(height: 20),
                      _label('Programme'),
                      _textField(
                        _programmeCtrl,
                        'e.g. BSc Computer Engineering',
                      ),
                      const SizedBox(height: 20),
                      _label('Year / Level'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _levels
                            .map(
                              (l) => GestureDetector(
                                onTap: () => setState(() => _level = l),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _level == l
                                        ? AppColors.primary
                                        : AppColors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: _level == l
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Text(
                                    l,
                                    style: AppTextStyles.labelM.copyWith(
                                      color: _level == l
                                          ? AppColors.white
                                          : AppColors.grey1,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ] else ...[
                      _label('Bio'),
                      TextField(
                        controller: _bioCtrl,
                        maxLines: 4,
                        maxLength: 200,
                        style: AppTextStyles.bodyM
                            .copyWith(color: AppColors.dark),
                        decoration: const InputDecoration(
                          hintText:
                              'Tell others a little about yourself… (optional)',
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                MediaQuery.of(context).padding.bottom + 16,
              ),
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
                    color:
                        _canAdvance ? AppColors.dark : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _step < 1 ? 'Continue' : 'Finish Setup',
                            style: AppTextStyles.buttonL.copyWith(
                              color: _canAdvance
                                  ? AppColors.white
                                  : AppColors.grey3,
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
        child: Text(text, style: AppTextStyles.labelM),
      );

  Widget _textField(
    TextEditingController ctrl,
    String hint, {
    TextCapitalization cap = TextCapitalization.none,
  }) =>
      TextField(
        controller: ctrl,
        textCapitalization: cap,
        onChanged: (_) => setState(() {}),
        style: AppTextStyles.bodyM.copyWith(color: AppColors.dark),
        decoration: InputDecoration(hintText: hint),
      );
}
