// CAMPUS AMBASSADOR module data models.
//
// Each model maps directly onto its Supabase table. Joins (e.g. profile names)
// are pulled into optional fields via fromJson.

// ── Ambassador ───────────────────────────────────────────────

class Ambassador {
  final String id;
  final String userId;
  final String? universityName;
  final String? faculty;
  final String? department;
  final String? bio;
  final String? contact;
  final String status; // active | inactive | pending
  final int referralCount;
  final int eventsOrganized;
  final DateTime joinedAt;

  // Joined from profiles!ambassadors_user_id_fkey(full_name, avatar_url)
  final String? fullName;
  final String? avatarUrl;

  const Ambassador({
    required this.id,
    required this.userId,
    this.universityName,
    this.faculty,
    this.department,
    this.bio,
    this.contact,
    this.status = 'active',
    this.referralCount = 0,
    this.eventsOrganized = 0,
    required this.joinedAt,
    this.fullName,
    this.avatarUrl,
  });

  factory Ambassador.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return Ambassador(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      universityName: json['university_name'] as String?,
      faculty: json['faculty'] as String?,
      department: json['department'] as String?,
      bio: json['bio'] as String?,
      contact: json['contact'] as String?,
      status: json['status'] as String? ?? 'active',
      referralCount: json['referral_count'] as int? ?? 0,
      eventsOrganized: json['events_organized'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      fullName: profile?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
    );
  }
}

// ── Ambassador Event ─────────────────────────────────────────

class AmbassadorEvent {
  final String id;
  final String ambassadorId;
  final String title;
  final String? description;
  final DateTime? eventDate;
  final int attendance;
  final DateTime createdAt;

  const AmbassadorEvent({
    required this.id,
    required this.ambassadorId,
    required this.title,
    this.description,
    this.eventDate,
    this.attendance = 0,
    required this.createdAt,
  });

  factory AmbassadorEvent.fromJson(Map<String, dynamic> json) {
    return AmbassadorEvent(
      id: json['id'] as String,
      ambassadorId: json['ambassador_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'] as String)
          : null,
      attendance: json['attendance'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
