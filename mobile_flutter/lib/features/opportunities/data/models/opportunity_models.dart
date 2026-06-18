import 'package:flutter/material.dart';

/// The seven opportunity types. [key] matches the DB CHECK constraint.
enum OpportunityType {
  scholarship('scholarship', 'Scholarships', Icons.school_rounded),
  internship('internship', 'Internships', Icons.work_outline_rounded),
  competition('competition', 'Competitions', Icons.emoji_events_rounded),
  conference('conference', 'Conferences', Icons.groups_rounded),
  fellowship('fellowship', 'Fellowships', Icons.workspace_premium_rounded),
  exchange('exchange', 'Exchange Programs', Icons.flight_takeoff_rounded),
  campus('campus', 'Campus', Icons.location_city_rounded);

  const OpportunityType(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;

  static OpportunityType fromKey(String key) => OpportunityType.values
      .firstWhere((t) => t.key == key, orElse: () => OpportunityType.scholarship);

  Color get color {
    switch (this) {
      case OpportunityType.scholarship:
        return const Color(0xFF7C3AED);
      case OpportunityType.internship:
        return const Color(0xFF0066FF);
      case OpportunityType.competition:
        return const Color(0xFFD97706);
      case OpportunityType.conference:
        return const Color(0xFF0891B2);
      case OpportunityType.fellowship:
        return const Color(0xFFDB2777);
      case OpportunityType.exchange:
        return const Color(0xFF0F766E);
      case OpportunityType.campus:
        return const Color(0xFF2563EB);
    }
  }
}

/// Where a student is in their journey with an opportunity.
enum ApplicationStage {
  saved('saved', 'Saved'),
  preparing('preparing', 'Preparing'),
  applied('applied', 'Applied'),
  interview('interview', 'Interview'),
  accepted('accepted', 'Accepted'),
  rejected('rejected', 'Rejected'),
  withdrawn('withdrawn', 'Withdrawn');

  const ApplicationStage(this.key, this.label);
  final String key;
  final String label;

  static ApplicationStage fromKey(String? key) => ApplicationStage.values
      .firstWhere((s) => s.key == key, orElse: () => ApplicationStage.saved);

  Color get color {
    switch (this) {
      case ApplicationStage.saved:
        return const Color(0xFF6B7280);
      case ApplicationStage.preparing:
        return const Color(0xFFD97706);
      case ApplicationStage.applied:
        return const Color(0xFF0066FF);
      case ApplicationStage.interview:
        return const Color(0xFF7C3AED);
      case ApplicationStage.accepted:
        return const Color(0xFF10B981);
      case ApplicationStage.rejected:
        return const Color(0xFFEF4444);
      case ApplicationStage.withdrawn:
        return const Color(0xFF9CA3AF);
    }
  }
}

/// A single opportunity listing.
class OpportunityModel {
  final String id;
  final OpportunityType type;
  final String title;
  final String? organization;
  final String? description;
  final String? summary;
  final String? coverUrl;
  final String? location;
  final bool isRemote;
  final String? country;
  final String? funding;
  final bool isFunded;
  final String? eligibility;
  final List<String> fields;
  final List<String> levels;
  final List<String> tags;
  final String? applicationUrl;
  final DateTime? deadline;
  final DateTime? startsAt;
  final String? universityId;
  final bool isVerified;
  final bool isFeatured;
  final String status;
  final int viewCount;
  final int saveCount;
  final int applicationCount;
  final DateTime createdAt;

  // Per-viewer derived state
  final bool isSaved;
  final ApplicationStage? stage;

  const OpportunityModel({
    required this.id,
    required this.type,
    required this.title,
    this.organization,
    this.description,
    this.summary,
    this.coverUrl,
    this.location,
    this.isRemote = false,
    this.country,
    this.funding,
    this.isFunded = false,
    this.eligibility,
    this.fields = const [],
    this.levels = const [],
    this.tags = const [],
    this.applicationUrl,
    this.deadline,
    this.startsAt,
    this.universityId,
    this.isVerified = false,
    this.isFeatured = false,
    this.status = 'published',
    this.viewCount = 0,
    this.saveCount = 0,
    this.applicationCount = 0,
    required this.createdAt,
    this.isSaved = false,
    this.stage,
  });

  factory OpportunityModel.fromJson(
    Map<String, dynamic> json, {
    Set<String> savedIds = const {},
    Map<String, String> stages = const {},
  }) {
    List<String> arr(dynamic v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? const [];
    DateTime? dt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v as String)?.toLocal();
    final id = json['id'] as String;
    return OpportunityModel(
      id: id,
      type: OpportunityType.fromKey(json['type'] as String? ?? 'scholarship'),
      title: json['title'] as String? ?? '',
      organization: json['organization'] as String?,
      description: json['description'] as String?,
      summary: json['summary'] as String?,
      coverUrl: json['cover_url'] as String?,
      location: json['location'] as String?,
      isRemote: json['is_remote'] as bool? ?? false,
      country: json['country'] as String?,
      funding: json['funding'] as String?,
      isFunded: json['is_funded'] as bool? ?? false,
      eligibility: json['eligibility'] as String?,
      fields: arr(json['fields']),
      levels: arr(json['levels']),
      tags: arr(json['tags']),
      applicationUrl: json['application_url'] as String?,
      deadline: dt(json['deadline']),
      startsAt: dt(json['starts_at']),
      universityId: json['university_id'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      status: json['status'] as String? ?? 'published',
      viewCount: json['view_count'] as int? ?? 0,
      saveCount: json['save_count'] as int? ?? 0,
      applicationCount: json['application_count'] as int? ?? 0,
      createdAt: dt(json['created_at']) ?? DateTime.now(),
      isSaved: savedIds.contains(id) || (json['is_saved'] as bool? ?? false),
      stage: stages.containsKey(id)
          ? ApplicationStage.fromKey(stages[id])
          : (json['stage'] != null
              ? ApplicationStage.fromKey(json['stage'] as String)
              : null),
    );
  }

  /// Serialisable map for the Hive offline cache.
  Map<String, dynamic> toCache() => {
        'id': id,
        'type': type.key,
        'title': title,
        'organization': organization,
        'description': description,
        'summary': summary,
        'cover_url': coverUrl,
        'location': location,
        'is_remote': isRemote,
        'country': country,
        'funding': funding,
        'is_funded': isFunded,
        'eligibility': eligibility,
        'fields': fields,
        'levels': levels,
        'tags': tags,
        'application_url': applicationUrl,
        'deadline': deadline?.toIso8601String(),
        'starts_at': startsAt?.toIso8601String(),
        'university_id': universityId,
        'is_verified': isVerified,
        'is_featured': isFeatured,
        'status': status,
        'view_count': viewCount,
        'save_count': saveCount,
        'application_count': applicationCount,
        'created_at': createdAt.toIso8601String(),
        'is_saved': isSaved,
        'stage': stage?.key,
      };

  // ── Deadline helpers ───────────────────────────────────────

  bool get isRolling => deadline == null;
  bool get isExpired => deadline != null && DateTime.now().isAfter(deadline!);

  int? get daysLeft {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inHours ~/ 24;
  }

  /// Human deadline label e.g. "3 days left", "Closes today", "Rolling".
  String get deadlineLabel {
    if (deadline == null) return 'Rolling';
    final d = daysLeft!;
    if (d < 0) return 'Closed';
    if (d == 0) return 'Closes today';
    if (d == 1) return '1 day left';
    if (d <= 14) return '$d days left';
    return 'Due ${_fmt(deadline!)}';
  }

  bool get isClosingSoon {
    final d = daysLeft;
    return d != null && d >= 0 && d <= 7;
  }

  static String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]}';
  }

  OpportunityModel copyWith({bool? isSaved, ApplicationStage? stage}) =>
      OpportunityModel(
        id: id,
        type: type,
        title: title,
        organization: organization,
        description: description,
        summary: summary,
        coverUrl: coverUrl,
        location: location,
        isRemote: isRemote,
        country: country,
        funding: funding,
        isFunded: isFunded,
        eligibility: eligibility,
        fields: fields,
        levels: levels,
        tags: tags,
        applicationUrl: applicationUrl,
        deadline: deadline,
        startsAt: startsAt,
        universityId: universityId,
        isVerified: isVerified,
        isFeatured: isFeatured,
        status: status,
        viewCount: viewCount,
        saveCount: saveCount,
        applicationCount: applicationCount,
        createdAt: createdAt,
        isSaved: isSaved ?? this.isSaved,
        stage: stage ?? this.stage,
      );
}

/// A tracked application (joins the opportunity for the tracker board).
class TrackedApplication {
  final String id;
  final String opportunityId;
  final ApplicationStage stage;
  final String? notes;
  final DateTime? appliedAt;
  final DateTime updatedAt;
  final OpportunityModel? opportunity;

  const TrackedApplication({
    required this.id,
    required this.opportunityId,
    required this.stage,
    this.notes,
    this.appliedAt,
    required this.updatedAt,
    this.opportunity,
  });

  factory TrackedApplication.fromJson(Map<String, dynamic> json) {
    final opp = json['opportunities'] as Map<String, dynamic>?;
    return TrackedApplication(
      id: json['id'] as String,
      opportunityId: json['opportunity_id'] as String,
      stage: ApplicationStage.fromKey(json['stage'] as String?),
      notes: json['notes'] as String?,
      appliedAt: json['applied_at'] != null
          ? DateTime.tryParse(json['applied_at'] as String)
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      opportunity: opp != null ? OpportunityModel.fromJson(opp) : null,
    );
  }
}

/// Filters for browsing / searching opportunities.
class OpportunityFilter {
  final OpportunityType? type;
  final String? query;
  final bool fundedOnly;
  final bool remoteOnly;
  final bool verifiedOnly;
  final String? field;
  final String sort; // recent | deadline | popular

  const OpportunityFilter({
    this.type,
    this.query,
    this.fundedOnly = false,
    this.remoteOnly = false,
    this.verifiedOnly = false,
    this.field,
    this.sort = 'recent',
  });

  OpportunityFilter copyWith({
    OpportunityType? type,
    String? query,
    bool? fundedOnly,
    bool? remoteOnly,
    bool? verifiedOnly,
    String? field,
    String? sort,
    bool clearType = false,
    bool clearField = false,
  }) {
    return OpportunityFilter(
      type: clearType ? null : (type ?? this.type),
      query: query ?? this.query,
      fundedOnly: fundedOnly ?? this.fundedOnly,
      remoteOnly: remoteOnly ?? this.remoteOnly,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      field: clearField ? null : (field ?? this.field),
      sort: sort ?? this.sort,
    );
  }
}

/// Aggregate stats for the admin dashboard.
class OpportunityStats {
  final int published;
  final int closingSoon;
  final int pendingReports;
  final Map<String, int> typeCounts;
  final Map<String, int> topSearches;

  const OpportunityStats({
    this.published = 0,
    this.closingSoon = 0,
    this.pendingReports = 0,
    this.typeCounts = const {},
    this.topSearches = const {},
  });
}

/// A row in the admin moderation queue.
class OpportunityReportItem {
  final String id;
  final String reason;
  final DateTime createdAt;
  final String? opportunityId;
  final String? opportunityTitle;
  final String? reporterName;

  const OpportunityReportItem({
    required this.id,
    required this.reason,
    required this.createdAt,
    this.opportunityId,
    this.opportunityTitle,
    this.reporterName,
  });

  factory OpportunityReportItem.fromJson(Map<String, dynamic> json) {
    final o = json['opportunities'] as Map<String, dynamic>?;
    final p = json['profiles'] as Map<String, dynamic>?;
    return OpportunityReportItem(
      id: json['id'] as String,
      reason: json['reason'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      opportunityId: o?['id'] as String?,
      opportunityTitle: o?['title'] as String?,
      reporterName: p?['full_name'] as String?,
    );
  }
}
