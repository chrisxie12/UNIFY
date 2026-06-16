class VerificationRequestModel {
  final String id;
  final String userId;
  final String universityId;
  final String position;
  final String? classRepresented;
  final String? department;
  final String academicYear;
  final String? evidenceUrl;
  final String? evidenceType;
  final String status;
  final String? adminNotes;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const VerificationRequestModel({
    required this.id,
    required this.userId,
    required this.universityId,
    required this.position,
    this.classRepresented,
    this.department,
    required this.academicYear,
    this.evidenceUrl,
    this.evidenceType,
    this.status = 'pending',
    this.adminNotes,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });

  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    return VerificationRequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      universityId: json['university_id'] as String,
      position: json['position'] as String,
      classRepresented: json['class_represented'] as String?,
      department: json['department'] as String?,
      academicYear: json['academic_year'] as String,
      evidenceUrl: json['evidence_url'] as String?,
      evidenceType: json['evidence_type'] as String?,
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['admin_notes'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'university_id': universityId,
      'position': position,
      'class_represented': classRepresented,
      'department': department,
      'academic_year': academicYear,
      'evidence_url': evidenceUrl,
      'evidence_type': evidenceType,
    };
  }
}
