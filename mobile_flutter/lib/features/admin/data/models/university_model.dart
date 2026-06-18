class UniversityModel {
  final String id;
  final String name;
  final String? shortName;
  final String? logoUrl;
  final String? country;
  final String? region;
  final String? website;
  final String? verificationDomain;
  final String? themePrimary;
  final String? themeSecondary;
  final String? welcomeScreen;
  final bool isActive;
  final DateTime createdAt;

  const UniversityModel({
    required this.id,
    required this.name,
    this.shortName,
    this.logoUrl,
    this.country,
    this.region,
    this.website,
    this.verificationDomain,
    this.themePrimary,
    this.themeSecondary,
    this.welcomeScreen,
    this.isActive = true,
    required this.createdAt,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['short_name'] as String?,
      logoUrl: json['logo_url'] as String?,
      country: json['country'] as String?,
      region: json['region'] as String?,
      website: json['website'] as String?,
      verificationDomain: json['verification_domain'] as String?,
      themePrimary: json['theme_primary'] as String?,
      themeSecondary: json['theme_secondary'] as String?,
      welcomeScreen: json['welcome_screen'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (shortName != null) 'short_name': shortName,
    if (logoUrl != null) 'logo_url': logoUrl,
    if (country != null) 'country': country,
    if (region != null) 'region': region,
    if (website != null) 'website': website,
    if (verificationDomain != null) 'verification_domain': verificationDomain,
    if (themePrimary != null) 'theme_primary': themePrimary,
    if (themeSecondary != null) 'theme_secondary': themeSecondary,
    if (welcomeScreen != null) 'welcome_screen': welcomeScreen,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
  };
}
