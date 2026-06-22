import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/design_tokens.dart';
import 'steps/step_identity.dart';
import 'steps/step_shs_personal_info.dart';
import 'steps/step_shs_education.dart';
import 'steps/step_shs_university_interest.dart';
import 'steps/step_shs_goals.dart';
import 'steps/step_uni_selection.dart';
import 'steps/step_uni_email_verify.dart';
import 'steps/step_uni_academic_details.dart';
import 'steps/step_interests.dart';
import 'steps/step_preview.dart';

enum UserIdentity { shs, uni }

class OnboardingData {
  UserIdentity? identity;

  String? shsFullName;
  String? shsPhone;
  String? shsLocation;
  String? shsSchoolName;
  int? shsYearCompleted;
  String? shsWassceGrades;
  String? shsPreferredUniversity;
  String? shsIntendedProgram;

  String? uniSelectedUniversity;
  String? uniEmail;
  bool uniEmailVerified = false;
  String? uniDepartment;
  String? uniLevel;
  String? uniStudentId;

  List<String> goals = [];
  List<String> interests = [];

  bool get isSHS => identity == UserIdentity.shs;
  bool get isUni => identity == UserIdentity.uni;

  Map<String, dynamic> toProfilePayload() {
    final base = <String, dynamic>{
      'user_type': isSHS ? 'shs_graduate' : 'university_student',
      'full_name': isSHS ? shsFullName : '',
      'phone': isSHS ? shsPhone : '',
      'goals': goals,
      'interests': interests,
      'onboarding_complete': true,
    };
    if (isSHS) {
      base.addAll({
        'location': shsLocation,
        'school_name': shsSchoolName,
        'year_completed': shsYearCompleted,
        'wassce_grades': shsWassceGrades,
        'preferred_university': shsPreferredUniversity,
        'intended_program': shsIntendedProgram,
      });
    } else {
      base.addAll({
        'university': uniSelectedUniversity,
        'university_email': uniEmail,
        'email_verified': uniEmailVerified,
        'department': uniDepartment,
        'level': uniLevel,
        'student_id': uniStudentId,
      });
    }
    return base;
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageCtrl;
  late final AnimationController _enterCtrl;
  final _data = OnboardingData();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: UnifyAnim.enter,
    )..forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  List<Widget> get _steps {
    final buildStep = _buildStep;
    if (_data.identity == null) return [buildStep(0)];
    if (_data.isSHS) {
      return [
        buildStep(0), buildStep(1), buildStep(2),
        buildStep(3), buildStep(4), buildStep(5), buildStep(6),
      ];
    }
    return [
      buildStep(0), buildStep(7), buildStep(8),
      buildStep(9), buildStep(4), buildStep(5), buildStep(6),
    ];
  }

  int get _totalSteps => _steps.length;
  int get _currentPage => _pageCtrl.hasClients ? _pageCtrl.page!.round() : 0;

  /// Both the SHS and University flows are 7 steps; show that even before a
  /// path is chosen (when [_steps] is still just the identity step).
  static const int _flowLength = 7;

  String get _progressLabel => 'Step ${_currentPage + 1} of $_flowLength';

  Widget _buildStep(int index) {
    switch (index) {
      case 0:
        return StepIdentity(
          data: _data,
          animCtrl: _enterCtrl,
          onChanged: () => setState(() {}),
        );
      case 1:
        return StepShsPersonalInfo(
          data: _data,
          animCtrl: _enterCtrl,
        );
      case 2:
        return StepShsEducation(
          data: _data,
          animCtrl: _enterCtrl,
        );
      case 3:
        return StepShsUniversityInterest(
          data: _data,
          animCtrl: _enterCtrl,
        );
      case 4:
        return StepShsGoals(
          data: _data,
          animCtrl: _enterCtrl,
        );
      case 5:
        return StepInterests(
          data: _data,
          animCtrl: _enterCtrl,
        );
      case 6:
        return StepPreview(
          data: _data,
          animCtrl: _enterCtrl,
        );
      case 7:
        return StepUniSelection(
          data: _data,
          animCtrl: _enterCtrl,
        );
      case 8:
        return StepUniEmailVerify(
          data: _data,
          animCtrl: _enterCtrl,
        );
      case 9:
        return StepUniAcademicDetails(
          data: _data,
          animCtrl: _enterCtrl,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _goNext() {
    if (_currentPage < _totalSteps - 1) {
      _pageCtrl.nextPage(
        duration: UnifyAnim.normal,
        curve: UnifyAnim.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
        duration: UnifyAnim.normal,
        curve: UnifyAnim.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'pending_onboarding_payload',
          _data.toProfilePayload().toString(),
        );
        if (!mounted) return;
        context.go('/auth');
        return;
      }
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        ..._data.toProfilePayload(),
      });
      if (!mounted) return;
      context.go('/app/feed');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to save. Please try again.');
      debugPrint('[Onboarding] $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _onStepChanged(int page) {
    setState(() {});
    _enterCtrl.reset();
    _enterCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifyColors.surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: _onStepChanged,
                itemCount: _totalSteps,
                itemBuilder: (_, i) => _steps[i],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _goBack,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: UnifyColors.surfaceElevated,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: UnifyColors.textPrimary,
                    size: 22,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _progressLabel.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: UnifyColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Segmented progress bar
          Row(
            children: [
              for (int i = 0; i < _flowLength; i++) ...[
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: i <= _currentPage
                          ? const LinearGradient(
                              colors: [UnifyColors.primaryBlue, UnifyColors.accentPurple],
                            )
                          : null,
                      color: i <= _currentPage ? null : UnifyColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                if (i < _flowLength - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLast = _currentPage == _totalSteps - 1;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        UnifySpacing.s20,
        UnifySpacing.s12,
        UnifySpacing.s20,
        MediaQuery.of(context).padding.bottom + UnifySpacing.s20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error!,
                style: UnifyTextStyle.caption(color: UnifyColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          _GradientContinueButton(
            label: isLast ? 'Complete Setup' : 'Continue',
            enabled: _canProceed,
            loading: _submitting,
            onTap: _goNext,
          ),
        ],
      ),
    );
  }

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return _data.identity != null;
      case 1:
        if (_data.isSHS) {
          return (_data.shsFullName?.isNotEmpty ?? false) &&
              (_data.shsPhone?.isNotEmpty ?? false);
        }
        return _data.uniSelectedUniversity != null;
      case 2:
        if (_data.isSHS) return _data.shsSchoolName != null;
        return _data.uniEmailVerified;
      case 3:
        if (_data.isSHS) return _data.shsPreferredUniversity != null;
        return (_data.uniDepartment?.isNotEmpty ?? false) &&
            (_data.uniLevel?.isNotEmpty ?? false);
      case 4:
        return _data.goals.isNotEmpty;
      case 5:
        return _data.interests.isNotEmpty;
      case 6:
        return true;
      default:
        return false;
    }
  }
}

// ── Gradient continue button ────────────────────────────────────────────────

class _GradientContinueButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _GradientContinueButton({
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [UnifyColors.primaryBlue, UnifyColors.accentPurple],
                )
              : null,
          color: active ? null : UnifyColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: UnifyColors.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: active ? Colors.white : UnifyColors.textTertiary,
                ),
              ),
      ),
    );
  }
}
