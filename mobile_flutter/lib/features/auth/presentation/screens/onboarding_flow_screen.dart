import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/unify_snackbar.dart';

// ─── Design tokens ───────────────────────────────────────────────────────────
const _primaryBlue = Color(0xFF2563EB);
const _accentPurple = Color(0xFF7C3AED);
const _surfaceWhite = Color(0xFFFFFFFF);
const _surfaceGrey = Color(0xFFF8FAFC);
const _surfaceElevated = Color(0xFFF1F5F9);
const _textPrimary = Color(0xFF0F172A);
const _textSecondary = Color(0xFF64748B);
const _textTertiary = Color(0xFF94A3B8);
const _divider = Color(0xFFE2E8F0);
const _success = Color(0xFF10B981);
const _error = Color(0xFFEF4444);

// ─── Static data ─────────────────────────────────────────────────────────────
const _shsList = [
  'Achimota School', 'Ghana National College', 'Prempeh College',
  'Mfantsipim School', 'Wesley Girls', 'ADISCO', 'Opoku Ware', 'PRESEC',
  "St. Augustine's College", 'Legon Presbyterian',
  'Ghana Secondary Technical School', 'Other',
];

const _uniList = [
  'GCTU', 'UG', 'KNUST', 'UCC', 'UDS', 'UPSA', 'Ashesi',
  'Central University', 'Regent University', 'Valley View University',
  'University of Professional Studies', 'Other',
];

const _goalsList = [
  'Make friends', 'Explore universities', 'Learn about courses',
  'Find scholarships', 'Join communities', 'Career opportunities',
  'Get study tips', 'Find accommodation',
];

const _goalsIcons = [
  Icons.people, Icons.school, Icons.book, Icons.star,
  Icons.groups, Icons.work, Icons.lightbulb, Icons.home,
];

const _interestsList = [
  'Technology', 'AI', 'Programming', 'Business', 'Design', 'Startups',
  'Research', 'Sports', 'Music', 'Politics', 'Health', 'Education',
  'Finance', 'Agriculture', 'Law', 'Engineering', 'Cybersecurity',
  'Networking', 'Data Science', 'Robotics',
];

const _programmes = [
  'Science', 'General Arts', 'Business', 'Visual Arts',
  'Home Economics', 'Agricultural Science', 'Technical',
];

const _faculties = [
  'Engineering', 'Science', 'Business', 'Arts & Social Sciences',
  'Health Sciences', 'Law', 'Education', 'ICT',
];

const _departments = [
  'Computer Science', 'Information Technology', 'Electrical Engineering',
  'Mechanical Engineering', 'Accounting', 'Marketing', 'Economics',
  'Psychology', 'Medicine', 'Pharmacy',
];

const _uniProgrammes = [
  'BSc Computer Science', 'BSc Information Technology', 'BEng Electrical',
  'BEng Mechanical', 'BSc Accounting', 'BSc Marketing', 'BA Economics',
  'BA Psychology', 'MBChB Medicine', 'BPharm Pharmacy',
];

const _regions = [
  'Greater Accra', 'Ashanti', 'Central', 'Eastern', 'Western',
  'Northern', 'Upper East', 'Upper West', 'Volta', 'Brong-Ahafo',
  'Oti', 'Bono East', 'Ahafo', 'Savannah', 'North East', 'Western North',
];

const _enrollmentYears = ['2024', '2025', '2026', '2027'];

// ─── Onboarding state ────────────────────────────────────────────────────────
enum _UserType { none, shs, uni }

class _OnboardingData {
  // identity
  _UserType userType;

  // SHS personal
  String firstName;
  String lastName;
  String gender;
  String region;

  // SHS education
  String shsName;
  String shsProgramme;
  String graduationYear;
  String waecStatus;

  // SHS interest
  List<String> intendedUniversities;
  String intendedProgramme;
  String enrollmentYear;

  // SHS goals
  List<String> goals;

  // Uni
  String universityName;
  String emailInput;
  String otpInput;
  bool otpVerified;
  String faculty;
  String department;
  String uniProgramme;
  String level;
  String involvement;

  // Shared
  List<String> interests;

  _OnboardingData({
    this.userType = _UserType.none,
    this.firstName = '',
    this.lastName = '',
    this.gender = '',
    this.region = '',
    this.shsName = '',
    this.shsProgramme = '',
    this.graduationYear = '',
    this.waecStatus = 'Written',
    this.intendedUniversities = const [],
    this.intendedProgramme = '',
    this.enrollmentYear = '',
    this.goals = const [],
    this.universityName = '',
    this.emailInput = '',
    this.otpInput = '',
    this.otpVerified = false,
    this.faculty = '',
    this.department = '',
    this.uniProgramme = '',
    this.level = 'Level 100',
    this.involvement = '',
    this.interests = const [],
  });

  _OnboardingData copyWith({
    _UserType? userType,
    String? firstName,
    String? lastName,
    String? gender,
    String? region,
    String? shsName,
    String? shsProgramme,
    String? graduationYear,
    String? waecStatus,
    List<String>? intendedUniversities,
    String? intendedProgramme,
    String? enrollmentYear,
    List<String>? goals,
    String? universityName,
    String? emailInput,
    String? otpInput,
    bool? otpVerified,
    String? faculty,
    String? department,
    String? uniProgramme,
    String? level,
    String? involvement,
    List<String>? interests,
  }) {
    return _OnboardingData(
      userType: userType ?? this.userType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      region: region ?? this.region,
      shsName: shsName ?? this.shsName,
      shsProgramme: shsProgramme ?? this.shsProgramme,
      graduationYear: graduationYear ?? this.graduationYear,
      waecStatus: waecStatus ?? this.waecStatus,
      intendedUniversities: intendedUniversities ?? this.intendedUniversities,
      intendedProgramme: intendedProgramme ?? this.intendedProgramme,
      enrollmentYear: enrollmentYear ?? this.enrollmentYear,
      goals: goals ?? this.goals,
      universityName: universityName ?? this.universityName,
      emailInput: emailInput ?? this.emailInput,
      otpInput: otpInput ?? this.otpInput,
      otpVerified: otpVerified ?? this.otpVerified,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      uniProgramme: uniProgramme ?? this.uniProgramme,
      level: level ?? this.level,
      involvement: involvement ?? this.involvement,
      interests: interests ?? this.interests,
    );
  }
}

class _OnboardingNotifier extends StateNotifier<_OnboardingData> {
  _OnboardingNotifier() : super(_OnboardingData());

  void update(_OnboardingData Function(_OnboardingData) updater) {
    state = updater(state);
  }
}

final _onboardingProvider =
    StateNotifierProvider<_OnboardingNotifier, _OnboardingData>(
  (_) => _OnboardingNotifier(),
);

// ─── Main screen ─────────────────────────────────────────────────────────────
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen>
    with TickerProviderStateMixin {
  int _stepIndex = 0;
  bool _goingForward = true;

  // shake animation
  late final AnimationController _shakeCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  late final Animation<double> _shakeAnim = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear));

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  List<int> get _steps {
    final data = ref.read(_onboardingProvider);
    if (data.userType == _UserType.shs) {
      return [1, 2, 3, 4, 5, 6, 7];
    } else if (data.userType == _UserType.uni) {
      return [1, 8, 9, 10, 6, 7];
    }
    return [1];
  }

  int get _totalSteps => _steps.length;

  int get _currentStepId =>
      _stepIndex < _steps.length ? _steps[_stepIndex] : 1;

  void _goNext() {
    if (_stepIndex < _steps.length - 1) {
      setState(() {
        _goingForward = true;
        _stepIndex++;
      });
    }
  }

  void _goBack() {
    if (_stepIndex > 0) {
      setState(() {
        _goingForward = false;
        _stepIndex--;
      });
    } else {
      context.pop();
    }
  }

  void _shake() => _shakeCtrl.forward(from: 0);

  Future<void> _finish() async {
    final data = ref.read(_onboardingProvider);
    final isShs = data.userType == _UserType.shs;

    final displayName = isShs
        ? '${data.firstName} ${data.lastName}'.trim()
        : data.firstName.isNotEmpty
            ? '${data.firstName} ${data.lastName}'.trim()
            : 'Student';

    final school = isShs ? data.shsName : data.universityName;
    final programme = isShs ? data.intendedProgramme : data.uniProgramme;
    final yearStr = isShs ? '1' : data.level.replaceAll(RegExp(r'[^0-9]'), '');
    final year = (int.tryParse(yearStr) ?? 100) > 10
        ? ((int.tryParse(yearStr) ?? 100) ~/ 100)
        : (int.tryParse(yearStr) ?? 1);

    await ref.read(authNotifierProvider.notifier).completeOnboarding(
          displayName: displayName.isEmpty ? 'Student' : displayName,
          school: school.isEmpty ? 'Unknown' : school,
          programme: programme.isEmpty ? 'General' : programme,
          yearOfStudy: year.clamp(1, 6),
        );

    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    authState.whenOrNull(
      error: (e, _) =>
          UnifySnackbar.error(context, ErrorMapper.toUserMessage(e)),
      data: (_) => context.go('/app/feed'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceGrey,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              stepIndex: _stepIndex,
              totalSteps: _totalSteps,
              onBack: _goBack,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  final offsetAnim = Tween<Offset>(
                    begin: _goingForward
                        ? const Offset(1, 0)
                        : const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ));
                  return SlideTransition(
                    position: offsetAnim,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_stepIndex),
                  child: _buildStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    final stepId = _currentStepId;
    switch (stepId) {
      case 1:
        return _StepIdentity(onNext: _goNext, shake: _shake, shakeAnim: _shakeAnim);
      case 2: // SHS personal
        return _StepShsPersonal(onNext: _goNext, shake: _shake, shakeAnim: _shakeAnim);
      case 3: // SHS education
        return _StepShsEducation(onNext: _goNext, shake: _shake, shakeAnim: _shakeAnim);
      case 4: // SHS uni interest
        return _StepShsUniInterest(onNext: _goNext, shake: _shake, shakeAnim: _shakeAnim);
      case 5: // SHS goals
        return _StepGoals(onNext: _goNext, shake: _shake, shakeAnim: _shakeAnim);
      case 6: // Shared interests
        return _StepInterests(onNext: _goNext, shake: _shake, shakeAnim: _shakeAnim);
      case 7: // Preview
        return _StepPreview(onFinish: _finish, onEdit: () {
          setState(() {
            _goingForward = false;
            _stepIndex = 0;
          });
        });
      case 8: // Uni selection
        return _StepUniSelection(onNext: _goNext, shake: _shake, shakeAnim: _shakeAnim);
      case 9: // Email verification
        return _StepEmailVerification(onNext: _goNext, shake: _shake, shakeAnim: _shakeAnim);
      case 10: // Academic details
        return _StepAcademicDetails(onNext: _goNext, shake: _shake, shakeAnim: _shakeAnim);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Top bar ─────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final int stepIndex;
  final int totalSteps;
  final VoidCallback onBack;

  const _TopBar({
    required this.stepIndex,
    required this.totalSteps,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps > 0 ? (stepIndex + 1) / totalSteps : 0.0;
    return Container(
      color: _surfaceWhite,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: _textPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Step ${stepIndex + 1} of $totalSteps',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                    ),
                  ),
                ),
                Text(
                  '${((stepIndex + 1) / math.max(totalSteps, 1) * 100).round()}%',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: _divider,
              valueColor: const AlwaysStoppedAnimation(_primaryBlue),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────
TextStyle _bodyStyle({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = _textPrimary,
}) =>
    GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: weight, color: color);

Widget _label(String text) => Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _textSecondary,
      ),
    );

Widget _stepTitle(String title, String subtitle) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            )),
        const SizedBox(height: 6),
        Text(subtitle,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _textSecondary,
            )),
      ],
    );

Widget _continueButton({
  required bool enabled,
  required VoidCallback? onTap,
  bool loading = false,
  String label = 'Continue',
}) =>
    AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 52,
          decoration: BoxDecoration(
            color: enabled ? _primaryBlue : _primaryBlue,
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled
                ? [
                    const BoxShadow(
                        color: Color(0x3F2563EB),
                        blurRadius: 12,
                        offset: Offset(0, 4))
                  ]
                : [],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
          ),
        ),
      ),
    );

Widget _searchableDropdown({
  required String label,
  required String? value,
  required List<String> items,
  required void Function(String) onSelected,
  String hint = 'Search...',
}) =>
    _SearchableDropdown(
        label: label, value: value, items: items, onSelected: onSelected, hint: hint);

Widget _segmentedControl({
  required List<String> options,
  required String selected,
  required void Function(String) onChanged,
}) =>
    Container(
      height: 48,
      decoration: BoxDecoration(
        color: _surfaceElevated,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: options.map((o) {
          final isSelected = selected == o;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(o),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(
                    o,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : _textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

Widget _styledDropdown({
  required String label,
  required String? value,
  required List<String> items,
  required void Function(String?) onChanged,
  String hint = 'Select...',
}) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value?.isEmpty == true ? null : value,
              hint: Text(hint,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 14, color: _textTertiary)),
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              borderRadius: BorderRadius.circular(12),
              items: items
                  .map((i) => DropdownMenuItem(
                        value: i,
                        child: Text(i,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 14, color: _textPrimary)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );

Widget _inputField({
  required String label,
  required TextEditingController ctrl,
  String hint = '',
  String? error,
  TextInputType keyboardType = TextInputType.text,
}) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: GoogleFonts.spaceGrotesk(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.spaceGrotesk(fontSize: 14, color: _textTertiary),
            errorText: error,
            filled: true,
            fillColor: _surfaceWhite,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _error),
            ),
          ),
        ),
      ],
    );

// ─── Searchable dropdown widget ───────────────────────────────────────────────
class _SearchableDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final void Function(String) onSelected;
  final String hint;

  const _SearchableDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onSelected,
    this.hint = 'Search...',
  });

  @override
  State<_SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<_SearchableDropdown> {
  final _ctrl = TextEditingController();
  bool _open = false;
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    if (widget.value != null && widget.value!.isNotEmpty) {
      _ctrl.text = widget.value!;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _filter(String q) {
    setState(() {
      _filtered = widget.items
          .where((i) => i.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(widget.label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _open = !_open;
              if (_open && (widget.value == null || widget.value!.isEmpty)) {
                _ctrl.clear();
                _filtered = widget.items;
              }
            });
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: _surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _open ? _primaryBlue : _divider,
                  width: _open ? 2 : 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value?.isNotEmpty == true
                        ? widget.value!
                        : widget.hint,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: widget.value?.isNotEmpty == true
                          ? _textPrimary
                          : _textTertiary,
                    ),
                  ),
                ),
                Icon(_open ? Icons.expand_less : Icons.expand_more,
                    color: _textSecondary, size: 20),
              ],
            ),
          ),
        ),
        if (_open) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: _surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _divider),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _ctrl,
                    autofocus: true,
                    onChanged: _filter,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 14, color: _textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: GoogleFonts.spaceGrotesk(
                          fontSize: 14, color: _textTertiary),
                      prefixIcon: const Icon(Icons.search,
                          color: _textTertiary, size: 18),
                      filled: true,
                      fillColor: _surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      final isSelected = item == widget.value;
                      return GestureDetector(
                        onTap: () {
                          widget.onSelected(item);
                          setState(() => _open = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          color: isSelected
                              ? _primaryBlue.withValues(alpha: 0.06)
                              : Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(item,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      color: isSelected
                                          ? _primaryBlue
                                          : _textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    )),
                              ),
                              if (isSelected)
                                const Icon(Icons.check,
                                    color: _primaryBlue, size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Step wrapper ─────────────────────────────────────────────────────────────
class _StepWrapper extends StatelessWidget {
  final Widget child;
  final Animation<double> shakeAnim;

  const _StepWrapper({required this.child, required this.shakeAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shakeAnim,
      builder: (_, c) => Transform.translate(
        offset: Offset(shakeAnim.value, 0),
        child: c,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: child,
      ),
    );
  }
}

// ─── Step 1: Identity ────────────────────────────────────────────────────────
class _StepIdentity extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback shake;
  final Animation<double> shakeAnim;

  const _StepIdentity({
    required this.onNext,
    required this.shake,
    required this.shakeAnim,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_onboardingProvider);
    final notifier = ref.read(_onboardingProvider.notifier);

    void select(_UserType type) {
      notifier.update((d) => d.copyWith(userType: type));
    }

    return _StepWrapper(
      shakeAnim: shakeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Who are you?', 'Which best describes you?'),
          const SizedBox(height: 32),
          _IdentityCard(
            title: 'I am a Senior High School Graduate',
            subtitle: 'Completed SHS and exploring university options',
            icon: Icons.school_outlined,
            accentColor: _accentPurple,
            isSelected: data.userType == _UserType.shs,
            onTap: () => select(_UserType.shs),
          ),
          const SizedBox(height: 16),
          _IdentityCard(
            title: 'I am a University Student',
            subtitle: 'Currently enrolled at a university in Ghana',
            icon: Icons.account_balance_outlined,
            accentColor: _primaryBlue,
            isSelected: data.userType == _UserType.uni,
            onTap: () => select(_UserType.uni),
          ),
          const SizedBox(height: 40),
          _continueButton(
            enabled: data.userType != _UserType.none,
            onTap: () {
              if (data.userType == _UserType.none) {
                shake();
              } else {
                onNext();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _IdentityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.08)
              : _surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : _divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.12)
                    : _surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isSelected ? accentColor : _textSecondary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _textPrimary : _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.elasticOut,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 2A: SHS Personal Info ───────────────────────────────────────────────
class _StepShsPersonal extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback shake;
  final Animation<double> shakeAnim;

  const _StepShsPersonal({
    required this.onNext,
    required this.shake,
    required this.shakeAnim,
  });

  @override
  ConsumerState<_StepShsPersonal> createState() => _StepShsPersonalState();
}

class _StepShsPersonalState extends ConsumerState<_StepShsPersonal> {
  late final TextEditingController _firstCtrl;
  late final TextEditingController _lastCtrl;
  String? _firstErr;
  String? _lastErr;

  @override
  void initState() {
    super.initState();
    final data = ref.read(_onboardingProvider);
    _firstCtrl = TextEditingController(text: data.firstName);
    _lastCtrl = TextEditingController(text: data.lastName);
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final fe = _firstCtrl.text.trim().isEmpty ? 'Required' : null;
    final le = _lastCtrl.text.trim().isEmpty ? 'Required' : null;
    setState(() {
      _firstErr = fe;
      _lastErr = le;
    });
    return fe == null && le == null;
  }

  void _next() {
    if (!_validate()) {
      widget.shake();
      return;
    }
    final data = ref.read(_onboardingProvider);
    if (data.gender.isEmpty || data.region.isEmpty) {
      widget.shake();
      return;
    }
    ref.read(_onboardingProvider.notifier).update((d) => d.copyWith(
          firstName: _firstCtrl.text.trim(),
          lastName: _lastCtrl.text.trim(),
        ));
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(_onboardingProvider);
    final notifier = ref.read(_onboardingProvider.notifier);

    final canContinue = _firstCtrl.text.trim().isNotEmpty &&
        _lastCtrl.text.trim().isNotEmpty &&
        data.gender.isNotEmpty &&
        data.region.isNotEmpty;

    return _StepWrapper(
      shakeAnim: widget.shakeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Personal Info', 'Tell us a bit about yourself'),
          const SizedBox(height: 28),
          _inputField(
              label: 'First Name',
              ctrl: _firstCtrl,
              hint: 'Kwame',
              error: _firstErr),
          const SizedBox(height: 16),
          _inputField(
              label: 'Last Name',
              ctrl: _lastCtrl,
              hint: 'Asante',
              error: _lastErr),
          const SizedBox(height: 16),
          _styledDropdown(
            label: 'Gender',
            value: data.gender,
            items: const ['Male', 'Female', 'Prefer not to say'],
            onChanged: (v) =>
                notifier.update((d) => d.copyWith(gender: v ?? '')),
            hint: 'Select gender',
          ),
          const SizedBox(height: 16),
          _styledDropdown(
            label: 'Region',
            value: data.region,
            items: _regions,
            onChanged: (v) =>
                notifier.update((d) => d.copyWith(region: v ?? '')),
            hint: 'Select region',
          ),
          const SizedBox(height: 36),
          _continueButton(enabled: canContinue, onTap: _next),
        ],
      ),
    );
  }
}

// ─── Step 3A: SHS Education ───────────────────────────────────────────────────
class _StepShsEducation extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback shake;
  final Animation<double> shakeAnim;

  const _StepShsEducation({
    required this.onNext,
    required this.shake,
    required this.shakeAnim,
  });

  @override
  ConsumerState<_StepShsEducation> createState() => _StepShsEducationState();
}

class _StepShsEducationState extends ConsumerState<_StepShsEducation> {
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(_onboardingProvider);
    final notifier = ref.read(_onboardingProvider.notifier);

    final canContinue = data.shsName.isNotEmpty &&
        data.shsProgramme.isNotEmpty &&
        data.graduationYear.isNotEmpty;

    return _StepWrapper(
      shakeAnim: widget.shakeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Your SHS', 'Tell us about your secondary education'),
          const SizedBox(height: 28),
          _searchableDropdown(
            label: 'SHS Name',
            value: data.shsName,
            items: _shsList,
            onSelected: (v) =>
                notifier.update((d) => d.copyWith(shsName: v)),
            hint: 'Search your school...',
          ),
          const SizedBox(height: 16),
          _styledDropdown(
            label: 'Programme',
            value: data.shsProgramme,
            items: _programmes,
            onChanged: (v) =>
                notifier.update((d) => d.copyWith(shsProgramme: v ?? '')),
            hint: 'Select programme',
          ),
          const SizedBox(height: 16),
          _styledDropdown(
            label: 'Graduation Year',
            value: data.graduationYear,
            items: ['2020', '2021', '2022', '2023', '2024', '2025'],
            onChanged: (v) =>
                notifier.update((d) => d.copyWith(graduationYear: v ?? '')),
            hint: 'Select year',
          ),
          const SizedBox(height: 16),
          _label('WAEC Status'),
          const SizedBox(height: 8),
          _segmentedControl(
            options: const ['Written', 'Passed', 'Pending'],
            selected: data.waecStatus,
            onChanged: (v) =>
                notifier.update((d) => d.copyWith(waecStatus: v)),
          ),
          const SizedBox(height: 36),
          _continueButton(
            enabled: canContinue,
            onTap: canContinue ? widget.onNext : widget.shake,
          ),
        ],
      ),
    );
  }
}

// ─── Step 4A: University Interest ────────────────────────────────────────────
class _StepShsUniInterest extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback shake;
  final Animation<double> shakeAnim;

  const _StepShsUniInterest({
    required this.onNext,
    required this.shake,
    required this.shakeAnim,
  });

  @override
  ConsumerState<_StepShsUniInterest> createState() =>
      _StepShsUniInterestState();
}

class _StepShsUniInterestState extends ConsumerState<_StepShsUniInterest> {
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(_onboardingProvider);
    final notifier = ref.read(_onboardingProvider.notifier);

    void toggleUni(String uni) {
      final current = List<String>.from(data.intendedUniversities);
      if (current.contains(uni)) {
        current.remove(uni);
      } else if (current.length < 3) {
        current.add(uni);
      }
      notifier.update((d) => d.copyWith(intendedUniversities: current));
    }

    final canContinue = data.intendedUniversities.isNotEmpty &&
        data.intendedProgramme.isNotEmpty &&
        data.enrollmentYear.isNotEmpty;

    return _StepWrapper(
      shakeAnim: widget.shakeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle(
              'University Interest', 'Which universities interest you? (max 3)'),
          const SizedBox(height: 24),
          _label('Interested Universities'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _uniList.map((u) {
              final sel = data.intendedUniversities.contains(u);
              return GestureDetector(
                onTap: () => toggleUni(u),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _primaryBlue : _surfaceElevated,
                    borderRadius: BorderRadius.circular(999),
                    border: sel
                        ? null
                        : Border.all(color: _divider),
                  ),
                  child: Text(u,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : _textSecondary,
                      )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _styledDropdown(
            label: 'Intended Programme',
            value: data.intendedProgramme,
            items: _uniProgrammes,
            onChanged: (v) =>
                notifier.update((d) => d.copyWith(intendedProgramme: v ?? '')),
            hint: 'Select programme',
          ),
          const SizedBox(height: 16),
          _styledDropdown(
            label: 'Expected Enrollment Year',
            value: data.enrollmentYear,
            items: _enrollmentYears,
            onChanged: (v) =>
                notifier.update((d) => d.copyWith(enrollmentYear: v ?? '')),
            hint: 'Select year',
          ),
          const SizedBox(height: 36),
          _continueButton(
            enabled: canContinue,
            onTap: canContinue ? widget.onNext : widget.shake,
          ),
        ],
      ),
    );
  }
}

// ─── Step 5A: Goals ───────────────────────────────────────────────────────────
class _StepGoals extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback shake;
  final Animation<double> shakeAnim;

  const _StepGoals({
    required this.onNext,
    required this.shake,
    required this.shakeAnim,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_onboardingProvider);
    final notifier = ref.read(_onboardingProvider.notifier);

    void toggle(String goal) {
      final current = List<String>.from(data.goals);
      if (current.contains(goal)) {
        current.remove(goal);
      } else {
        current.add(goal);
      }
      notifier.update((d) => d.copyWith(goals: current));
    }

    final canContinue = data.goals.length >= 3;

    return _StepWrapper(
      shakeAnim: shakeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Your Goals', 'What do you hope to achieve? (min 3)'),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: _goalsList.length,
            itemBuilder: (_, i) {
              final goal = _goalsList[i];
              final icon = _goalsIcons[i];
              final sel = data.goals.contains(goal);
              return GestureDetector(
                onTap: () => toggle(goal),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: sel
                        ? _primaryBlue.withValues(alpha: 0.08)
                        : _surfaceWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel ? _primaryBlue : _divider,
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(icon,
                          color: sel ? _primaryBlue : _textSecondary,
                          size: 22),
                      Text(goal,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight:
                                sel ? FontWeight.w700 : FontWeight.w500,
                            color:
                                sel ? _textPrimary : _textSecondary,
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${data.goals.length} selected (min 3)',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: canContinue ? _success : _textTertiary),
          ),
          const SizedBox(height: 28),
          _continueButton(
            enabled: canContinue,
            onTap: canContinue ? onNext : shake,
          ),
        ],
      ),
    );
  }
}

// ─── Step 2B: University Selection ───────────────────────────────────────────
class _StepUniSelection extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback shake;
  final Animation<double> shakeAnim;

  const _StepUniSelection({
    required this.onNext,
    required this.shake,
    required this.shakeAnim,
  });

  @override
  ConsumerState<_StepUniSelection> createState() => _StepUniSelectionState();
}

class _StepUniSelectionState extends ConsumerState<_StepUniSelection> {
  final _searchCtrl = TextEditingController();
  List<String> _filtered = _uniList;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter(String q) {
    setState(() {
      _filtered = _uniList
          .where((u) => u.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(_onboardingProvider);
    final notifier = ref.read(_onboardingProvider.notifier);

    return _StepWrapper(
      shakeAnim: widget.shakeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Your University', 'Search and select your university'),
          const SizedBox(height: 24),
          TextField(
            controller: _searchCtrl,
            onChanged: _filter,
            style: GoogleFonts.spaceGrotesk(fontSize: 14, color: _textPrimary),
            decoration: InputDecoration(
              hintText: 'Search university...',
              hintStyle: GoogleFonts.spaceGrotesk(
                  fontSize: 14, color: _textTertiary),
              prefixIcon: const Icon(Icons.search, color: _textTertiary),
              filled: true,
              fillColor: _surfaceWhite,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: _primaryBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._filtered.map((uni) {
            final sel = data.universityName == uni;
            return GestureDetector(
              onTap: () =>
                  notifier.update((d) => d.copyWith(universityName: uni)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: sel
                      ? _primaryBlue.withValues(alpha: 0.06)
                      : _surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: sel ? _primaryBlue : _divider,
                      width: sel ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(uni,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: sel
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color:
                                sel ? _primaryBlue : _textPrimary,
                          )),
                    ),
                    AnimatedScale(
                      scale: sel ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.elasticOut,
                      child: const Icon(Icons.check_circle,
                          color: _primaryBlue, size: 20),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 28),
          _continueButton(
            enabled: data.universityName.isNotEmpty,
            onTap: data.universityName.isNotEmpty
                ? widget.onNext
                : widget.shake,
          ),
        ],
      ),
    );
  }
}

// ─── Step 3B: Email Verification ─────────────────────────────────────────────
class _StepEmailVerification extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback shake;
  final Animation<double> shakeAnim;

  const _StepEmailVerification({
    required this.onNext,
    required this.shake,
    required this.shakeAnim,
  });

  @override
  ConsumerState<_StepEmailVerification> createState() =>
      _StepEmailVerificationState();
}

class _StepEmailVerificationState
    extends ConsumerState<_StepEmailVerification> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;
  String? _emailErr;

  @override
  void initState() {
    super.initState();
    final data = ref.read(_onboardingProvider);
    _emailCtrl.text = data.emailInput;
    _otpCtrl.text = data.otpInput;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _emailErr = 'Enter a valid email');
      widget.shake();
      return;
    }
    setState(() {
      _emailErr = null;
      _otpSent = true;
    });
    ref
        .read(_onboardingProvider.notifier)
        .update((d) => d.copyWith(emailInput: email));
  }

  void _verify() {
    final otp = _otpCtrl.text.trim();
    // Mock OTP: accept "1234" or any 4-digit code
    if (otp.length == 4) {
      ref.read(_onboardingProvider.notifier).update(
            (d) => d.copyWith(otpInput: otp, otpVerified: true),
          );
      widget.onNext();
    } else {
      widget.shake();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(_onboardingProvider);

    return _StepWrapper(
      shakeAnim: widget.shakeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Verify Your Email',
              'Use your university email to verify your status'),
          const SizedBox(height: 28),
          _inputField(
            label: 'University Email',
            ctrl: _emailCtrl,
            hint: 'you@university.edu.gh',
            error: _emailErr,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          if (!_otpSent)
            _continueButton(
              label: 'Send OTP',
              enabled: true,
              onTap: _sendOtp,
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: _success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('OTP sent to ${_emailCtrl.text}',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 13, color: _success)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _inputField(
              label: 'Enter OTP',
              ctrl: _otpCtrl,
              hint: '4-digit code',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text('Hint: any 4-digit code works in this demo',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12, color: _textTertiary)),
            const SizedBox(height: 24),
            _continueButton(
              label: 'Verify & Continue',
              enabled: _otpCtrl.text.length >= 4,
              onTap: _verify,
            ),
          ],
          if (!_otpSent && data.otpVerified) ...[
            const SizedBox(height: 12),
            Text('Already verified', style: _bodyStyle(color: _success)),
          ],
        ],
      ),
    );
  }
}

// ─── Step 4B: Academic Details ────────────────────────────────────────────────
class _StepAcademicDetails extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback shake;
  final Animation<double> shakeAnim;

  const _StepAcademicDetails({
    required this.onNext,
    required this.shake,
    required this.shakeAnim,
  });

  @override
  ConsumerState<_StepAcademicDetails> createState() =>
      _StepAcademicDetailsState();
}

class _StepAcademicDetailsState
    extends ConsumerState<_StepAcademicDetails> {
  final _involvementCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _involvementCtrl.text = ref.read(_onboardingProvider).involvement;
  }

  @override
  void dispose() {
    _involvementCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(_onboardingProvider);
    final notifier = ref.read(_onboardingProvider.notifier);

    final canContinue = data.faculty.isNotEmpty &&
        data.department.isNotEmpty &&
        data.uniProgramme.isNotEmpty;

    return _StepWrapper(
      shakeAnim: widget.shakeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Academic Details', 'Tell us about your studies'),
          const SizedBox(height: 28),
          _styledDropdown(
            label: 'Faculty',
            value: data.faculty,
            items: _faculties,
            onChanged: (v) =>
                notifier.update((d) => d.copyWith(faculty: v ?? '')),
            hint: 'Select faculty',
          ),
          const SizedBox(height: 16),
          _styledDropdown(
            label: 'Department',
            value: data.department,
            items: _departments,
            onChanged: (v) =>
                notifier.update((d) => d.copyWith(department: v ?? '')),
            hint: 'Select department',
          ),
          const SizedBox(height: 16),
          _styledDropdown(
            label: 'Programme',
            value: data.uniProgramme,
            items: _uniProgrammes,
            onChanged: (v) =>
                notifier.update((d) => d.copyWith(uniProgramme: v ?? '')),
            hint: 'Select programme',
          ),
          const SizedBox(height: 16),
          _label('Current Level'),
          const SizedBox(height: 8),
          _segmentedControl(
            options: const ['Level 100', 'Level 200', 'Level 300', 'Level 400'],
            selected: data.level,
            onChanged: (v) => notifier.update((d) => d.copyWith(level: v)),
          ),
          const SizedBox(height: 16),
          _inputField(
            label: 'Campus Involvement (Optional)',
            ctrl: _involvementCtrl,
            hint: 'e.g., NUGS, Student Council, Debate Club...',
          ),
          const SizedBox(height: 36),
          _continueButton(
            enabled: canContinue,
            onTap: canContinue
                ? () {
                    notifier.update((d) =>
                        d.copyWith(involvement: _involvementCtrl.text.trim()));
                    widget.onNext();
                  }
                : widget.shake,
          ),
        ],
      ),
    );
  }
}

// ─── Step 6: Interests (shared) ───────────────────────────────────────────────
class _StepInterests extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback shake;
  final Animation<double> shakeAnim;

  const _StepInterests({
    required this.onNext,
    required this.shake,
    required this.shakeAnim,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_onboardingProvider);
    final notifier = ref.read(_onboardingProvider.notifier);

    void toggle(String interest) {
      final current = List<String>.from(data.interests);
      if (current.contains(interest)) {
        current.remove(interest);
      } else if (current.length < 10) {
        current.add(interest);
      }
      notifier.update((d) => d.copyWith(interests: current));
    }

    final canContinue = data.interests.length >= 3;

    return _StepWrapper(
      shakeAnim: shakeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Your Interests', 'Select at least 3 (max 10)'),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interestsList.map((interest) {
              final sel = data.interests.contains(interest);
              return GestureDetector(
                onTap: () => toggle(interest),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _primaryBlue : _surfaceElevated,
                    borderRadius: BorderRadius.circular(999),
                    border: sel
                        ? null
                        : Border.all(color: _divider),
                  ),
                  child: Text(
                    interest,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : _textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            '${data.interests.length}/10 selected (min 3)',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: canContinue ? _success : _textTertiary),
          ),
          const SizedBox(height: 32),
          _continueButton(
            enabled: canContinue,
            onTap: canContinue ? onNext : shake,
          ),
        ],
      ),
    );
  }
}

// ─── Step 7: Preview ──────────────────────────────────────────────────────────
class _StepPreview extends ConsumerWidget {
  final Future<void> Function() onFinish;
  final VoidCallback onEdit;

  const _StepPreview({required this.onFinish, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_onboardingProvider);
    final loading = ref.watch(authNotifierProvider).isLoading;
    final isShs = data.userType == _UserType.shs;

    final name = isShs
        ? '${data.firstName} ${data.lastName}'.trim()
        : data.universityName.isNotEmpty
            ? data.universityName
            : 'Student';
    final displayName =
        isShs ? '${data.firstName} ${data.lastName}'.trim() : '';
    final school = isShs ? data.shsName : data.universityName;
    final programme = isShs ? data.intendedProgramme : data.uniProgramme;
    final type = isShs ? 'SHS Graduate' : 'University Student';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Looking Good!', 'Review your profile before finishing'),
          const SizedBox(height: 24),
          // Profile card
          Container(
            decoration: BoxDecoration(
              color: _surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _divider),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 16,
                    offset: Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryBlue, _accentPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName.isNotEmpty ? displayName : name,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              type,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Details
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (school.isNotEmpty)
                        _previewRow(
                            Icons.school_outlined, 'School / University',
                            school),
                      if (programme.isNotEmpty)
                        _previewRow(
                            Icons.book_outlined, 'Programme', programme),
                      if (isShs && data.region.isNotEmpty)
                        _previewRow(
                            Icons.location_on_outlined, 'Region', data.region),
                      if (!isShs && data.level.isNotEmpty)
                        _previewRow(Icons.bar_chart_outlined, 'Level',
                            data.level),
                      if (data.interests.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.interests_outlined,
                                size: 18, color: _textSecondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Interests',
                                      style: GoogleFonts.spaceGrotesk(
                                          fontSize: 12,
                                          color: _textTertiary)),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: data.interests
                                        .take(5)
                                        .map((i) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _primaryBlue
                                                    .withValues(alpha: 0.08),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(i,
                                                  style: GoogleFonts.spaceGrotesk(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: _primaryBlue,
                                                  )),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Edit button
          GestureDetector(
            onTap: onEdit,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _surfaceWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_outlined,
                      color: _textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Text('Edit Profile',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _continueButton(
            label: 'Looks Good — Finish',
            enabled: !loading,
            loading: loading,
            onTap: loading ? null : onFinish,
          ),
        ],
      ),
    );
  }

  Widget _previewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 12, color: _textTertiary)),
                Text(value,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
