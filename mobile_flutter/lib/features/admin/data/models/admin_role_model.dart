class AdminRoleModel {
  final String id;
  final String role;
  final String? description;
  final DateTime createdAt;

  const AdminRoleModel({
    required this.id,
    required this.role,
    this.description,
    required this.createdAt,
  });

  factory AdminRoleModel.fromJson(Map<String, dynamic> json) {
    return AdminRoleModel(
      id: json['id'] as String,
      role: json['role'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    if (description != null) 'description': description,
    'created_at': createdAt.toIso8601String(),
  };
}
