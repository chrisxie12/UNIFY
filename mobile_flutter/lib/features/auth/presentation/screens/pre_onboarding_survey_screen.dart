import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/survey_state_provider.dart';

// ---------------------------------------------------------------------------
// PreOnboardingSurveyScreen — dynamic state-machine-driven survey that
// branches based on user classification (SHS Graduate vs University Student).
// ---------------------------------------------------------------------------

class PreOnboardingSurveyScreen extends ConsumerStatefulWidget {
  const PreOnboardingSurveyScreen({super.key});

  @override
  ConsumerState<PreOnboardingSurveyScreen> createState() =>
      _PreOnboardingSurveyScreenState();
}

class _PreOnboardingSurveyScreenState
    extends ConsumerState<PreOnboardingSurveyScreen> {
  int _step = 0;
  int? _selected;
  bool _submitting = false;

  String? _userTypeChoice;
  String? _step2Choice;
  String? _step3Choice;

  @override
  void dispose() {
    super.dispose();
  }

  void _select(int index) {
    setState(() => _selected = index);
  }

  void _next() {
    if (_selected == null) return;

    if (_step == 0) {
      _userTypeChoice = _selected == 0 ? 'shs' : 'uni';
      final userType = _selected == 0
          ? UserType.shsGraduate
          : UserType.universityStudent;
      ref.read(surveyStateProvider.notifier).setUserType(userType);

      setState(() {
        _step = 1;
        _selected = null;
      });
    } else if (_step == 1) {
      _step2Choice = _selected == 0
          ? _shsStep2[_selected!]
          : _uniStep2[_selected!];

      if (_userTypeChoice == 'shs') {
        ref.read(surveyStateProvider.notifier).setGoal(_step2Choice!);
      } else {
        ref.read(surveyStateProvider.notifier).setInstitution(_step2Choice!);
      }

      setState(() {
        _step = 2;
        _selected = null;
      });
    } else if (_step == 2) {
      _step3Choice = _selected == 0
          ? _shsStep3[_selected!]
          : _uniStep3[_selected!];

      if (_userTypeChoice == 'shs') {
        ref.read(surveyStateProvider.notifier).setIntendedMajor(_step3Choice!);
      } else {
        ref.read(surveyStateProvider.notifier).setProgram(_step3Choice!);
      }

      _submit();
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    // Small delay so the UI shows the selection briefly
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    context.go('/unify-auth');
  }

  // ── Step questions & choices ──────────────────────────────────────

  static const _questions = <String>[
    'Which best describes\nyour current status?',
    '', // dynamically set
    '', // dynamically set
  ];

  static const _shsStep2 = <String>[
    'Explore University Admissions',
    'Join Prep Communities',
    'Find Student Freelancers',
  ];

  static const _uniStep2 = <String>[
    'Ghana Communication Technology University (GCTU)',
    'Kwame Nkrumah University of Science and Technology (KNUST)',
    'University of Ghana (UG)',
  ];

  static const _shsStep3 = <String>[
    'Computer Programming',
    'Civil Engineering',
    'Business Administration',
    'General Science',
  ];

  static const _uniStep3 = <String>[
    'Computer Programming',
    'Telecommunications Engineering',
    'Computer Science',
  ];

  String get _question {
    if (_step == 0) return _questions[0];
    if (_step == 1) {
      return _userTypeChoice == 'shs'
          ? 'What is your primary\ngoal on UNIFY?'
          : 'Which institution do\nyou currently attend?';
    }
    return _userTypeChoice == 'shs'
        ? 'What field of study or major\nare you intending to pursue?'
        : 'What is your primary\nacademic program?';
  }

  List<String> get _choices {
    if (_step == 0) {
      return [
        'I am a Senior High School (SHS) Graduate',
        'I am a University Student',
      ];
    }
    if (_step == 1) {
      return _userTypeChoice == 'shs' ? _shsStep2 : _uniStep2;
    }
    return _userTypeChoice == 'shs' ? _shsStep3 : _uniStep3;
  }

  int get _totalSteps => 3;

  @override
  Widget build(BuildContext context) {
    final isLast = _step == _totalSteps - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
          onPressed: _step > 0
              ? () => setState(() {
                    _step--;
                    _selected = null;
                  })
              : () => context.go('/onboarding-carousel'),
        ),
        title: Text(
          'Step ${_step + 1} of $_totalSteps',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 28),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _question,
                    key: ValueKey('q$_step'),
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                      height: 1.3,
                    ),
                  ),
                ),
              ),

              // Choices
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey('c$_step'),
                  children: List.generate(_choices.length, (i) {
                    final selected = _selected == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _select(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF3730A3).withValues(alpha: 0.06)
                                : const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF3730A3)
                                  : const Color(0xFFF3F4F6),
                              width: selected ? 2 : 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _choices[i],
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1F2937),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              if (selected)
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF3730A3),
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const Spacer(),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _selected != null && !_submitting ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3730A3),
                    foregroundColor: const Color(0xFFFFFFFF),
                    disabledBackgroundColor:
                        const Color(0xFFF3F4F6),
                    disabledForegroundColor:
                        const Color(0xFFD1D5DB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                    textStyle: GoogleFonts.inter(
                      fontSize: 15,
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
                      : Text(isLast ? 'Complete' : 'Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
