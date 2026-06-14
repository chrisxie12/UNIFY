import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  final _progCtrl = TextEditingController();
  int _year = 1;
  String? _nameError;
  String? _progError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _progCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    String? nameErr;
    String? progErr;
    if (_nameCtrl.text.trim().length < 2) nameErr = 'Enter your full name';
    if (_progCtrl.text.trim().isEmpty) progErr = 'Enter your programme';
    setState(() {
      _nameError = nameErr;
      _progError = progErr;
    });
    return nameErr == null && progErr == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    await ref.read(authNotifierProvider.notifier).completeOnboarding(
          displayName: _nameCtrl.text.trim(),
          programme: _progCtrl.text.trim(),
          yearOfStudy: _year,
        );
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    state.whenOrNull(
      error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      ),
      data: (_) => context.go('/app/feed'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set up your profile', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text('Help us personalise your UNIFY experience.', style: AppTextStyles.body),
              const SizedBox(height: 36),
              AppTextField(
                label: 'Full Name',
                hint: 'Kwame Asante',
                controller: _nameCtrl,
                capitalization: TextCapitalization.words,
                errorText: _nameError,
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Programme',
                hint: 'BSc Computer Science',
                controller: _progCtrl,
                capitalization: TextCapitalization.words,
                errorText: _progError,
              ),
              const SizedBox(height: 20),
              Text('Year of Study', style: AppTextStyles.label),
              const SizedBox(height: 12),
              Row(
                children: List.generate(4, (i) {
                  final yr = i + 1;
                  final selected = _year == yr;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _year = yr),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                        height: 48,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF1D4ED8)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Year $yr',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              AppButton(
                label: 'Continue',
                loading: loading,
                onTap: loading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
