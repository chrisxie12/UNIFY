import 'dart:convert';
import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/academic_models.dart';

class AcademicRepositoryImpl {
  final SupabaseClient _client;
  AcademicRepositoryImpl(this._client);

  static const _box = AppConstants.academicBox;
  static const _offlineBox = AppConstants.offlineResourcesBox;
  static const _uploaderJoin =
      'profiles!academic_resources_uploader_id_fkey(full_name)';

  // ── Courses ──────────────────────────────────────────────────

  Future<List<CourseModel>> getCourses({
    String? universityId,
    String? faculty,
    String? department,
    String? query,
    int limit = 60,
  }) async {
    try {
      var q = _client.from('courses').select('*');
      if (universityId != null) q = q.eq('university_id', universityId);
      if (faculty != null && faculty.isNotEmpty) q = q.eq('faculty', faculty);
      if (department != null && department.isNotEmpty) {
        q = q.eq('department', department);
      }
      if (query != null && query.trim().isNotEmpty) {
        final t = query.trim();
        q = q.or('code.ilike.%$t%,title.ilike.%$t%,lecturer.ilike.%$t%');
      }
      final data = await q.order('code', ascending: true).limit(limit);
      final items = (data as List)
          .map((r) => CourseModel.fromJson(r as Map<String, dynamic>))
          .toList();
      if (faculty == null && department == null && (query == null || query.isEmpty)) {
        await _cacheList('courses', items.map((c) => c.toCache()).toList());
      }
      return items;
    } catch (_) {
      final cached = await _readCache('courses');
      if (cached != null) {
        return cached.map((e) => CourseModel.fromJson(e)).toList();
      }
      rethrow;
    }
  }

  Future<CourseModel?> getCourse(String id) async {
    final data =
        await _client.from('courses').select('*').eq('id', id).maybeSingle();
    return data == null ? null : CourseModel.fromJson(data);
  }

  Future<void> recordCourseView(String id) async {
    try {
      await _client.rpc('increment_course_view', params: {'p_id': id});
    } catch (_) {}
  }

  Future<String> createCourse(Map<String, dynamic> payload) async {
    final row =
        await _client.from('courses').insert(payload).select('id').single();
    return row['id'] as String;
  }

  /// Distinct faculties for a university (drives the hierarchy browser).
  Future<List<String>> getFaculties(String? universityId) async {
    var q = _client.from('courses').select('faculty');
    if (universityId != null) q = q.eq('university_id', universityId);
    final data = await q;
    final set = <String>{};
    for (final r in (data as List)) {
      final f = r['faculty'] as String?;
      if (f != null && f.isNotEmpty) set.add(f);
    }
    final list = set.toList()..sort();
    return list;
  }

  Future<List<String>> getDepartments(
      String? universityId, String faculty) async {
    var q = _client.from('courses').select('department').eq('faculty', faculty);
    if (universityId != null) q = q.eq('university_id', universityId);
    final data = await q;
    final set = <String>{};
    for (final r in (data as List)) {
      final d = r['department'] as String?;
      if (d != null && d.isNotEmpty) set.add(d);
    }
    final list = set.toList()..sort();
    return list;
  }

  // ── Resources ────────────────────────────────────────────────

  Future<List<ResourceModel>> getResources({
    required ResourceFilter filter,
    String? universityId,
    int limit = 60,
  }) async {
    final isDefault = filter.courseId == null &&
        filter.type == null &&
        (filter.query == null || filter.query!.isEmpty) &&
        filter.faculty == null &&
        filter.department == null &&
        !filter.verifiedOnly;
    try {
      var q = _client
          .from('academic_resources')
          .select('*, $_uploaderJoin')
          .eq('is_approved', true);
      if (universityId != null) q = q.eq('university_id', universityId);
      if (filter.courseId != null) q = q.eq('course_id', filter.courseId!);
      if (filter.type != null) q = q.eq('resource_type', filter.type!.key);
      if (filter.faculty != null && filter.faculty!.isNotEmpty) {
        q = q.eq('faculty', filter.faculty!);
      }
      if (filter.department != null && filter.department!.isNotEmpty) {
        q = q.eq('department', filter.department!);
      }
      if (filter.verifiedOnly) q = q.neq('verification', 'student');
      if (filter.query != null && filter.query!.trim().isNotEmpty) {
        final t = filter.query!.trim();
        q = q.or('title.ilike.%$t%,description.ilike.%$t%,lecturer.ilike.%$t%');
      }

      final data = await switch (filter.sort) {
        'rating' => q.order('rating', ascending: false).limit(limit),
        'downloads' =>
          q.order('download_count', ascending: false).limit(limit),
        _ => q.order('created_at', ascending: false).limit(limit),
      };

      final items = (data as List)
          .map((r) => ResourceModel.fromJson(r as Map<String, dynamic>))
          .toList();
      if (isDefault) {
        await _cacheList('resources', items.map((r) => r.toCache()).toList());
      }
      return items;
    } catch (_) {
      if (isDefault) {
        final cached = await _readCache('resources');
        if (cached != null) {
          return cached.map((e) => ResourceModel.fromJson(e)).toList();
        }
      }
      rethrow;
    }
  }

  Future<ResourceModel?> getResource(String id) async {
    final data = await _client
        .from('academic_resources')
        .select('*, $_uploaderJoin')
        .eq('id', id)
        .maybeSingle();
    return data == null ? null : ResourceModel.fromJson(data);
  }

  Future<void> recordResourceView(String id) async {
    try {
      await _client.rpc('increment_resource_view', params: {'p_id': id});
    } catch (_) {}
  }

  Future<String> uploadFile(String userId, Uint8List bytes, String ext) async {
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('academic').uploadBinary(path, bytes,
        fileOptions: const FileOptions(upsert: true));
    return _client.storage.from('academic').getPublicUrl(path);
  }

  Future<String> createResource(Map<String, dynamic> payload) async {
    final row = await _client
        .from('academic_resources')
        .insert(payload)
        .select('id')
        .single();
    return row['id'] as String;
  }

  Future<void> deleteResource(String id) async {
    await _client.from('academic_resources').delete().eq('id', id);
  }

  /// Course rep / faculty admin elevates a resource's verification level.
  Future<void> setVerification(
      String resourceId, ResourceVerification level) async {
    await _client
        .from('academic_resources')
        .update({'verification': level.key}).eq('id', resourceId);
  }

  // ── Ratings ──────────────────────────────────────────────────

  Future<List<ResourceRating>> getRatings(String resourceId) async {
    final data = await _client
        .from('resource_ratings')
        .select('*, profiles!resource_ratings_user_id_fkey(full_name)')
        .eq('resource_id', resourceId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((r) => ResourceRating.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<int?> myRating(String resourceId, String userId) async {
    final r = await _client
        .from('resource_ratings')
        .select('rating')
        .eq('resource_id', resourceId)
        .eq('user_id', userId)
        .maybeSingle();
    return r?['rating'] as int?;
  }

  Future<void> rateResource({
    required String resourceId,
    required String userId,
    required int rating,
    String? comment,
  }) async {
    await _client.from('resource_ratings').upsert({
      'resource_id': resourceId,
      'user_id': userId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    }, onConflict: 'resource_id,user_id');
  }

  // ── Downloads + offline ──────────────────────────────────────

  Future<void> recordDownload(String resourceId, String? userId) async {
    try {
      await _client.from('resource_downloads').insert({
        'resource_id': resourceId,
        if (userId != null) 'user_id': userId,
      });
    } catch (_) {}
  }

  /// Save a resource for offline access (metadata cached in Hive; image
  /// binaries are cached by cached_network_image automatically).
  Future<void> saveOffline(ResourceModel r) async {
    final box = await Hive.openBox(_offlineBox);
    await box.put(r.id, jsonEncode(r.toCache()));
  }

  Future<void> removeOffline(String id) async {
    final box = await Hive.openBox(_offlineBox);
    await box.delete(id);
  }

  Future<bool> isOffline(String id) async {
    final box = await Hive.openBox(_offlineBox);
    return box.containsKey(id);
  }

  Future<List<ResourceModel>> getOfflineResources() async {
    final box = await Hive.openBox(_offlineBox);
    final out = <ResourceModel>[];
    for (final v in box.values) {
      try {
        out.add(ResourceModel.fromJson(
            jsonDecode(v as String) as Map<String, dynamic>));
      } catch (_) {}
    }
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }

  // ── Assignments ──────────────────────────────────────────────

  Future<List<AssignmentModel>> getAssignments({
    String? courseId,
    String? userId,
    int limit = 40,
  }) async {
    var q = _client.from('assignments').select('*');
    if (courseId != null) q = q.eq('course_id', courseId);
    final data = await q.order('due_at', ascending: true, nullsFirst: false).limit(limit);

    Map<String, String> statuses = {};
    if (userId != null) {
      final subs = await _client
          .from('assignment_submissions')
          .select('assignment_id, status')
          .eq('user_id', userId);
      statuses = {
        for (final s in (subs as List))
          s['assignment_id'] as String: s['status'] as String,
      };
    }
    return (data as List)
        .map((r) => AssignmentModel.fromJson(r as Map<String, dynamic>,
            status: statuses[(r as Map)['id']]))
        .toList();
  }

  Future<String> createAssignment(Map<String, dynamic> payload) async {
    final row = await _client
        .from('assignments')
        .insert(payload)
        .select('id')
        .single();
    return row['id'] as String;
  }

  Future<void> submitAssignment({
    required String assignmentId,
    required String userId,
    String? linkUrl,
    String status = 'submitted',
  }) async {
    await _client.from('assignment_submissions').upsert({
      'assignment_id': assignmentId,
      'user_id': userId,
      if (linkUrl != null) 'link_url': linkUrl,
      'status': status,
    }, onConflict: 'assignment_id,user_id');
  }

  Future<void> setAssignmentReminder({
    required String assignmentId,
    required String userId,
    required DateTime remindAt,
  }) async {
    await _client.from('assignment_reminders').upsert({
      'assignment_id': assignmentId,
      'user_id': userId,
      'remind_at': remindAt.toIso8601String(),
    }, onConflict: 'assignment_id,user_id,remind_at');
  }

  // ── Exams ────────────────────────────────────────────────────

  Future<List<ExamModel>> getExams({
    String? universityId,
    String? courseId,
    int limit = 60,
  }) async {
    var q = _client.from('exam_schedule').select('*');
    if (courseId != null) q = q.eq('course_id', courseId);
    if (universityId != null) q = q.eq('university_id', universityId);
    final data =
        await q.order('exam_date', ascending: true, nullsFirst: false).limit(limit);
    return (data as List)
        .map((r) => ExamModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> createExam(Map<String, dynamic> payload) async {
    await _client.from('exam_schedule').insert(payload);
  }

  // ── GPA ──────────────────────────────────────────────────────

  Future<List<GpaEntry>> getGpaEntries(String userId) async {
    final data = await _client
        .from('gpa_entries')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: true);
    return (data as List)
        .map((r) => GpaEntry.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> addGpaEntry(Map<String, dynamic> payload) async {
    await _client.from('gpa_entries').insert(payload);
  }

  Future<void> deleteGpaEntry(String id) async {
    await _client.from('gpa_entries').delete().eq('id', id);
  }

  // ── Study planner ────────────────────────────────────────────

  Future<List<StudyPlan>> getStudyPlans(String userId) async {
    final data = await _client
        .from('study_plans')
        .select('*, study_tasks(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((r) => StudyPlan.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<String> createStudyPlan(Map<String, dynamic> payload) async {
    final row = await _client
        .from('study_plans')
        .insert(payload)
        .select('id')
        .single();
    return row['id'] as String;
  }

  Future<void> deleteStudyPlan(String id) async {
    await _client.from('study_plans').delete().eq('id', id);
  }

  Future<void> addTask(String planId, String title, {DateTime? dueAt}) async {
    await _client.from('study_tasks').insert({
      'plan_id': planId,
      'title': title,
      if (dueAt != null) 'due_at': dueAt.toIso8601String(),
    });
  }

  Future<void> toggleTask(String taskId, bool done) async {
    await _client.from('study_tasks').update({'done': done}).eq('id', taskId);
  }

  Future<void> deleteTask(String taskId) async {
    await _client.from('study_tasks').delete().eq('id', taskId);
  }

  // ── Search analytics ─────────────────────────────────────────

  Future<void> logSearch(String? userId, String query) async {
    if (query.trim().isEmpty) return;
    try {
      await _client.from('academic_searches').insert({
        if (userId != null) 'user_id': userId,
        'query': query.trim(),
      });
    } catch (_) {}
  }

  // ── Admin analytics ──────────────────────────────────────────

  Future<AcademicStats> getStats() async {
    Future<int> total(String table) async =>
        (await _client.from(table).select('id') as List).length;

    final topSearches = <String, int>{};
    try {
      final ts = await _client.rpc('top_academic_searches');
      for (final r in (ts as List)) {
        topSearches[r['query'] as String] = (r['total'] as num).toInt();
      }
    } catch (_) {}

    List<ResourceModel> mostDownloaded = [];
    try {
      final data = await _client
          .from('academic_resources')
          .select('*, $_uploaderJoin')
          .order('download_count', ascending: false)
          .limit(5);
      mostDownloaded = (data as List)
          .map((r) => ResourceModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {}

    return AcademicStats(
      courses: await total('courses'),
      resources: await total('academic_resources'),
      topDownloads:
          mostDownloaded.isEmpty ? 0 : mostDownloaded.first.downloadCount,
      topSearches: topSearches,
      mostDownloaded: mostDownloaded,
    );
  }

  // ── Hive cache helpers ───────────────────────────────────────

  Future<void> _cacheList(String key, List<Map<String, dynamic>> data) async {
    try {
      final box = await Hive.openBox(_box);
      await box.put(key, jsonEncode(data));
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>?> _readCache(String key) async {
    try {
      final box = await Hive.openBox(_box);
      final raw = box.get(key) as String?;
      if (raw == null) return null;
      return (jsonDecode(raw) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (_) {
      return null;
    }
  }
}
