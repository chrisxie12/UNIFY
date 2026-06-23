import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/design_tokens.dart';
import 'steps/step_identity.dart';
import 'steps/step_personal_details.dart';
import 'steps/step_academic.dart';
import 'steps/step_shs_goals.dart';
import 'steps/step_interests.dart';
import 'steps/step_profile_photo.dart';
import 'steps/step_preview.dart';

enum UserIdentity { shs, uni }

class OnboardingData {
  UserIdentity? identity;

  // Shared personal details (collected for both paths at step 2)
  String? fullName;
  String? email;

  // Shared profile photo (local file path, step 6 — optional)
  String? photoPath;

  String? shsFullName;
  String? shsPhone;
  String? shsLocation;
  String? shsSchoolName;
  int? shsYearCompleted;
  String? shsWassceGrades;
  String? shsPreferredUniversity;
  String? shsIntendedProgram;
  String? shsStatus; // 'student' | 'graduate'

  String? uniSelectedUniversity;
  String? uniEmail;
  bool uniEmailVerified = false;
  String? uniFaculty;
  String? uniDepartment;
  String? uniLevel;
  String? uniStudentId;

  List<String> goals = [];
  List<String> interests = [];

  bool get isSHS => identity == UserIdentity.shs;
  bool get isUni => identity == UserIdentity.uni;

  /// Auto-generates a concise profile headline from onboarding answers.
  String get headline {
    if (isUni) {
      final levelShort = _parseLevel(uniLevel);
      final facultyShort = _shortFaculty(uniFaculty);
      final uniShort = _shortUni(uniSelectedUniversity);
      if (levelShort != null && facultyShort != null && uniShort != null) {
        return '$levelShort $facultyShort Student at $uniShort';
      }
      if (uniShort != null) return 'Student at $uniShort';
      return 'University Student';
    }
    // SHS path — pick first career-flavoured interest, else first goal
    final careerTerms = ['Engineering', 'Medicine', 'Business', 'Law', 'Teaching',
        'Technology', 'Arts & Design', 'Agriculture', 'Media & Communication',
        'Accounting', 'Entrepreneurship', 'Research'];
    final career = interests.firstWhere(
      (i) => careerTerms.any((t) => i.contains(t)),
      orElse: () => goals.isNotEmpty ? goals.first : '',
    );
    if (career.isNotEmpty) return 'Aspiring $career Student';
    return 'SHS Graduate';
  }

  static String? _parseLevel(String? raw) {
    if (raw == null) return null;
    final m = RegExp(r'Level\s+(\d+)').firstMatch(raw);
    return m != null ? 'Level ${m.group(1)}' : null;
  }

  static String? _shortFaculty(String? raw) {
    if (raw == null) return null;
    return raw
        .replaceAll('College of ', '')
        .replaceAll('Faculty of ', '')
        .replaceAll('School of ', '')
        .trim();
  }

  static String? _shortUni(String? raw) {
    if (raw == null) return null;
    // Extract acronym in parentheses e.g. "KNUST" from "... (KNUST)"
    final m = RegExp(r'\(([^)]+)\)').firstMatch(raw);
    if (m != null) return m.group(1);
    return raw.split(' ').take(2).join(' ');
  }

  Map<String, dynamic> toProfilePayload() {
    final base = <String, dynamic>{
      'user_type': isSHS ? 'shs_graduate' : 'university_student',
      'full_name': fullName ?? '',
      'email': email ?? '',
      'headline': headline,
      'goals': goals,
      'interests': interests,
      'onboarding_complete': true,
    };
    if (isSHS) {
      base.addAll({
        'school_name': shsSchoolName,
        'year_completed': shsYearCompleted,
        'status': shsStatus,
      });
    } else {
      base.addAll({
        'university': uniSelectedUniversity,
        'faculty': uniFaculty,
        'level': uniLevel,
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
    // Both paths: identity → personal details → academic → goals →
    // interests → profile photo → review. The academic/goals/interests steps
    // branch internally by path. Always 7 steps.
    return [
      buildStep(0), buildStep(1), buildStep(11),
      buildStep(4), buildStep(5), buildStep(12), buildStep(6),
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
        return StepPersonalDetails(
          data: _data,
          animCtrl: _enterCtrl,
          onChanged: () => setState(() {}),
        );
      case 4:
        return StepShsGoals(
          data: _data,
          animCtrl: _enterCtrl,
          onChanged: () => setState(() {}),
        );
      case 5:
        return StepInterests(
          data: _data,
          animCtrl: _enterCtrl,
          onChanged: () => setState(() {}),
        );
      case 6:
        return StepPreview(
          data: _data,
          animCtrl: _enterCtrl,
        );
      case 11:
        return StepAcademic(
          data: _data,
          animCtrl: _enterCtrl,
          onChanged: () => setState(() {}),
        );
      case 12:
        return StepProfilePhoto(
          data: _data,
          animCtrl: _enterCtrl,
          onChanged: () => setState(() {}),
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
      // Best-effort: join matching communities. Never blocks completion.
      await _autoJoinCommunities(user.id);
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

  /// Silently joins communities that match the user's profile.
  /// All failures are swallowed — onboarding always completes.
  Future<void> _autoJoinCommunities(String userId) async {
    try {
      final db = Supabase.instance.client;
      final candidates = <Map<String, dynamic>>[];

      if (_data.isUni) {
        // 1. University-wide community
        if (_data.uniSelectedUniversity != null) {
          final uniShort = OnboardingData._shortUni(_data.uniSelectedUniversity);
          final keyword = uniShort ?? _data.uniSelectedUniversity!.split(' ').first;
          final rows = await db
              .from('communities')
              .select('id')
              .eq('community_type', 'university')
              .eq('is_active', true)
              .ilike('name', '%$keyword%')
              .limit(1);
          candidates.addAll((rows as List).cast<Map<String, dynamic>>());
        }

        // 2. Faculty community
        if (_data.uniFaculty != null) {
          final fShort = OnboardingData._shortFaculty(_data.uniFaculty);
          if (fShort != null) {
            final rows = await db
                .from('communities')
                .select('id')
                .eq('community_type', 'faculty')
                .eq('is_active', true)
                .ilike('name', '%$fShort%')
                .limit(2);
            candidates.addAll((rows as List).cast<Map<String, dynamic>>());
          }
        }

        // 3. Level community
        if (_data.uniLevel != null) {
          final lvl = OnboardingData._parseLevel(_data.uniLevel);
          if (lvl != null) {
            final rows = await db
                .from('communities')
                .select('id')
                .eq('community_type', 'level')
                .eq('is_active', true)
                .ilike('name', '%$lvl%')
                .limit(2);
            candidates.addAll((rows as List).cast<Map<String, dynamic>>());
          }
        }
      } else {
        // SHS: look for prospective-student communities
        final rows = await db
            .from('communities')
            .select('id')
            .eq('is_active', true)
            .or("community_type.eq.prospective,name.ilike.%Prospective%,name.ilike.%SHS Graduate%")
            .limit(3);
        candidates.addAll((rows as List).cast<Map<String, dynamic>>());
      }

      // Deduplicate by id
      final seen = <String>{};
      final unique = candidates.where((c) => seen.add(c['id'] as String)).toList();

      if (unique.isEmpty) return;

      await db.from('community_members').upsert(
        unique.map((c) => {
          'community_id': c['id'],
          'user_id': userId,
          'role': 'member',
        }).toList(),
        onConflict: 'community_id,user_id',
        ignoreDuplicates: true,
      );
    } catch (e) {
      debugPrint('[Onboarding] auto-join skipped: $e');
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
        // Personal details: valid full name + email.
        return (_data.fullName?.trim().length ?? 0) >= 2 &&
            isValidOnboardingEmail(_data.email);
      case 2:
        // Academic info (path-specific).
        if (_data.isSHS) {
          return _data.shsSchoolName != null &&
              _data.shsYearCompleted != null &&
              _data.shsStatus != null;
        }
        return _data.uniSelectedUniversity != null &&
            _data.uniFaculty != null &&
            _data.uniLevel != null;
      case 3:
        return _data.goals.isNotEmpty;
      case 4:
        // SHS interests require at least three selections.
        return _data.isSHS
            ? _data.interests.length >= 3
            : _data.interests.isNotEmpty;
      case 5:
        return true; // Profile photo is optional.
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
