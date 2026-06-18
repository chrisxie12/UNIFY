class AuditLogModel {
  final String id;
  final String actorId;
  final String action;
  final String entityType;
  final String? entityId;
  final String? universityId;
  final Map<String, dynamic> details;
  final String? ipAddress;
  final DateTime createdAt;
  final String? actorName;

  const AuditLogModel({
    required this.id,
    required this.actorId,
    required this.action,
    required this.entityType,
    this.entityId,
    this.universityId,
    this.details = const {},
    this.ipAddress,
    required this.createdAt,
    this.actorName,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    final profileData = json['profiles'] as Map<String, dynamic>?;
    return AuditLogModel(
      id: json['id'] as String,
      actorId: json['actor_id'] as String,
      action: json['action'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String?,
      universityId: json['university_id'] as String?,
      details: json['details'] as Map<String, dynamic>? ?? {},
      ipAddress: json['ip_address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      actorName: profileData?['full_name'] as String?,
    );
  }

  String get actionLabel {
    return action.replaceAll('_', ' ');
  }
}
