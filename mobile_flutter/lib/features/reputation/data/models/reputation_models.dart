// ── Reputation Score ──────────────────────────────────────────

class ReputationScore {
  final String userId;
  final int score;
  final String level;
  final DateTime updatedAt;

  const ReputationScore({
    required this.userId,
    this.score = 0,
    this.level = 'beginner',
    required this.updatedAt,
  });

  String get levelLabel {
    switch (level) {
      case 'beginner': return 'Beginner';
      case 'bronze': return 'Bronze';
      case 'silver': return 'Silver';
      case 'gold': return 'Gold';
      case 'platinum': return 'Platinum';
      case 'diamond': return 'Diamond';
      default: return level;
    }
  }

  double get levelProgress {
    if (level == 'diamond') return 1.0;
    final levels = ['beginner', 'bronze', 'silver', 'gold', 'platinum', 'diamond'];
    final currentIndex = levels.indexOf(level);
    if (currentIndex < 0 || currentIndex >= levels.length - 1) return 0.0;
    final rangeStart = _levelThreshold(levels[currentIndex]);
    final rangeEnd = _levelThreshold(levels[currentIndex + 1]);
    return (score - rangeStart) / (rangeEnd - rangeStart);
  }

  static int _levelThreshold(String level) {
    switch (level) {
      case 'beginner': return 0;
      case 'bronze': return 50;
      case 'silver': return 200;
      case 'gold': return 500;
      case 'platinum': return 1000;
      case 'diamond': return 2500;
      default: return 0;
    }
  }

  factory ReputationScore.fromJson(Map<String, dynamic> json) {
    return ReputationScore(
      userId: json['user_id'] as String,
      score: json['score'] as int? ?? 0,
      level: json['level'] as String? ?? 'beginner',
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId, 'score': score, 'level': level, 'updated_at': updatedAt.toIso8601String(),
  };
}

// ── Achievement Definition ────────────────────────────────────

class AchievementDefinition {
  final String id;
  final String slug;
  final String title;
  final String? description;
  final String? iconUrl;
  final String category;
  final Map<String, dynamic>? criteria;
  final int points;
  final bool isSystem;

  const AchievementDefinition({
    required this.id, required this.slug, required this.title,
    this.description, this.iconUrl, this.category = 'general',
    this.criteria, this.points = 0, this.isSystem = true,
  });

  String get categoryLabel {
    switch (category) {
      case 'general': return 'General';
      case 'community': return 'Community';
      case 'academic': return 'Academic';
      case 'leadership': return 'Leadership';
      case 'event': return 'Event';
      case 'marketplace': return 'Marketplace';
      default: return category;
    }
  }

  factory AchievementDefinition.fromJson(Map<String, dynamic> json) {
    return AchievementDefinition(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      category: json['category'] as String? ?? 'general',
      criteria: json['criteria'] as Map<String, dynamic>?,
      points: json['points'] as int? ?? 0,
      isSystem: json['is_system'] as bool? ?? true,
    );
  }
}

// ── User Achievement ──────────────────────────────────────────

class UserAchievement {
  final String userId;
  final AchievementDefinition achievement;
  final DateTime unlockedAt;
  final bool notificationSent;

  const UserAchievement({
    required this.userId, required this.achievement,
    required this.unlockedAt, this.notificationSent = false,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      userId: json['user_id'] as String,
      achievement: AchievementDefinition.fromJson(json['achievement'] as Map<String, dynamic>),
      unlockedAt: DateTime.parse(json['unlocked_at'] as String),
      notificationSent: json['notification_sent'] as bool? ?? false,
    );
  }
}

// ── User Skill ────────────────────────────────────────────────

class UserSkill {
  final String id;
  final String userId;
  final String skillName;
  final String proficiencyLevel;
  final DateTime createdAt;
  final int endorsementCount;

  const UserSkill({
    required this.id, required this.userId, required this.skillName,
    this.proficiencyLevel = 'beginner', required this.createdAt,
    this.endorsementCount = 0,
  });

  String get proficiencyLabel {
    switch (proficiencyLevel) {
      case 'beginner': return 'Beginner';
      case 'intermediate': return 'Intermediate';
      case 'advanced': return 'Advanced';
      case 'expert': return 'Expert';
      default: return proficiencyLevel;
    }
  }

  double get proficiencyFraction {
    switch (proficiencyLevel) {
      case 'beginner': return 0.25;
      case 'intermediate': return 0.5;
      case 'advanced': return 0.75;
      case 'expert': return 1.0;
      default: return 0.25;
    }
  }

  factory UserSkill.fromJson(Map<String, dynamic> json) {
    return UserSkill(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      skillName: json['skill_name'] as String,
      proficiencyLevel: json['proficiency_level'] as String? ?? 'beginner',
      createdAt: DateTime.parse(json['created_at'] as String),
      endorsementCount: json['endorsement_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId, 'skill_name': skillName, 'proficiency_level': proficiencyLevel,
  };
}

// ── Skill Endorsement ─────────────────────────────────────────

class SkillEndorsement {
  final String id;
  final String skillId;
  final String endorsedBy;
  final String? message;
  final DateTime createdAt;
  final String? endorserName;
  final String? endorserAvatar;

  const SkillEndorsement({
    required this.id, required this.skillId, required this.endorsedBy,
    this.message, required this.createdAt, this.endorserName, this.endorserAvatar,
  });

  factory SkillEndorsement.fromJson(Map<String, dynamic> json) {
    return SkillEndorsement(
      id: json['id'] as String,
      skillId: json['skill_id'] as String,
      endorsedBy: json['endorsed_by'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      endorserName: json['endorser_name'] as String?,
      endorserAvatar: json['endorser_avatar'] as String?,
    );
  }
}

// ── Contribution ──────────────────────────────────────────────

class Contribution {
  final String id;
  final String userId;
  final String contributionType;
  final String? referenceType;
  final String? referenceId;
  final String? label;
  final DateTime createdAt;

  const Contribution({
    required this.id, required this.userId, required this.contributionType,
    this.referenceType, this.referenceId, this.label, required this.createdAt,
  });

  String get typeLabel {
    switch (contributionType) {
      case 'post': return 'Post';
      case 'resource': return 'Resource';
      case 'event': return 'Event';
      case 'comment': return 'Comment';
      case 'marketplace': return 'Marketplace';
      case 'volunteer': return 'Volunteer';
      default: return contributionType;
    }
  }

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      contributionType: json['contribution_type'] as String,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      label: json['label'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// ── Portfolio Project ─────────────────────────────────────────

class PortfolioProject {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? url;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final DateTime createdAt;

  const PortfolioProject({
    required this.id, required this.userId, required this.title,
    this.description, this.url, this.startDate, this.endDate,
    this.isCurrent = false, required this.createdAt,
  });

  factory PortfolioProject.fromJson(Map<String, dynamic> json) {
    return PortfolioProject(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      url: json['url'] as String?,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      isCurrent: json['is_current'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'user_id': userId, 'title': title, 'description': description,
    'url': url, 'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(), 'is_current': isCurrent,
  };
}

// ── Leadership History ────────────────────────────────────────

class LeadershipHistory {
  final String id;
  final String userId;
  final String position;
  final String organization;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String? description;
  final DateTime createdAt;

  const LeadershipHistory({
    required this.id, required this.userId, required this.position,
    required this.organization, this.startDate, this.endDate,
    this.isCurrent = false, this.description, required this.createdAt,
  });

  factory LeadershipHistory.fromJson(Map<String, dynamic> json) {
    return LeadershipHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      position: json['position'] as String,
      organization: json['organization'] as String,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      isCurrent: json['is_current'] as bool? ?? false,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'user_id': userId, 'position': position, 'organization': organization,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(), 'is_current': isCurrent, 'description': description,
  };
}

// ── User Certificate ──────────────────────────────────────────

class UserCertificate {
  final String id;
  final String userId;
  final String title;
  final String issuer;
  final String certificateType;
  final String? url;
  final DateTime? issuedAt;
  final DateTime createdAt;

  const UserCertificate({
    required this.id, required this.userId, required this.title,
    required this.issuer, required this.certificateType,
    this.url, this.issuedAt, required this.createdAt,
  });

  String get typeLabel {
    switch (certificateType) {
      case 'workshop': return 'Workshop';
      case 'competition': return 'Competition';
      case 'event': return 'Event';
      case 'leadership': return 'Leadership';
      case 'training': return 'Training';
      default: return certificateType;
    }
  }

  factory UserCertificate.fromJson(Map<String, dynamic> json) {
    return UserCertificate(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      issuer: json['issuer'] as String,
      certificateType: json['certificate_type'] as String,
      url: json['url'] as String?,
      issuedAt: json['issued_at'] != null ? DateTime.parse(json['issued_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'user_id': userId, 'title': title, 'issuer': issuer,
    'certificate_type': certificateType, 'url': url, 'issued_at': issuedAt?.toIso8601String(),
  };
}

// ── Reputation Event (points log entry) ───────────────────────

class ReputationEvent {
  final String id;
  final String userId;
  final String eventType;
  final int points;
  final String? referenceType;
  final String? referenceId;
  final String? description;
  final DateTime createdAt;

  const ReputationEvent({
    required this.id, required this.userId, required this.eventType,
    required this.points, this.referenceType, this.referenceId,
    this.description, required this.createdAt,
  });

  String get eventLabel {
    switch (eventType) {
      case 'post_created': return 'Created a post';
      case 'comment_upvoted': return 'Helpful comment';
      case 'event_attended': return 'Attended event';
      case 'resource_uploaded': return 'Uploaded resource';
      case 'best_answer': return 'Best answer';
      case 'leadership_role': return 'Leadership role';
      default: return eventType;
    }
  }

  factory ReputationEvent.fromJson(Map<String, dynamic> json) {
    return ReputationEvent(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventType: json['event_type'] as String,
      points: json['points'] as int,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// ── Reputation Summary (dashboard data) ───────────────────────

class ReputationSummary {
  final ReputationScore score;
  final List<UserAchievement> achievements;
  final List<UserSkill> skills;
  final int totalContributions;
  final Map<String, int> contributionsByType;
  final int endorsementCount;
  final int certificateCount;
  final int leadershipCount;

  const ReputationSummary({
    required this.score, required this.achievements, required this.skills,
    this.totalContributions = 0, this.contributionsByType = const {},
    this.endorsementCount = 0, this.certificateCount = 0, this.leadershipCount = 0,
  });
}
