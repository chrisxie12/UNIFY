import 'package:flutter/material.dart';

// ── Resource type ──────────────────────────────────────────────

enum ResourceType {
  lectureNote('lecture_note', 'Notes', Icons.description_rounded),
  pastQuestion('past_question', 'Past Questions', Icons.quiz_rounded),
  assignment('assignment', 'Assignments', Icons.assignment_rounded),
  slides('slides', 'Slides', Icons.slideshow_rounded),
  studyGuide('study_guide', 'Study Guides', Icons.menu_book_rounded),
  textbook('textbook', 'Textbooks', Icons.auto_stories_rounded),
  project('project', 'Projects', Icons.science_rounded),
  other('other', 'Other', Icons.folder_rounded);

  const ResourceType(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;

  static ResourceType fromKey(String? key) => ResourceType.values
      .firstWhere((t) => t.key == key, orElse: () => ResourceType.other);

  Color get color {
    switch (this) {
      case ResourceType.lectureNote:
        return const Color(0xFF0066FF);
      case ResourceType.pastQuestion:
        return const Color(0xFFDC2626);
      case ResourceType.assignment:
        return const Color(0xFFD97706);
      case ResourceType.slides:
        return const Color(0xFF7C3AED);
      case ResourceType.studyGuide:
        return const Color(0xFF0F766E);
      case ResourceType.textbook:
        return const Color(0xFF2563EB);
      case ResourceType.project:
        return const Color(0xFF0891B2);
      case ResourceType.other:
        return const Color(0xFF6B7280);
    }
  }
}

// ── Verification ladder ────────────────────────────────────────

enum ResourceVerification {
  student('student', 'Student Uploaded'),
  courseRep('course_rep', 'Verified by Course Rep'),
  facultyAdmin('faculty_admin', 'Verified by Faculty Admin'),
  official('official', 'Official Resource');

  const ResourceVerification(this.key, this.label);
  final String key;
  final String label;

  static ResourceVerification fromKey(String? key) => ResourceVerification.values
      .firstWhere((v) => v.key == key, orElse: () => ResourceVerification.student);

  bool get isVerified => this != ResourceVerification.student;

  Color get color {
    switch (this) {
      case ResourceVerification.student:
        return const Color(0xFF9CA3AF);
      case ResourceVerification.courseRep:
        return const Color(0xFF0066FF);
      case ResourceVerification.facultyAdmin:
        return const Color(0xFF7C3AED);
      case ResourceVerification.official:
        return const Color(0xFF10B981);
    }
  }
}

// ── Course ─────────────────────────────────────────────────────

class CourseModel {
  final String id;
  final String? universityId;
  final String? communityId;
  final String code;
  final String title;
  final String? description;
  final String? faculty;
  final String? department;
  final String? level;
  final int? credits;
  final String? lecturer;
  final String? academicYear;
  final String? semester;
  final int viewCount;
  final int resourceCount;

  const CourseModel({
    required this.id,
    this.universityId,
    this.communityId,
    required this.code,
    required this.title,
    this.description,
    this.faculty,
    this.department,
    this.level,
    this.credits,
    this.lecturer,
    this.academicYear,
    this.semester,
    this.viewCount = 0,
    this.resourceCount = 0,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id: json['id'] as String,
        universityId: json['university_id'] as String?,
        communityId: json['community_id'] as String?,
        code: json['code'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        faculty: json['faculty'] as String?,
        department: json['department'] as String?,
        level: json['level'] as String?,
        credits: json['credits'] as int?,
        lecturer: json['lecturer'] as String?,
        academicYear: json['academic_year'] as String?,
        semester: json['semester'] as String?,
        viewCount: json['view_count'] as int? ?? 0,
        resourceCount: json['resource_count'] as int? ?? 0,
      );

  Map<String, dynamic> toCache() => {
        'id': id,
        'university_id': universityId,
        'community_id': communityId,
        'code': code,
        'title': title,
        'description': description,
        'faculty': faculty,
        'department': department,
        'level': level,
        'credits': credits,
        'lecturer': lecturer,
        'academic_year': academicYear,
        'semester': semester,
        'view_count': viewCount,
        'resource_count': resourceCount,
      };

  String get subtitle => [
        if (department != null) department,
        if (level != null) 'Level $level',
        if (credits != null) '$credits credits',
      ].whereType<String>().join(' · ');
}

// ── Academic resource ──────────────────────────────────────────

class ResourceModel {
  final String id;
  final String? courseId;
  final String? communityId;
  final String? universityId;
  final String? uploaderId;
  final String title;
  final String? description;
  final String? faculty;
  final String? department;
  final String? academicYear;
  final String? semester;
  final String? lecturer;
  final ResourceType resourceType;
  final String fileType; // pdf|docx|ppt|image|link|...
  final String? fileUrl;
  final String? linkUrl;
  final int? fileSize;
  final ResourceVerification verification;
  final int downloadCount;
  final int viewCount;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;
  final String? uploaderName;

  const ResourceModel({
    required this.id,
    this.courseId,
    this.communityId,
    this.universityId,
    this.uploaderId,
    required this.title,
    this.description,
    this.faculty,
    this.department,
    this.academicYear,
    this.semester,
    this.lecturer,
    this.resourceType = ResourceType.other,
    this.fileType = 'link',
    this.fileUrl,
    this.linkUrl,
    this.fileSize,
    this.verification = ResourceVerification.student,
    this.downloadCount = 0,
    this.viewCount = 0,
    this.rating = 0,
    this.ratingCount = 0,
    required this.createdAt,
    this.uploaderName,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    return ResourceModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String?,
      communityId: json['community_id'] as String?,
      universityId: json['university_id'] as String?,
      uploaderId: json['uploader_id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      faculty: json['faculty'] as String?,
      department: json['department'] as String?,
      academicYear: json['academic_year'] as String?,
      semester: json['semester'] as String?,
      lecturer: json['lecturer'] as String?,
      resourceType: ResourceType.fromKey(json['resource_type'] as String?),
      fileType: json['file_type'] as String? ?? 'link',
      fileUrl: json['file_url'] as String?,
      linkUrl: json['link_url'] as String?,
      fileSize: json['file_size'] as int?,
      verification:
          ResourceVerification.fromKey(json['verification'] as String?),
      downloadCount: json['download_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: json['rating_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      uploaderName: p?['full_name'] as String?,
    );
  }

  Map<String, dynamic> toCache() => {
        'id': id,
        'course_id': courseId,
        'community_id': communityId,
        'university_id': universityId,
        'uploader_id': uploaderId,
        'title': title,
        'description': description,
        'faculty': faculty,
        'department': department,
        'academic_year': academicYear,
        'semester': semester,
        'lecturer': lecturer,
        'resource_type': resourceType.key,
        'file_type': fileType,
        'file_url': fileUrl,
        'link_url': linkUrl,
        'file_size': fileSize,
        'verification': verification.key,
        'download_count': downloadCount,
        'view_count': viewCount,
        'rating': rating,
        'rating_count': ratingCount,
        'created_at': createdAt.toIso8601String(),
        'profiles': {'full_name': uploaderName},
      };

  String? get url => linkUrl?.isNotEmpty == true ? linkUrl : fileUrl;
  bool get isImage => fileType == 'image';

  String get sizeLabel {
    if (fileSize == null) return '';
    final kb = fileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}

class ResourceRating {
  final String userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? userName;

  const ResourceRating({
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userName,
  });

  factory ResourceRating.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    return ResourceRating(
      userId: json['user_id'] as String,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: p?['full_name'] as String?,
    );
  }
}

// ── Assignment ─────────────────────────────────────────────────

class AssignmentModel {
  final String id;
  final String? courseId;
  final String title;
  final String? description;
  final String? linkUrl;
  final DateTime? dueAt;
  final DateTime createdAt;
  final String? submissionStatus; // todo|submitted|done (for current user)

  const AssignmentModel({
    required this.id,
    this.courseId,
    required this.title,
    this.description,
    this.linkUrl,
    this.dueAt,
    required this.createdAt,
    this.submissionStatus,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json,
      {String? status}) {
    return AssignmentModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      linkUrl: json['link_url'] as String?,
      dueAt: json['due_at'] != null
          ? DateTime.tryParse(json['due_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      submissionStatus: status,
    );
  }

  int? get daysLeft =>
      dueAt == null ? null : dueAt!.difference(DateTime.now()).inHours ~/ 24;
  bool get isOverdue => dueAt != null && DateTime.now().isAfter(dueAt!);
  bool get isDone => submissionStatus == 'submitted' || submissionStatus == 'done';

  String get dueLabel {
    if (dueAt == null) return 'No due date';
    final d = daysLeft!;
    if (d < 0) return 'Overdue';
    if (d == 0) return 'Due today';
    if (d == 1) return 'Due tomorrow';
    return 'Due in $d days';
  }
}

// ── Exam schedule ──────────────────────────────────────────────

class ExamModel {
  final String id;
  final String? courseId;
  final String title;
  final String examType; // quiz|midsem|exam|presentation|other
  final DateTime? examDate;
  final String? venue;
  final String? notes;

  const ExamModel({
    required this.id,
    this.courseId,
    required this.title,
    this.examType = 'exam',
    this.examDate,
    this.venue,
    this.notes,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) => ExamModel(
        id: json['id'] as String,
        courseId: json['course_id'] as String?,
        title: json['title'] as String? ?? '',
        examType: json['exam_type'] as String? ?? 'exam',
        examDate: json['exam_date'] != null
            ? DateTime.tryParse(json['exam_date'] as String)
            : null,
        venue: json['venue'] as String?,
        notes: json['notes'] as String?,
      );

  int? get daysLeft => examDate == null
      ? null
      : examDate!.difference(DateTime.now()).inHours ~/ 24;
}

// ── GPA ────────────────────────────────────────────────────────

class GpaEntry {
  final String id;
  final String semester;
  final String courseName;
  final double credits;
  final double gradePoint;
  final String? gradeLabel;

  const GpaEntry({
    required this.id,
    required this.semester,
    required this.courseName,
    required this.credits,
    required this.gradePoint,
    this.gradeLabel,
  });

  factory GpaEntry.fromJson(Map<String, dynamic> json) => GpaEntry(
        id: json['id'] as String,
        semester: json['semester'] as String? ?? '',
        courseName: json['course_name'] as String? ?? '',
        credits: (json['credits'] as num?)?.toDouble() ?? 0,
        gradePoint: (json['grade_point'] as num?)?.toDouble() ?? 0,
        gradeLabel: json['grade_label'] as String?,
      );
}

/// Standard 4.0-scale letter grades used by the GPA calculator.
const List<({String label, double point})> kGrades = [
  (label: 'A', point: 4.0),
  (label: 'B+', point: 3.5),
  (label: 'B', point: 3.0),
  (label: 'C+', point: 2.5),
  (label: 'C', point: 2.0),
  (label: 'D+', point: 1.5),
  (label: 'D', point: 1.0),
  (label: 'F', point: 0.0),
];

// ── Study planner ──────────────────────────────────────────────

enum StudyPlanType {
  schedule('schedule', 'Schedule'),
  revision('revision', 'Revision'),
  countdown('countdown', 'Countdown');

  const StudyPlanType(this.key, this.label);
  final String key;
  final String label;

  static StudyPlanType fromKey(String? k) => StudyPlanType.values
      .firstWhere((t) => t.key == k, orElse: () => StudyPlanType.schedule);
}

class StudyPlan {
  final String id;
  final String title;
  final StudyPlanType type;
  final DateTime? targetDate;
  final DateTime createdAt;
  final List<StudyTask> tasks;

  const StudyPlan({
    required this.id,
    required this.title,
    this.type = StudyPlanType.schedule,
    this.targetDate,
    required this.createdAt,
    this.tasks = const [],
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    final tasks = (json['study_tasks'] as List?)
            ?.map((t) => StudyTask.fromJson(t as Map<String, dynamic>))
            .toList() ??
        const <StudyTask>[];
    tasks.sort((a, b) => a.position.compareTo(b.position));
    return StudyPlan(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      type: StudyPlanType.fromKey(json['type'] as String?),
      targetDate: json['target_date'] != null
          ? DateTime.tryParse(json['target_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      tasks: tasks,
    );
  }

  int get doneCount => tasks.where((t) => t.done).length;
  double get progress => tasks.isEmpty ? 0 : doneCount / tasks.length;
  int? get daysLeft => targetDate == null
      ? null
      : targetDate!.difference(DateTime.now()).inHours ~/ 24;
}

class StudyTask {
  final String id;
  final String planId;
  final String title;
  final DateTime? dueAt;
  final bool done;
  final int position;

  const StudyTask({
    required this.id,
    required this.planId,
    required this.title,
    this.dueAt,
    this.done = false,
    this.position = 0,
  });

  factory StudyTask.fromJson(Map<String, dynamic> json) => StudyTask(
        id: json['id'] as String,
        planId: json['plan_id'] as String,
        title: json['title'] as String? ?? '',
        dueAt: json['due_at'] != null
            ? DateTime.tryParse(json['due_at'] as String)
            : null,
        done: json['done'] as bool? ?? false,
        position: json['position'] as int? ?? 0,
      );
}

// ── Filters & analytics ────────────────────────────────────────

class ResourceFilter {
  final String? courseId;
  final ResourceType? type;
  final String? query;
  final String? faculty;
  final String? department;
  final bool verifiedOnly;
  final String sort; // recent | rating | downloads

  const ResourceFilter({
    this.courseId,
    this.type,
    this.query,
    this.faculty,
    this.department,
    this.verifiedOnly = false,
    this.sort = 'recent',
  });

  ResourceFilter copyWith({
    String? courseId,
    ResourceType? type,
    String? query,
    String? faculty,
    String? department,
    bool? verifiedOnly,
    String? sort,
    bool clearType = false,
  }) =>
      ResourceFilter(
        courseId: courseId ?? this.courseId,
        type: clearType ? null : (type ?? this.type),
        query: query ?? this.query,
        faculty: faculty ?? this.faculty,
        department: department ?? this.department,
        verifiedOnly: verifiedOnly ?? this.verifiedOnly,
        sort: sort ?? this.sort,
      );
}

class AcademicStats {
  final int courses;
  final int resources;
  final int topDownloads;
  final Map<String, int> topSearches;
  final List<ResourceModel> mostDownloaded;

  const AcademicStats({
    this.courses = 0,
    this.resources = 0,
    this.topDownloads = 0,
    this.topSearches = const {},
    this.mostDownloaded = const [],
  });
}
