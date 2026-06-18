import 'package:unify/features/academic/data/models/academic_models.dart';

abstract class AcademicRepository {
  Future<List<CourseModel>> getCourses({String? department, String? faculty, String? university, String? level});
  Future<CourseModel?> getCourse(String courseId);
  Future<CourseModel> createCourse(CourseModel course);

  Future<List<AcademicResourceModel>> getResources({
    String? courseId, String? type, String? department,
    String? verificationStatus, String? searchQuery,
  });
  Future<AcademicResourceModel> uploadResource(AcademicResourceModel resource);
  Future<void> deleteResource(String resourceId);
  Future<void> incrementDownload(String resourceId, String userId);
  Future<void> incrementView(String resourceId);

  Future<List<AssignmentModel>> getAssignments(String courseId);
  Future<AssignmentModel> createAssignment(AssignmentModel assignment);
  Future<void> submitAssignment(String assignmentId, String userId, {String? url, String? text, String? fileUrl});
  Future<void> deleteAssignment(String assignmentId);

  Future<List<GPARecord>> getGPARecords(String userId);
  Future<void> saveGPARecord(GPARecord record);
  Future<void> deleteGPARecord(String recordId);

  Future<List<StudyPlanModel>> getStudyPlans(String userId);
  Future<StudyPlanModel> createStudyPlan(StudyPlanModel plan);
  Future<void> toggleStudyItem(String itemId, bool completed);
  Future<void> deleteStudyPlan(String planId);

  Future<List<ResourceRating>> getRatings(String resourceId);
  Future<void> rateResource(String resourceId, String userId, int rating, {String? review});
  Future<double> getAverageRating(String resourceId);

  Future<List<ExamTimetable>> getExamTimetables({String? department});
  Future<void> addExamTimetable(ExamTimetable timetable);

  Future<List<AcademicResourceModel>> searchResources(String query);
  Future<List<CourseModel>> searchCourses(String query);
}
