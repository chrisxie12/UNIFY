import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import 'steps/step_profile_photo.dart';
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

  String? photoUrl;

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
        buildStep(3), buildStep(4), buildStep(5),
        buildStep(10), buildStep(6),
      ];
    }
    return [
      buildStep(0), buildStep(7), buildStep(8),
      buildStep(9), buildStep(4), buildStep(5),
      buildStep(10), buildStep(6),
    ];
  }

  int get _totalSteps => _steps.length;
  int get _currentPage => _pageCtrl.hasClients ? _pageCtrl.page!.round() : 0;

  String get _progressLabel => 'Step ${_currentPage + 1} of $_totalSteps';

  void _onStepDataChanged() => setState(() {});

  Widget _buildStep(int index) {
    final onChanged = _onStepDataChanged;
    switch (index) {
      case 0:
        return StepIdentity(
          data: _data, animCtrl: _enterCtrl, onChanged: onChanged,
        );
      case 1:
        return StepShsPersonalInfo(
          data: _data, animCtrl: _enterCtrl, onChanged: onChanged,
        );
      case 2:
        return StepShsEducation(
          data: _data, animCtrl: _enterCtrl, onChanged: onChanged,
        );
      case 3:
        return StepShsUniversityInterest(
          data: _data, animCtrl: _enterCtrl, onChanged: onChanged,
        );
      case 4:
        return StepShsGoals(
          data: _data, animCtrl: _enterCtrl, onChanged: onChanged,
        );
      case 5:
        return StepInterests(
          data: _data, animCtrl: _enterCtrl, onChanged: onChanged,
        );
      case 6:
        return StepPreview(
          data: _data, animCtrl: _enterCtrl,
        );
      case 7:
        return StepUniSelection(
          data: _data, animCtrl: _enterCtrl, onChanged: onChanged,
        );
      case 8:
        return StepUniEmailVerify(
          data: _data, animCtrl: _enterCtrl, onChanged: onChanged,
        );
      case 9:
        return StepUniAcademicDetails(
          data: _data, animCtrl: _enterCtrl, onChanged: onChanged,
        );
      case 10:
        return StepProfilePhoto(
          data: _data, animCtrl: _enterCtrl, onChanged: onChanged,
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _goBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: UnifyColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(UnifyRadius.md),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: UnifyColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _progressLabel.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: UnifyColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: UnifyColors.primaryBlue,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: const Icon(Icons.group, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_totalSteps, (i) {
              final filled = i <= _currentPage;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: filled
                          ? UnifyColors.primaryBlue
                          : UnifyColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLast = _currentPage == _totalSteps - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).padding.bottom + 20,
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
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _canProceed
                  ? (_submitting ? null : _goNext)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: UnifyColors.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    UnifyColors.primaryBlue.withValues(alpha: 0.4),
                elevation: 2,
                shadowColor: UnifyColors.primaryBlue.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isLast ? 'Complete Setup' : 'Continue'),
            ),
          ),
          if (_currentPage > 0)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GestureDetector(
                onTap: _goBack,
                child: Text(
                  'Go back',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: UnifyColors.textSecondary,
                  ),
                ),
              ),
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
      case 7:
        return true;
      default:
        return false;
    }
  }
}
