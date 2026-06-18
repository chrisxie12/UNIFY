class FacultyModel {
  final String id;
  final String universityId;
  final String name;
  final String type;
  final String? description;
  final DateTime createdAt;

  const FacultyModel({
    required this.id,
    required this.universityId,
    required this.name,
    this.type = 'faculty',
    this.description,
    required this.createdAt,
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      id: json['id'] as String,
      universityId: json['university_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'faculty',
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'university_id': universityId,
    'name': name,
    'type': type,
    if (description != null) 'description': description,
    'created_at': createdAt.toIso8601String(),
  };
}
