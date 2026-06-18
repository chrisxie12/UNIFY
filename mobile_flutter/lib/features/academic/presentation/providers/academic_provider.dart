import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unify/core/providers/supabase_provider.dart';
import 'package:unify/features/academic/data/models/academic_models.dart';
import 'package:unify/features/academic/data/repositories/academic_repository_impl.dart';
import 'package:unify/features/academic/domain/repositories/academic_repository.dart';

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  return AcademicRepositoryImpl(ref.watch(supabaseProvider));
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(supabaseProvider).auth.currentUser?.id;
});

// ─── Courses ──────────────────────────────────────────────────────
final coursesProvider = FutureProvider<List<CourseModel>>((ref) async {
  final repo = ref.watch(academicRepositoryProvider);
  return repo.getCourses();
});

final courseProvider = FutureProvider.family<CourseModel?, String>((ref, courseId) async {
  final repo = ref.watch(academicRepositoryProvider);
  return repo.getCourse(courseId);
});

final coursesByDepartmentProvider = FutureProvider.family<List<CourseModel>, String>((ref, department) async {
  final repo = ref.watch(academicRepositoryProvider);
  return repo.getCourses(department: department);
});

// ─── Resources ────────────────────────────────────────────────────
final resourcesByCourseProvider = FutureProvider.family<List<AcademicResourceModel>, String>((ref, courseId) async {
  final repo = ref.watch(academicRepositoryProvider);
  return repo.getResources(courseId: courseId);
});

final resourcesByTypeProvider = FutureProvider.family<List<AcademicResourceModel>, String>((ref, type) async {
  final repo = ref.watch(academicRepositoryProvider);
  return repo.getResources(type: type);
});

final searchResourcesProvider = FutureProvider.family<List<AcademicResourceModel>, String>((ref, query) async {
  if (query.length < 2) return [];
  final repo = ref.watch(academicRepositoryProvider);
  return repo.searchResources(query);
});

final searchCoursesProvider = FutureProvider.family<List<CourseModel>, String>((ref, query) async {
  if (query.length < 2) return [];
  final repo = ref.watch(academicRepositoryProvider);
  return repo.searchCourses(query);
});

// ─── Assignments ──────────────────────────────────────────────────
final assignmentsProvider = FutureProvider.family<List<AssignmentModel>, String>((ref, courseId) async {
  final repo = ref.watch(academicRepositoryProvider);
  return repo.getAssignments(courseId);
});

// ─── GPA ──────────────────────────────────────────────────────────
final gpaRecordsProvider = FutureProvider<List<GPARecord>>((ref) async {
  final repo = ref.watch(academicRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return repo.getGPARecords(userId);
});

// ─── Study Plans ──────────────────────────────────────────────────
final studyPlansProvider = FutureProvider<List<StudyPlanModel>>((ref) async {
  final repo = ref.watch(academicRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return repo.getStudyPlans(userId);
});

// ─── Exam Timetables ──────────────────────────────────────────────
final examTimetablesProvider = FutureProvider<List<ExamTimetable>>((ref) async {
  final repo = ref.watch(academicRepositoryProvider);
  return repo.getExamTimetables();
});

// ─── Ratings ──────────────────────────────────────────────────────
final resourceRatingsProvider = FutureProvider.family<List<ResourceRating>, String>((ref, resourceId) async {
  final repo = ref.watch(academicRepositoryProvider);
  return repo.getRatings(resourceId);
});

// ─── Notifier ─────────────────────────────────────────────────────
class AcademicNotifier extends StateNotifier<AcademicState> {
  final AcademicRepository _repo;
  final String? _userId;

  AcademicNotifier(this._repo, this._userId) : super(AcademicState());

  Future<void> uploadResource(AcademicResourceModel resource) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.uploadResource(resource);
      state = state.copyWith(isLoading: false, success: 'Resource uploaded');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '$e');
    }
  }

  Future<void> saveGPA(
    String semester, String? academicYear, bool isCgpa,
    List<GPACourse> courses,
  ) async {
    if (_userId == null) return;
    final totalCredits = courses.fold<int>(0, (sum, c) => sum + c.credits);
    final totalGradePoints = courses.fold<double>(0, (sum, c) => sum + c.gradePoint * c.credits);
    final gpa = totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;

    final record = GPARecord(
      id: '',
      userId: _userId,
      semester: semester,
      academicYear: academicYear,
      gpa: double.parse(gpa.toStringAsFixed(2)),
      totalCredits: totalCredits,
      totalGradePoints: totalGradePoints,
      isCgpa: isCgpa,
      createdAt: DateTime.now(),
      courses: courses,
    );
    await _repo.saveGPARecord(record);
  }

  Future<void> createStudyPlan(String title, {DateTime? examDate}) async {
    if (_userId == null) return;
    final plan = StudyPlanModel(
      id: '',
      userId: _userId,
      title: title,
      examDate: examDate,
      createdAt: DateTime.now(),
    );
    await _repo.createStudyPlan(plan);
  }

  Future<void> rateResource(String resourceId, int rating, {String? review}) async {
    if (_userId == null) return;
    await _repo.rateResource(resourceId, _userId, rating, review: review);
  }
}

class AcademicState {
  final bool isLoading;
  final String? error;
  final String? success;

  AcademicState({this.isLoading = false, this.error, this.success});

  AcademicState copyWith({bool? isLoading, String? error, String? success}) {
    return AcademicState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success,
    );
  }
}

final academicProvider = StateNotifierProvider<AcademicNotifier, AcademicState>((ref) {
  final repo = ref.watch(academicRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return AcademicNotifier(repo, userId);
});
