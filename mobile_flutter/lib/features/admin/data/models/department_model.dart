class DepartmentModel {
  final String id;
  final String facultyId;
  final String name;
  final String? description;
  final DateTime createdAt;

  const DepartmentModel({
    required this.id,
    required this.facultyId,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as String,
      facultyId: json['faculty_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'faculty_id': facultyId,
    'name': name,
    if (description != null) 'description': description,
    'created_at': createdAt.toIso8601String(),
  };
}
