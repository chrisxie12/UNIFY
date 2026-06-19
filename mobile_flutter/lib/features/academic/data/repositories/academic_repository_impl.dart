import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unify/features/academic/data/models/academic_models.dart';
import 'package:unify/features/academic/domain/repositories/academic_repository.dart';

class AcademicRepositoryImpl implements AcademicRepository {
  final SupabaseClient _client;
  AcademicRepositoryImpl(this._client);

  @override
  Future<List<CourseModel>> getCourses({
    String? department, String? faculty, String? university, String? level,
  }) async {
    dynamic query = _client.from('courses').select('''
      *,
      resource_count:academic_resources(count),
      assignment_count:assignments(count)
    ''');

    if (department != null) query = query.eq('department', department);
    if (faculty != null) query = query.eq('faculty', faculty);
    if (university != null) query = query.eq('university', university);
    if (level != null) query = query.eq('level', level);
    query = query.order('name', ascending: true).limit(50);

    final data = await query;
    return (data as List).map((m) => CourseModel.fromMap(m as Map<String, dynamic>)).toList();
  }

  @override
  Future<CourseModel?> getCourse(String courseId) async {
    final data = await _client.from('courses').select('''
      *,
      resource_count:academic_resources(count),
      assignment_count:assignments(count)
    ''').eq('id', courseId).maybeSingle();
    if (data == null) return null;
    return CourseModel.fromMap(data);
  }

  @override
  Future<CourseModel> createCourse(CourseModel course) async {
    final data = await _client.from('courses').insert({
      'code': course.code,
      'name': course.name,
      'description': course.description,
      'credits': course.credits,
      'university': course.university,
      'faculty': course.faculty,
      'department': course.department,
      'level': course.level,
      'semester': course.semester,
      'lecturer_name': course.lecturerName,
      'lecturer_id': course.lecturerId,
      'community_id': course.communityId,
      'created_by': course.createdBy,
    }).select().single();
    return CourseModel.fromMap(data);
  }

  @override
  Future<List<AcademicResourceModel>> getResources({
    String? courseId, String? type, String? department,
    String? verificationStatus, String? searchQuery, int limit = 50,
  }) async {
    dynamic query = _client.from('academic_resources').select('''
      *,
      rating_count:resource_ratings(count)
    ''');

    if (courseId != null) query = query.eq('course_id', courseId);
    if (type != null) query = query.eq('type', type);
    if (department != null) query = query.eq('department', department);
    if (verificationStatus != null) query = query.eq('verification_status', verificationStatus);
    if (searchQuery != null) query = query.ilike('title', '%$searchQuery%');
    query = query.order('created_at', ascending: false).limit(limit);

    final data = await query;
    final resources = (data as List).map((m) => AcademicResourceModel.fromMap(m as Map<String, dynamic>)).toList();
    await _attachAverageRatings(resources);
    return resources;
  }

  @override
  Future<AcademicResourceModel?> getResource(String resourceId) async {
    final data = await _client.from('academic_resources').select('''
      *,
      average_rating:resource_ratings(rating.avg),
      rating_count:resource_ratings(count)
    ''').eq('id', resourceId).maybeSingle();
    if (data == null) return null;
    return AcademicResourceModel.fromMap(data);
  }

  @override
  Future<AcademicResourceModel> uploadResource(AcademicResourceModel resource) async {
    final data = await _client.from('academic_resources').insert({
      'course_id': resource.courseId,
      'title': resource.title,
      'description': resource.description,
      'type': resource.type,
      'file_url': resource.fileUrl,
      'file_type': resource.fileType,
      'file_size': resource.fileSize,
      'thumbnail_url': resource.thumbnailUrl,
      'university': resource.university,
      'faculty': resource.faculty,
      'department': resource.department,
      'academic_year': resource.academicYear,
      'semester': resource.semester,
      'lecturer': resource.lecturer,
      'uploaded_by': resource.uploadedBy,
      'verification_status': resource.verificationStatus,
    }).select().single();
    return AcademicResourceModel.fromMap(data);
  }

  @override
  Future<void> deleteResource(String resourceId) async {
    await _client.from('academic_resources').delete().eq('id', resourceId);
  }

  @override
  Future<void> incrementDownload(String resourceId, String userId) async {
    await _client.rpc('increment_resource_download', params: {
      'p_resource_id': resourceId,
      'p_user_id': userId,
    });
  }

  @override
  Future<void> incrementView(String resourceId) async {
    await _client.rpc('increment_resource_view', params: {'p_resource_id': resourceId});
  }

  @override
  Future<List<AssignmentModel>> getAssignments(String courseId) async {
    final data = await _client.from('assignments').select('''
      *,
      is_submitted:assignment_submissions!inner(id)
    ''').eq('course_id', courseId).order('due_date', ascending: true).limit(50);
    return (data as List).map((m) => AssignmentModel.fromMap(m as Map<String, dynamic>)).toList();
  }

  @override
  Future<AssignmentModel> createAssignment(AssignmentModel assignment) async {
    final data = await _client.from('assignments').insert({
      'course_id': assignment.courseId,
      'title': assignment.title,
      'description': assignment.description,
      'due_date': assignment.dueDate.toIso8601String(),
      'max_score': assignment.maxScore,
      'submission_type': assignment.submissionType,
      'created_by': assignment.createdBy,
    }).select().single();
    return AssignmentModel.fromMap(data);
  }

  @override
  Future<void> submitAssignment(String assignmentId, String userId, {String? url, String? text, String? fileUrl}) async {
    await _client.from('assignment_submissions').upsert({
      'assignment_id': assignmentId,
      'user_id': userId,
      'submission_url': url,
      'submission_text': text,
      'submission_file_url': fileUrl,
    });
  }

  @override
  Future<void> deleteAssignment(String assignmentId) async {
    await _client.from('assignments').delete().eq('id', assignmentId);
  }

  @override
  Future<List<GPARecord>> getGPARecords(String userId) async {
    final data = await _client.from('gpa_records').select('''
      *,
      courses:gpa_courses(*)
    ''').eq('user_id', userId).order('created_at', ascending: false).limit(20);
    return (data as List).map((m) => GPARecord.fromMap(m as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveGPARecord(GPARecord record) async {
    final gpaData = await _client.from('gpa_records').insert({
      'user_id': record.userId,
      'semester': record.semester,
      'academic_year': record.academicYear,
      'gpa': record.gpa,
      'total_credits': record.totalCredits,
      'total_grade_points': record.totalGradePoints,
      'is_cgpa': record.isCgpa,
    }).select().single();

    final gpaId = gpaData['id'] as String;
    for (final course in record.courses) {
      await _client.from('gpa_courses').insert({
        'gpa_record_id': gpaId,
        'course_name': course.courseName,
        'course_code': course.courseCode,
        'credits': course.credits,
        'grade': course.grade,
        'grade_point': course.gradePoint,
      });
    }
  }

  @override
  Future<void> deleteGPARecord(String recordId) async {
    await _client.from('gpa_records').delete().eq('id', recordId);
  }

  @override
  Future<List<StudyPlanModel>> getStudyPlans(String userId) async {
    final data = await _client.from('study_plans').select('''
      *,
      items:study_plan_items(*)
    ''').eq('user_id', userId).order('created_at', ascending: false).limit(20);
    return (data as List).map((m) => StudyPlanModel.fromMap(m as Map<String, dynamic>)).toList();
  }

  @override
  Future<StudyPlanModel> createStudyPlan(StudyPlanModel plan) async {
    final planData = await _client.from('study_plans').insert({
      'user_id': plan.userId,
      'title': plan.title,
      'description': plan.description,
      'start_date': plan.startDate?.toIso8601String(),
      'end_date': plan.endDate?.toIso8601String(),
      'exam_date': plan.examDate?.toIso8601String(),
    }).select().single();
    return StudyPlanModel.fromMap(planData);
  }

  @override
  Future<void> toggleStudyItem(String itemId, bool completed) async {
    await _client.from('study_plan_items').update({'is_completed': completed}).eq('id', itemId);
  }

  @override
  Future<void> deleteStudyPlan(String planId) async {
    await _client.from('study_plans').delete().eq('id', planId);
  }

  // Fetches average ratings for a list of resources in one batched query.
  // PostgREST doesn't support rating.avg() in select, so we compute it here.
  Future<void> _attachAverageRatings(List<AcademicResourceModel> resources) async {
    if (resources.isEmpty) return;
    try {
      final ids = resources.map((r) => r.id).toList();
      final data = await _client
          .from('resource_ratings')
          .select('resource_id, rating')
          .inFilter('resource_id', ids);
      final rows = data as List;
      final sums = <String, int>{};
      final counts = <String, int>{};
      for (final row in rows) {
        final rid = row['resource_id'] as String;
        final rating = (row['rating'] as num).toInt();
        sums[rid] = (sums[rid] ?? 0) + rating;
        counts[rid] = (counts[rid] ?? 0) + 1;
      }
      for (final r in resources) {
        final c = counts[r.id] ?? 0;
        r.averageRating = c > 0 ? (sums[r.id]! / c) : 0.0;
      }
    } catch (e) {
      debugPrint('[AcademicRepositoryImpl] _attachAverageRatings error: $e');
    }
  }

  @override
  Future<List<ResourceRating>> getRatings(String resourceId) async {
    final data = await _client.from('resource_ratings').select('*')
        .eq('resource_id', resourceId).order('created_at', ascending: false).limit(50);
    return (data as List).map((m) => ResourceRating.fromMap(m as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> rateResource(String resourceId, String userId, int rating, {String? review}) async {
    await _client.from('resource_ratings').upsert({
      'resource_id': resourceId,
      'user_id': userId,
      'rating': rating,
      'review': review,
    });
  }

  @override
  Future<double> getAverageRating(String resourceId) async {
    final data = await _client.from('resource_ratings')
        .select('rating').eq('resource_id', resourceId); // intentionally unbounded — needs all ratings for accurate average
    final ratings = (data as List).map((m) => m['rating'] as int).toList();
    if (ratings.isEmpty) return 0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  @override
  Future<List<ExamTimetable>> getExamTimetables({String? department}) async {
    dynamic query = _client.from('exam_timetables').select('''
      *,
      course:course_id(name, code)
    ''');
    if (department != null) query = query.eq('course.department', department);
    query = query.order('exam_date', ascending: true).limit(50);
    final data = await query;
    return (data as List).map((m) {
      final map = m as Map<String, dynamic>;
      if (map['course'] != null) {
        map['course_name'] = map['course']['name'];
        map['course_code'] = map['course']['code'];
      }
      return ExamTimetable.fromMap(map);
    }).toList();
  }

  @override
  Future<void> addExamTimetable(ExamTimetable timetable) async {
    await _client.from('exam_timetables').insert({
      'course_id': timetable.courseId,
      'exam_date': timetable.examDate.toIso8601String(),
      'exam_time': timetable.examTime,
      'venue': timetable.venue,
      'duration_minutes': timetable.durationMinutes,
      'created_by': timetable.createdBy,
    });
  }

  @override
  Future<List<AcademicResourceModel>> searchResources(String query) async {
    final data = await _client.from('academic_resources').select('''
      *,
      rating_count:resource_ratings(count)
    ''').ilike('title', '%$query%').order('download_count', ascending: false).limit(20);
    final resources = (data as List).map((m) => AcademicResourceModel.fromMap(m as Map<String, dynamic>)).toList();
    await _attachAverageRatings(resources);
    return resources;
  }

  @override
  Future<List<CourseModel>> searchCourses(String query) async {
    final data = await _client.from('courses').select('''
      *,
      resource_count:academic_resources(count)
    ''').or('code.ilike.%$query%,name.ilike.%$query%').limit(20);
    return (data as List).map((m) => CourseModel.fromMap(m as Map<String, dynamic>)).toList();
  }
}
