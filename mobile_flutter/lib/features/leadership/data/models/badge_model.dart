class BadgeModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? iconUrl;
  final String category;
  final bool isSystem;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconUrl,
    this.category = 'general',
    this.isSystem = false,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      category: json['category'] as String? ?? 'general',
      isSystem: json['is_system'] as bool? ?? false,
    );
  }
}
