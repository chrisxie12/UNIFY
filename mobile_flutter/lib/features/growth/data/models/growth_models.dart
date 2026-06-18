// GROWTH module data models.
//
// Each model maps directly onto its Supabase table. Joins (e.g. profile names)
// are pulled into optional fields via fromJson.

// ── Waitlist ─────────────────────────────────────────────────

class WaitlistEntry {
  final String id;
  final String email;
  final String? fullName;
  final String? universityName;
  final String? programme;
  final String? level;
  final String? referredBy;
  final String status; // waiting | invited | joined | rejected
  final int position;
  final String? note;
  final DateTime createdAt;
  final DateTime? invitedAt;

  const WaitlistEntry({
    required this.id,
    required this.email,
    this.fullName,
    this.universityName,
    this.programme,
    this.level,
    this.referredBy,
    this.status = 'waiting',
    this.position = 0,
    this.note,
    required this.createdAt,
    this.invitedAt,
  });

  factory WaitlistEntry.fromJson(Map<String, dynamic> json) {
    return WaitlistEntry(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      universityName: json['university_name'] as String?,
      programme: json['programme'] as String?,
      level: json['level'] as String?,
      referredBy: json['referred_by'] as String?,
      status: json['status'] as String? ?? 'waiting',
      position: json['position'] as int? ?? 0,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      invitedAt: json['invited_at'] != null
          ? DateTime.parse(json['invited_at'] as String)
          : null,
    );
  }
}

// ── Invite Codes ─────────────────────────────────────────────

class InviteCode {
  final String id;
  final String code;
  final String? createdBy;
  final String type; // beta | referral | ambassador | general
  final int maxUses; // 0 = unlimited
  final int useCount;
  final DateTime? expiresAt;
  final bool isActive;
  final String? note;
  final DateTime createdAt;

  const InviteCode({
    required this.id,
    required this.code,
    this.createdBy,
    this.type = 'general',
    this.maxUses = 0,
    this.useCount = 0,
    this.expiresAt,
    this.isActive = true,
    this.note,
    required this.createdAt,
  });

  bool get isUnlimited => maxUses == 0;

  factory InviteCode.fromJson(Map<String, dynamic> json) {
    return InviteCode(
      id: json['id'] as String,
      code: json['code'] as String,
      createdBy: json['created_by'] as String?,
      type: json['type'] as String? ?? 'general',
      maxUses: json['max_uses'] as int? ?? 0,
      useCount: json['use_count'] as int? ?? 0,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// ── Beta Testers ─────────────────────────────────────────────

class BetaTester {
  final String userId;
  final String? invitedBy;
  final String cohort;
  final String status; // active | inactive | removed
  final int feedbackCount;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;

  // Joined from profiles!beta_testers_user_id_fkey(full_name, avatar_url)
  final String? fullName;
  final String? avatarUrl;

  const BetaTester({
    required this.userId,
    this.invitedBy,
    this.cohort = '',
    this.status = 'active',
    this.feedbackCount = 0,
    required this.joinedAt,
    this.lastActiveAt,
    this.fullName,
    this.avatarUrl,
  });

  factory BetaTester.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return BetaTester(
      userId: json['user_id'] as String,
      invitedBy: json['invited_by'] as String?,
      cohort: json['cohort'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      feedbackCount: json['feedback_count'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      fullName: profile?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
    );
  }
}

// ── Referrals ────────────────────────────────────────────────

class Referral {
  final String id;
  final String referrerId;
  final String? referredEmail;
  final String? referredUserId;
  final String? inviteCode;
  final String? channel;
  final String status; // sent | accepted | active
  final DateTime createdAt;
  final DateTime? acceptedAt;

  // Joined from profiles!referrals_referrer_id_fkey(full_name)
  final String? referrerName;

  const Referral({
    required this.id,
    required this.referrerId,
    this.referredEmail,
    this.referredUserId,
    this.inviteCode,
    this.channel,
    this.status = 'sent',
    required this.createdAt,
    this.acceptedAt,
    this.referrerName,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return Referral(
      id: json['id'] as String,
      referrerId: json['referrer_id'] as String,
      referredEmail: json['referred_email'] as String?,
      referredUserId: json['referred_user_id'] as String?,
      inviteCode: json['invite_code'] as String?,
      channel: json['channel'] as String?,
      status: json['status'] as String? ?? 'sent',
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      referrerName: profile?['full_name'] as String?,
    );
  }
}
