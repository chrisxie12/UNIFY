class SupabaseTables {
  SupabaseTables._();

  static const String profiles              = 'profiles';
  static const String universities          = 'universities';
  static const String announcements         = 'announcements';
  static const String announcementReads     = 'announcement_reads';
  static const String badges                = 'badges';
  static const String userBadges            = 'user_badges';
  static const String leadershipRoles       = 'leadership_roles';
  static const String userLeadership        = 'user_leadership';
  static const String communityRequests     = 'community_requests';
  static const String communities           = 'communities';
  static const String communityMembers      = 'community_members';
  static const String communityManagers     = 'community_managers';
  static const String verificationRequests  = 'verification_requests';
  static const String verificationLog       = 'verification_log';
  static const String announcementRequests  = 'announcement_requests';
}

class SupabaseColumns {
  SupabaseColumns._();

  // profiles
  static const String id           = 'id';
  static const String universityId = 'university_id';
  static const String fullName     = 'full_name';
  static const String phone        = 'phone';
  static const String avatarUrl    = 'avatar_url';
  static const String bio          = 'bio';
  static const String level        = 'level';
  static const String programme    = 'programme';
  static const String studentId    = 'student_id';
  static const String isVerified   = 'is_verified';
  static const String role         = 'role';
  static const String email        = 'email';

  // announcements
  static const String title        = 'title';
  static const String body         = 'body';
  static const String category     = 'category';
  static const String isPublished  = 'is_published';
  static const String publishedAt  = 'published_at';
  static const String expiresAt    = 'expires_at';
  static const String authorId     = 'author_id';
  static const String createdAt    = 'created_at';

  // badges
  static const String name         = 'name';
  static const String slug         = 'slug';
  static const String description  = 'description';
  static const String iconUrl      = 'icon_url';

  // leadership
  static const String title_       = 'title';
  static const String position     = 'position';
  static const String academicYear = 'academic_year';
  static const String verifiedBy   = 'verified_by';
  static const String verifiedAt   = 'verified_at';
  static const String isActive     = 'is_active';

  // community requests
  static const String communityName   = 'community_name';
  static const String communityType   = 'community_type';
  static const String estimatedStudentCount = 'estimated_student_count';
  static const String purpose         = 'purpose';
  static const String status          = 'status';
  static const String adminFeedback    = 'admin_feedback';
  static const String reviewedBy      = 'reviewed_by';
  static const String reviewedAt      = 'reviewed_at';

  // communities
  static const String description_   = 'description';
  static const String memberCount   = 'member_count';
  static const String createdBy     = 'created_by';

  // community members
  static const String communityId   = 'community_id';
  static const String userId        = 'user_id';
  static const String joinedAt      = 'joined_at';

  // community managers
  static const String assignedBy    = 'assigned_by';
  static const String assignedAt    = 'assigned_at';

  // announcement requests
  static const String requesterId   = 'requester_id';
  static const String isUrgent      = 'is_urgent';
  static const String targetAudience = 'target_audience';
  static const String adminNotes    = 'admin_notes';

  // profile extensions
  static const String faculty       = 'faculty';
  static const String department    = 'department';

  // verification requests
  static const String evidenceUrl   = 'evidence_url';
  static const String evidenceType  = 'evidence_type';

  // universities
  static const String shortName     = 'short_name';
  static const String domain        = 'domain';
  static const String logoUrl       = 'logo_url';
  static const String accentColor   = 'accent_color';
  static const String isActive_     = 'is_active';
}
