class VerificationRequestModel {
  final String id;
  final String userId;
  final String universityId;
  final String position;
  final String? classRepresented;
  final String? department;
  final String? programme;
  final String? level;
  final String? academicYear;
  final String? evidenceUrl;
  final String? evidenceType;
  final String status; // pending / approved / rejected
  final String? adminNotes;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  // Joined from profiles
  final String? requesterName;
  final String? requesterAvatar;
  final String? requesterProgramme;

  const VerificationRequestModel({
    required this.id,
    required this.userId,
    required this.universityId,
    required this.position,
    this.classRepresented,
    this.department,
    this.programme,
    this.level,
    this.academicYear,
    this.evidenceUrl,
    this.evidenceType,
    this.status = 'pending',
    this.adminNotes,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    this.requesterName,
    this.requesterAvatar,
    this.requesterProgramme,
  });

  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return VerificationRequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      universityId: json['university_id'] as String,
      position: json['position'] as String,
      classRepresented: json['class_represented'] as String?,
      department: json['department'] as String?,
      programme: json['programme'] as String?,
      level: json['level'] as String?,
      academicYear: json['academic_year'] as String?,
      evidenceUrl: json['evidence_url'] as String?,
      evidenceType: json['evidence_type'] as String?,
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['admin_notes'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      requesterName: profile?['full_name'] as String?,
      requesterAvatar: profile?['avatar_url'] as String?,
      requesterProgramme: profile?['programme'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'user_id': userId,
    'university_id': universityId,
    'position': position,
    if (classRepresented != null) 'class_represented': classRepresented,
    if (department != null) 'department': department,
    if (programme != null) 'programme': programme,
    if (level != null) 'level': level,
    if (academicYear != null) 'academic_year': academicYear,
    if (evidenceUrl != null) 'evidence_url': evidenceUrl,
    if (evidenceType != null) 'evidence_type': evidenceType,
  };
}
