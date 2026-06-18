class CourseModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final int credits;
  final String? university;
  final String? faculty;
  final String? department;
  final String? level;
  final String? semester;
  final String? lecturerName;
  final String? lecturerId;
  final String? communityId;
  final String? createdBy;
  final DateTime createdAt;
  final int resourceCount;
  final int assignmentCount;

  CourseModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.credits = 3,
    this.university,
    this.faculty,
    this.department,
    this.level,
    this.semester,
    this.lecturerName,
    this.lecturerId,
    this.communityId,
    this.createdBy,
    required this.createdAt,
    this.resourceCount = 0,
    this.assignmentCount = 0,
  });

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      credits: map['credits'] as int? ?? 3,
      university: map['university'] as String?,
      faculty: map['faculty'] as String?,
      department: map['department'] as String?,
      level: map['level'] as String?,
      semester: map['semester'] as String?,
      lecturerName: map['lecturer_name'] as String?,
      lecturerId: map['lecturer_id'] as String?,
      communityId: map['community_id'] as String?,
      createdBy: map['created_by'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      resourceCount: map['resource_count'] as int? ?? 0,
      assignmentCount: map['assignment_count'] as int? ?? 0,
    );
  }
}

class AcademicResourceModel {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final String type;
  final String fileUrl;
  final String fileType;
  final int? fileSize;
  final String? thumbnailUrl;
  final String? university;
  final String? faculty;
  final String? department;
  final String? academicYear;
  final String? semester;
  final String? lecturer;
  final String uploadedBy;
  final String? uploaderName;
  final String verificationStatus;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  int downloadCount;
  int viewCount;
  final DateTime createdAt;
  double averageRating;
  int ratingCount;
  bool isOffline;

  AcademicResourceModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.type,
    required this.fileUrl,
    required this.fileType,
    this.fileSize,
    this.thumbnailUrl,
    this.university,
    this.faculty,
    this.department,
    this.academicYear,
    this.semester,
    this.lecturer,
    required this.uploadedBy,
    this.uploaderName,
    this.verificationStatus = 'student_uploaded',
    this.verifiedBy,
    this.verifiedAt,
    this.downloadCount = 0,
    this.viewCount = 0,
    required this.createdAt,
    this.averageRating = 0,
    this.ratingCount = 0,
    this.isOffline = false,
  });

  bool get isVerified => verificationStatus != 'student_uploaded';
  String get verificationLabel {
    switch (verificationStatus) {
      case 'verified_course_rep': return 'Verified by Course Rep';
      case 'verified_faculty_admin': return 'Verified by Faculty Admin';
      case 'official': return 'Official Resource';
      default: return 'Student Uploaded';
    }
  }

  factory AcademicResourceModel.fromMap(Map<String, dynamic> map) {
    return AcademicResourceModel(
      id: map['id'] as String,
      courseId: map['course_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      type: map['type'] as String,
      fileUrl: map['file_url'] as String,
      fileType: map['file_type'] as String,
      fileSize: map['file_size'] as int?,
      thumbnailUrl: map['thumbnail_url'] as String?,
      university: map['university'] as String?,
      faculty: map['faculty'] as String?,
      department: map['department'] as String?,
      academicYear: map['academic_year'] as String?,
      semester: map['semester'] as String?,
      lecturer: map['lecturer'] as String?,
      uploadedBy: map['uploaded_by'] as String,
      uploaderName: map['uploader_name'] as String?,
      verificationStatus: map['verification_status'] as String? ?? 'student_uploaded',
      verifiedBy: map['verified_by'] as String?,
      verifiedAt: map['verified_at'] != null ? DateTime.parse(map['verified_at'] as String) : null,
      downloadCount: map['download_count'] as int? ?? 0,
      viewCount: map['view_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      averageRating: (map['average_rating'] as num?)?.toDouble() ?? 0,
      ratingCount: map['rating_count'] as int? ?? 0,
    );
  }
}

class AssignmentModel {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final double? maxScore;
  final String submissionType;
  final String? createdBy;
  final DateTime createdAt;
  bool isSubmitted;
  bool isGraded;
  double? score;
  String? feedback;

  AssignmentModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.dueDate,
    this.maxScore,
    this.submissionType = 'link',
    this.createdBy,
    required this.createdAt,
    this.isSubmitted = false,
    this.isGraded = false,
    this.score,
    this.feedback,
  });

  bool get isOverdue => DateTime.now().isAfter(dueDate);

  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      id: map['id'] as String,
      courseId: map['course_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: DateTime.parse(map['due_date'] as String),
      maxScore: (map['max_score'] as num?)?.toDouble(),
      submissionType: map['submission_type'] as String? ?? 'link',
      createdBy: map['created_by'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      isSubmitted: map['is_submitted'] as bool? ?? false,
      isGraded: map['is_graded'] as bool? ?? false,
      score: (map['score'] as num?)?.toDouble(),
      feedback: map['feedback'] as String?,
    );
  }
}

class GPARecord {
  final String id;
  final String userId;
  final String semester;
  final String? academicYear;
  final double gpa;
  final int totalCredits;
  final double totalGradePoints;
  final bool isCgpa;
  final DateTime createdAt;
  final List<GPACourse> courses;

  GPARecord({
    required this.id,
    required this.userId,
    required this.semester,
    this.academicYear,
    required this.gpa,
    required this.totalCredits,
    required this.totalGradePoints,
    this.isCgpa = false,
    required this.createdAt,
    this.courses = const [],
  });

  factory GPARecord.fromMap(Map<String, dynamic> map) {
    return GPARecord(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      semester: map['semester'] as String,
      academicYear: map['academic_year'] as String?,
      gpa: (map['gpa'] as num).toDouble(),
      totalCredits: map['total_credits'] as int,
      totalGradePoints: (map['total_grade_points'] as num).toDouble(),
      isCgpa: map['is_cgpa'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      courses: map['courses'] != null
          ? (map['courses'] as List).map((c) => GPACourse.fromMap(c as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

class GPACourse {
  final String id;
  final String? gpaRecordId;
  final String courseName;
  final String? courseCode;
  final int credits;
  final String grade;
  final double gradePoint;

  GPACourse({
    required this.id,
    this.gpaRecordId,
    required this.courseName,
    this.courseCode,
    required this.credits,
    required this.grade,
    required this.gradePoint,
  });

  factory GPACourse.fromMap(Map<String, dynamic> map) {
    return GPACourse(
      id: map['id'] as String,
      gpaRecordId: map['gpa_record_id'] as String?,
      courseName: map['course_name'] as String,
      courseCode: map['course_code'] as String?,
      credits: map['credits'] as int,
      grade: map['grade'] as String,
      gradePoint: (map['grade_point'] as num).toDouble(),
    );
  }
}

class StudyPlanModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? examDate;
  final bool isActive;
  final DateTime createdAt;
  final List<StudyPlanItem> items;

  StudyPlanModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.examDate,
    this.isActive = true,
    required this.createdAt,
    this.items = const [],
  });

  double get progress {
    if (items.isEmpty) return 0;
    return items.where((i) => i.isCompleted).length / items.length;
  }

  factory StudyPlanModel.fromMap(Map<String, dynamic> map) {
    return StudyPlanModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date'] as String) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      examDate: map['exam_date'] != null ? DateTime.parse(map['exam_date'] as String) : null,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      items: map['items'] != null
          ? (map['items'] as List).map((i) => StudyPlanItem.fromMap(i as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

class StudyPlanItem {
  final String id;
  final String planId;
  final String? courseId;
  final String title;
  final String? description;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final int? durationMinutes;
  final bool isCompleted;
  final String priority;
  final DateTime createdAt;

  StudyPlanItem({
    required this.id,
    required this.planId,
    this.courseId,
    required this.title,
    this.description,
    this.scheduledDate,
    this.scheduledTime,
    this.durationMinutes,
    this.isCompleted = false,
    this.priority = 'medium',
    required this.createdAt,
  });

  factory StudyPlanItem.fromMap(Map<String, dynamic> map) {
    return StudyPlanItem(
      id: map['id'] as String,
      planId: map['plan_id'] as String,
      courseId: map['course_id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      scheduledDate: map['scheduled_date'] != null ? DateTime.parse(map['scheduled_date'] as String) : null,
      scheduledTime: map['scheduled_time'] as String?,
      durationMinutes: map['duration_minutes'] as int?,
      isCompleted: map['is_completed'] as bool? ?? false,
      priority: map['priority'] as String? ?? 'medium',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class ResourceRating {
  final String id;
  final String resourceId;
  final String userId;
  final int rating;
  final String? review;
  final DateTime createdAt;

  ResourceRating({
    required this.id,
    required this.resourceId,
    required this.userId,
    required this.rating,
    this.review,
    required this.createdAt,
  });

  factory ResourceRating.fromMap(Map<String, dynamic> map) {
    return ResourceRating(
      id: map['id'] as String,
      resourceId: map['resource_id'] as String,
      userId: map['user_id'] as String,
      rating: map['rating'] as int,
      review: map['review'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class ExamTimetable {
  final String id;
  final String courseId;
  final DateTime examDate;
  final String? examTime;
  final String? venue;
  final int? durationMinutes;
  final String? createdBy;
  final DateTime createdAt;
  final String? courseName;
  final String? courseCode;

  ExamTimetable({
    required this.id,
    required this.courseId,
    required this.examDate,
    this.examTime,
    this.venue,
    this.durationMinutes,
    this.createdBy,
    required this.createdAt,
    this.courseName,
    this.courseCode,
  });

  factory ExamTimetable.fromMap(Map<String, dynamic> map) {
    return ExamTimetable(
      id: map['id'] as String,
      courseId: map['course_id'] as String,
      examDate: DateTime.parse(map['exam_date'] as String),
      examTime: map['exam_time'] as String?,
      venue: map['venue'] as String?,
      durationMinutes: map['duration_minutes'] as int?,
      createdBy: map['created_by'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      courseName: map['course_name'] as String?,
      courseCode: map['course_code'] as String?,
    );
  }
}
