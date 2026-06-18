class OpportunityModel {
  final String id;
  final String title;
  final String description;
  final String opportunityType;
  final String? universityId;
  final String organizerId;
  final DateTime? deadline;
  final String? eligibility;
  final String? url;
  final String status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final String? organizerName;
  final String? universityName;

  const OpportunityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.opportunityType,
    this.universityId,
    required this.organizerId,
    this.deadline,
    this.eligibility,
    this.url,
    this.status = 'pending',
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    this.organizerName,
    this.universityName,
  });

  factory OpportunityModel.fromJson(Map<String, dynamic> json) {
    final profileData = json['profiles'] as Map<String, dynamic>?;
    final uniData = json['universities'] as Map<String, dynamic>?;
    return OpportunityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      opportunityType: json['opportunity_type'] as String,
      universityId: json['university_id'] as String?,
      organizerId: json['organizer_id'] as String,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      eligibility: json['eligibility'] as String?,
      url: json['url'] as String?,
      status: json['status'] as String? ?? 'pending',
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      organizerName: profileData?['full_name'] as String?,
      universityName: uniData?['name'] as String?,
    );
  }

  String get opportunityTypeLabel {
    switch (opportunityType) {
      case 'scholarship': return 'Scholarship';
      case 'internship': return 'Internship';
      case 'fellowship': return 'Fellowship';
      case 'competition': return 'Competition';
      default: return opportunityType;
    }
  }

  bool get isExpired => deadline != null && deadline!.isBefore(DateTime.now());
  bool get isPending => status == 'pending';
}
