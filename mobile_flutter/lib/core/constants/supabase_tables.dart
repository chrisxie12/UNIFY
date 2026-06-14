class SupabaseTables {
  SupabaseTables._();

  static const String profiles = 'profiles';
  static const String universities = 'universities';
  static const String announcements = 'announcements';
  static const String announcementReads = 'announcement_reads';
}

class SupabaseColumns {
  SupabaseColumns._();

  // profiles
  static const String id = 'id';
  static const String fullName = 'full_name';
  static const String bio = 'bio';
  static const String level = 'level';
  static const String programme = 'programme';
  static const String avatarUrl = 'avatar_url';
  static const String isVerified = 'is_verified';
  static const String role = 'role';
  static const String universityId = 'university_id';
  static const String studentId = 'student_id';

  // announcements
  static const String title = 'title';
  static const String body = 'body';
  static const String category = 'category';
  static const String isPublished = 'is_published';
  static const String publishedAt = 'published_at';
  static const String expiresAt = 'expires_at';
  static const String authorId = 'author_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
