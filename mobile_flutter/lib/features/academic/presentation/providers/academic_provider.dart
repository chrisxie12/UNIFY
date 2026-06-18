import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/academic_models.dart';
import '../../data/repositories/academic_repository_impl.dart';

final academicRepositoryProvider = Provider<AcademicRepositoryImpl>((ref) {
  return AcademicRepositoryImpl(ref.watch(supabaseProvider));
});

// ── Student context ──────────────────────────────────────────

class AcademicContext {
  final String? universityId;
  final String? faculty;
  final String? department;
  const AcademicContext({this.universityId, this.faculty, this.department});
}

final academicContextProvider =
    FutureProvider.autoDispose<AcademicContext>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return const AcademicContext();
  try {
    final p = await client
        .from('profiles')
        .select('university_id, programme')
        .eq('id', user.id)
        .maybeSingle();
    return AcademicContext(
      universityId: p?['university_id'] as String?,
      department: p?['programme'] as String?,
    );
  } catch (_) {
    return const AcademicContext();
  }
});

// ── Courses ──────────────────────────────────────────────────

final courseSearchProvider = StateProvider.autoDispose<String>((ref) => '');

final coursesProvider =
    FutureProvider.autoDispose<List<CourseModel>>((ref) async {
  final ctx = ref.watch(academicContextProvider).valueOrNull;
  final query = ref.watch(courseSearchProvider);
  return ref.read(academicRepositoryProvider).getCourses(
        universityId: ctx?.universityId,
        query: query.isEmpty ? null : query,
      );
});

final courseDetailProvider =
    FutureProvider.autoDispose.family<CourseModel?, String>((ref, id) {
  return ref.read(academicRepositoryProvider).getCourse(id);
});

final facultiesProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final ctx = ref.watch(academicContextProvider).valueOrNull;
  return ref.read(academicRepositoryProvider).getFaculties(ctx?.universityId);
});

final departmentsProvider =
    FutureProvider.autoDispose.family<List<String>, String>((ref, faculty) {
  final ctx = ref.watch(academicContextProvider).valueOrNull;
  return ref
      .read(academicRepositoryProvider)
      .getDepartments(ctx?.universityId, faculty);
});

// ── Resources ────────────────────────────────────────────────

final resourceFilterProvider =
    StateProvider.autoDispose<ResourceFilter>((ref) => const ResourceFilter());

final resourcesProvider =
    FutureProvider.autoDispose<List<ResourceModel>>((ref) async {
  final ctx = ref.watch(academicContextProvider).valueOrNull;
  final filter = ref.watch(resourceFilterProvider);
  return ref.read(academicRepositoryProvider).getResources(
        filter: filter,
        universityId: ctx?.universityId,
      );
});

/// Resources for a specific course (course page).
final courseResourcesProvider = FutureProvider.autoDispose
    .family<List<ResourceModel>, String>((ref, courseId) {
  return ref
      .read(academicRepositoryProvider)
      .getResources(filter: ResourceFilter(courseId: courseId));
});

final resourceDetailProvider =
    FutureProvider.autoDispose.family<ResourceModel?, String>((ref, id) {
  return ref.read(academicRepositoryProvider).getResource(id);
});

final resourceRatingsProvider = FutureProvider.autoDispose
    .family<List<ResourceRating>, String>((ref, resourceId) {
  return ref.read(academicRepositoryProvider).getRatings(resourceId);
});

final offlineFlagProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, id) {
  return ref.read(academicRepositoryProvider).isOffline(id);
});

final offlineResourcesProvider =
    FutureProvider.autoDispose<List<ResourceModel>>((ref) {
  return ref.read(academicRepositoryProvider).getOfflineResources();
});

// ── Assignments ──────────────────────────────────────────────

final courseAssignmentsProvider = FutureProvider.autoDispose
    .family<List<AssignmentModel>, String>((ref, courseId) async {
  final user = ref.watch(supabaseProvider).auth.currentUser;
  return ref.read(academicRepositoryProvider).getAssignments(
        courseId: courseId,
        userId: user?.id,
      );
});

final myAssignmentsProvider =
    FutureProvider.autoDispose<List<AssignmentModel>>((ref) async {
  ref.watch(authStateProvider);
  final user = ref.watch(supabaseProvider).auth.currentUser;
  if (user == null) return [];
  return ref.read(academicRepositoryProvider).getAssignments(userId: user.id);
});

// ── Exams ────────────────────────────────────────────────────

final examsProvider =
    FutureProvider.autoDispose<List<ExamModel>>((ref) async {
  final ctx = ref.watch(academicContextProvider).valueOrNull;
  return ref
      .read(academicRepositoryProvider)
      .getExams(universityId: ctx?.universityId);
});

// ── GPA ──────────────────────────────────────────────────────

class GpaSummary {
  final double cgpa;
  final double totalCredits;
  final Map<String, double> semesterGpa; // semester → gpa
  final List<GpaEntry> entries;
  const GpaSummary({
    this.cgpa = 0,
    this.totalCredits = 0,
    this.semesterGpa = const {},
    this.entries = const [],
  });
}

final gpaProvider = FutureProvider.autoDispose<GpaSummary>((ref) async {
  ref.watch(authStateProvider);
  final user = ref.watch(supabaseProvider).auth.currentUser;
  if (user == null) return const GpaSummary();
  final entries =
      await ref.read(academicRepositoryProvider).getGpaEntries(user.id);

  double totalPoints = 0, totalCredits = 0;
  final bySem = <String, ({double pts, double cr})>{};
  for (final e in entries) {
    totalPoints += e.gradePoint * e.credits;
    totalCredits += e.credits;
    final cur = bySem[e.semester] ?? (pts: 0.0, cr: 0.0);
    bySem[e.semester] =
        (pts: cur.pts + e.gradePoint * e.credits, cr: cur.cr + e.credits);
  }
  final semGpa = <String, double>{};
  bySem.forEach((k, v) => semGpa[k] = v.cr == 0 ? 0 : v.pts / v.cr);

  return GpaSummary(
    cgpa: totalCredits == 0 ? 0 : totalPoints / totalCredits,
    totalCredits: totalCredits,
    semesterGpa: semGpa,
    entries: entries,
  );
});

// ── Study planner ────────────────────────────────────────────

final studyPlansProvider =
    FutureProvider.autoDispose<List<StudyPlan>>((ref) async {
  ref.watch(authStateProvider);
  final user = ref.watch(supabaseProvider).auth.currentUser;
  if (user == null) return [];
  return ref.read(academicRepositoryProvider).getStudyPlans(user.id);
});

// ── Admin analytics ──────────────────────────────────────────

final academicStatsProvider =
    FutureProvider.autoDispose<AcademicStats>((ref) {
  ref.watch(authStateProvider);
  return ref.read(academicRepositoryProvider).getStats();
});

// ── Offline toggle controller ────────────────────────────────

class OfflineController extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  Future<bool> toggle(ResourceModel r) async {
    final repo = ref.read(academicRepositoryProvider);
    final already = await repo.isOffline(r.id);
    if (already) {
      await repo.removeOffline(r.id);
    } else {
      await repo.saveOffline(r);
    }
    ref.invalidate(offlineResourcesProvider);
    ref.invalidate(offlineFlagProvider(r.id));
    return !already;
  }
}

final offlineControllerProvider =
    NotifierProvider.autoDispose<OfflineController, void>(
  OfflineController.new,
);
