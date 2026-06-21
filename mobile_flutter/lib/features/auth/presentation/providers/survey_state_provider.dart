import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserType { shsGraduate, universityStudent }

class SurveyState {
  final UserType? userType;
  final String? goal;
  final String? intendedMajor;
  final String? institution;
  final String? program;

  const SurveyState({
    this.userType,
    this.goal,
    this.intendedMajor,
    this.institution,
    this.program,
  });

  Map<String, dynamic> get preProfilePayload {
    if (userType == null) return {};
    switch (userType!) {
      case UserType.shsGraduate:
        return {
          'user_type': 'shs_graduate',
          'goal': goal,
          'intended_major': intendedMajor,
          'onboarding_complete': false,
        };
      case UserType.universityStudent:
        return {
          'user_type': 'university_student',
          'institution': institution,
          'program': program,
          'onboarding_complete': false,
        };
    }
  }

  bool get isComplete =>
      userType != null &&
      ((userType == UserType.shsGraduate &&
              goal != null &&
              intendedMajor != null) ||
          (userType == UserType.universityStudent &&
              institution != null &&
              program != null));

  SurveyState copyWith({
    UserType? userType,
    String? goal,
    String? intendedMajor,
    String? institution,
    String? program,
    bool clearGoal = false,
    bool clearIntendedMajor = false,
    bool clearInstitution = false,
    bool clearProgram = false,
  }) {
    return SurveyState(
      userType: userType ?? this.userType,
      goal: clearGoal ? null : (goal ?? this.goal),
      intendedMajor:
          clearIntendedMajor ? null : (intendedMajor ?? this.intendedMajor),
      institution:
          clearInstitution ? null : (institution ?? this.institution),
      program: clearProgram ? null : (program ?? this.program),
    );
  }
}

class SurveyStateNotifier extends StateNotifier<SurveyState> {
  SurveyStateNotifier() : super(const SurveyState());

  void setUserType(UserType type) => state = state.copyWith(userType: type);
  void setGoal(String goal) => state = state.copyWith(goal: goal);
  void setIntendedMajor(String major) =>
      state = state.copyWith(intendedMajor: major);
  void setInstitution(String institution) =>
      state = state.copyWith(institution: institution);
  void setProgram(String program) =>
      state = state.copyWith(program: program);
  void reset() => state = const SurveyState();
}

final surveyStateProvider =
    StateNotifierProvider<SurveyStateNotifier, SurveyState>(
  (_) => SurveyStateNotifier(),
);
