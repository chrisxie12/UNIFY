class EventModel {
  final String id;
  final String communityId;
  final String creatorId;
  final String? creatorName;
  final String? creatorAvatar;
  final String title;
  final String? description;
  final String? location;
  final DateTime eventDate;
  final String? eventTime;
  final DateTime? endDate;
  final String? endTime;
  final String? coverUrl;
  final String eventType;
  final int rsvpCount;
  final int? maxAttendees;
  final bool isVirtual;
  final String? meetingLink;
  final String? myRsvpStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  // New step14 fields
  final String category;
  final int? capacity;
  final String registrationType;
  final String? ticketType;
  final String? contactInfo;
  final String scope;
  final String? university;
  final String? faculty;
  final String? department;
  final String? organizerType;
  final int attendeeCount;
  final bool isFeatured;
  final bool isApproved;
  final bool isCancelled;
  final bool isSaved;
  final String? myTicketId;
  final String? myTicketQrCode;
  final bool myAttendanceStatus;

  const EventModel({
    required this.id,
    required this.communityId,
    required this.creatorId,
    this.creatorName,
    this.creatorAvatar,
    required this.title,
    this.description,
    this.location,
    required this.eventDate,
    this.eventTime,
    this.endDate,
    this.endTime,
    this.coverUrl,
    required this.eventType,
    this.rsvpCount = 0,
    this.maxAttendees,
    this.isVirtual = false,
    this.meetingLink,
    this.myRsvpStatus,
    required this.createdAt,
    required this.updatedAt,
    this.category = 'community_activities',
    this.capacity,
    this.registrationType = 'free',
    this.ticketType,
    this.contactInfo,
    this.scope = 'community',
    this.university,
    this.faculty,
    this.department,
    this.organizerType,
    this.attendeeCount = 0,
    this.isFeatured = false,
    this.isApproved = false,
    this.isCancelled = false,
    this.isSaved = false,
    this.myTicketId,
    this.myTicketQrCode,
    this.myAttendanceStatus = false,
  });

  String get eventTypeLabel {
    switch (eventType) {
      case 'class': return 'Class';
      case 'study_session': return 'Study Session';
      case 'workshop': return 'Workshop';
      case 'hackathon': return 'Hackathon';
      case 'orientation': return 'Orientation';
      case 'meeting': return 'Meeting';
      case 'social': return 'Social';
      case 'other': return 'Other';
      default: return eventType;
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'academic': return 'Academic';
      case 'career': return 'Career';
      case 'technology': return 'Technology';
      case 'entertainment': return 'Entertainment';
      case 'sports': return 'Sports';
      case 'religious': return 'Religious';
      case 'club_activities': return 'Club Activities';
      case 'community_activities': return 'Community Activities';
      case 'workshops': return 'Workshops';
      case 'seminars': return 'Seminar';
      case 'conferences': return 'Conference';
      default: return category;
    }
  }

  String get scopeLabel {
    switch (scope) {
      case 'community': return 'Community';
      case 'faculty': return 'Faculty';
      case 'university': return 'University';
      case 'campus': return 'Campus';
      default: return scope;
    }
  }

  String get registrationTypeLabel {
    switch (registrationType) {
      case 'free': return 'Free';
      case 'paid': return 'Paid';
      default: return registrationType;
    }
  }

  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[eventDate.month - 1]} ${eventDate.day}, ${eventDate.year}';
  }

  String get formattedDateShort {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[eventDate.month - 1]} ${eventDate.day}';
  }

  String get formattedTime {
    if (eventTime != null && eventTime!.isNotEmpty) {
      final parts = eventTime!.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 12;
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:$minute $period';
      }
    }
    final hour = eventDate.hour;
    final minute = eventDate.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }

  String get formattedEndTime {
    if (endTime != null && endTime!.isNotEmpty) {
      final parts = endTime!.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 12;
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:$minute $period';
      }
    }
    return '';
  }

  bool get isPast => eventDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));
  bool get isFull => capacity != null && attendeeCount >= capacity!;
  bool get needsApproval => !isApproved && scope != 'community';

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      creatorId: json['creator_id'] as String,
      creatorName: json['creator_name'] as String? ?? json['display_name'] as String?,
      creatorAvatar: json['creator_avatar'] as String? ?? json['avatar_url'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      eventTime: json['event_time'] as String?,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      endTime: json['end_time'] as String?,
      coverUrl: json['cover_url'] as String?,
      eventType: json['event_type'] as String,
      rsvpCount: json['rsvp_count'] as int? ?? 0,
      maxAttendees: json['max_attendees'] as int?,
      isVirtual: json['is_virtual'] as bool? ?? false,
      meetingLink: json['meeting_link'] as String?,
      myRsvpStatus: json['my_rsvp_status'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: json['category'] as String? ?? 'community_activities',
      capacity: json['capacity'] as int?,
      registrationType: json['registration_type'] as String? ?? 'free',
      ticketType: json['ticket_type'] as String?,
      contactInfo: json['contact_info'] as String?,
      scope: json['scope'] as String? ?? 'community',
      university: json['university'] as String?,
      faculty: json['faculty'] as String?,
      department: json['department'] as String?,
      organizerType: json['organizer_type'] as String?,
      attendeeCount: json['attendee_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isApproved: json['is_approved'] as bool? ?? false,
      isCancelled: json['is_cancelled'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
      myTicketId: json['my_ticket_id'] as String?,
      myTicketQrCode: json['my_ticket_qr'] as String?,
      myAttendanceStatus: json['my_attendance_status'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'community_id': communityId,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'location': location,
      'event_date': eventDate.toIso8601String(),
      'event_time': eventTime,
      'end_date': endDate?.toIso8601String(),
      'end_time': endTime,
      'cover_url': coverUrl,
      'event_type': eventType,
      'rsvp_count': rsvpCount,
      'max_attendees': maxAttendees,
      'is_virtual': isVirtual,
      'meeting_link': meetingLink,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category': category,
      'capacity': capacity,
      'registration_type': registrationType,
      'ticket_type': ticketType,
      'contact_info': contactInfo,
      'scope': scope,
      'university': university,
      'faculty': faculty,
      'department': department,
      'organizer_type': organizerType,
      'attendee_count': attendeeCount,
      'is_featured': isFeatured,
      'is_approved': isApproved,
      'is_cancelled': isCancelled,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'community_id': communityId,
      'creator_id': creatorId,
      'title': title,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      'event_date': eventDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      if (coverUrl != null) 'cover_url': coverUrl,
      'event_type': eventType,
      if (maxAttendees != null) 'max_attendees': maxAttendees,
      if (isVirtual) 'is_virtual': true,
      if (meetingLink != null) 'meeting_link': meetingLink,
      'category': category,
      if (capacity != null) 'capacity': capacity,
      if (ticketType != null) 'ticket_type': ticketType,
      if (contactInfo != null) 'contact_info': contactInfo,
      'scope': scope,
      if (university != null) 'university': university,
      if (faculty != null) 'faculty': faculty,
      if (department != null) 'department': department,
      if (organizerType != null) 'organizer_type': organizerType,
    };
  }
}

// ── Event Ticket ──────────────────────────────────────────────

class EventTicketModel {
  final String id;
  final String ticketNumber;
  final String eventId;
  final String userId;
  final String qrCode;
  final DateTime registrationTimestamp;
  final bool attended;
  final DateTime? checkedInAt;
  final String? checkedInBy;
  final String? eventTitle;
  final String? eventDate;
  final String? eventTime;
  final String? eventVenue;

  const EventTicketModel({
    required this.id,
    required this.ticketNumber,
    required this.eventId,
    required this.userId,
    required this.qrCode,
    required this.registrationTimestamp,
    this.attended = false,
    this.checkedInAt,
    this.checkedInBy,
    this.eventTitle,
    this.eventDate,
    this.eventTime,
    this.eventVenue,
  });

  String get formattedTimestamp {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[registrationTimestamp.month - 1]} ${registrationTimestamp.day}, ${registrationTimestamp.year}';
  }

  factory EventTicketModel.fromJson(Map<String, dynamic> json) {
    return EventTicketModel(
      id: json['id'] as String,
      ticketNumber: json['ticket_number'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      qrCode: json['qr_code'] as String,
      registrationTimestamp: DateTime.parse(json['registration_timestamp'] as String),
      attended: json['attended'] as bool? ?? false,
      checkedInAt: json['checked_in_at'] != null ? DateTime.parse(json['checked_in_at'] as String) : null,
      checkedInBy: json['checked_in_by'] as String?,
      eventTitle: json['event_title'] as String?,
      eventDate: json['event_date'] as String?,
      eventTime: json['event_time'] as String?,
      eventVenue: json['event_venue'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'event_id': eventId,
      'user_id': userId,
      'qr_code': qrCode,
      'registration_timestamp': registrationTimestamp.toIso8601String(),
      'attended': attended,
      'checked_in_at': checkedInAt?.toIso8601String(),
      'checked_in_by': checkedInBy,
    };
  }
}

// ── Event Save (bookmark) ────────────────────────────────────

class EventSave {
  final String userId;
  final String eventId;
  final DateTime savedAt;

  const EventSave({
    required this.userId,
    required this.eventId,
    required this.savedAt,
  });

  factory EventSave.fromJson(Map<String, dynamic> json) {
    return EventSave(
      userId: json['user_id'] as String,
      eventId: json['event_id'] as String,
      savedAt: DateTime.parse(json['saved_at'] as String),
    );
  }
}

// ── Event Discussion ─────────────────────────────────────────

class EventDiscussion {
  final String id;
  final String eventId;
  final String userId;
  final String content;
  final String? parentId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userName;
  final String? userAvatar;
  final List<EventDiscussion>? replies;

  const EventDiscussion({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.content,
    this.parentId,
    required this.createdAt,
    this.updatedAt,
    this.userName,
    this.userAvatar,
    this.replies,
  });

  String get formattedDate {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
  }

  factory EventDiscussion.fromJson(Map<String, dynamic> json) {
    return EventDiscussion(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      parentId: json['parent_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      userName: json['user_name'] as String?,
      userAvatar: json['user_avatar'] as String?,
      replies: json['replies'] != null
          ? (json['replies'] as List).map((r) => EventDiscussion.fromJson(r as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'content': content,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ── Event Media ───────────────────────────────────────────────

class EventMedia {
  final String id;
  final String eventId;
  final String uploadedBy;
  final String mediaType;
  final String url;
  final String? caption;
  final DateTime createdAt;
  final String? uploaderName;

  const EventMedia({
    required this.id,
    required this.eventId,
    required this.uploadedBy,
    required this.mediaType,
    required this.url,
    this.caption,
    required this.createdAt,
    this.uploaderName,
  });

  bool get isPhoto => mediaType == 'photo';
  bool get isVideo => mediaType == 'video';

  factory EventMedia.fromJson(Map<String, dynamic> json) {
    return EventMedia(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      uploadedBy: json['uploaded_by'] as String,
      mediaType: json['media_type'] as String,
      url: json['url'] as String,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      uploaderName: json['uploader_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'uploaded_by': uploadedBy,
      'media_type': mediaType,
      'url': url,
      'caption': caption,
    };
  }
}

// ── Event Reminder ────────────────────────────────────────────

class EventReminder {
  final String id;
  final String eventId;
  final String userId;
  final DateTime remindAt;
  final bool sent;
  final DateTime createdAt;

  const EventReminder({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.remindAt,
    this.sent = false,
    required this.createdAt,
  });

  factory EventReminder.fromJson(Map<String, dynamic> json) {
    return EventReminder(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      remindAt: DateTime.parse(json['remind_at'] as String),
      sent: json['sent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// ── Event Certificate ─────────────────────────────────────────

class EventCertificate {
  final String id;
  final String eventId;
  final String userId;
  final String certificateType;
  final String title;
  final DateTime issuedAt;
  final String? certificateUrl;
  final String? eventTitle;

  const EventCertificate({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.certificateType,
    required this.title,
    required this.issuedAt,
    this.certificateUrl,
    this.eventTitle,
  });

  String get certificateTypeLabel {
    switch (certificateType) {
      case 'participation': return 'Participation';
      case 'workshop': return 'Workshop';
      case 'training': return 'Training';
      default: return certificateType;
    }
  }

  factory EventCertificate.fromJson(Map<String, dynamic> json) {
    return EventCertificate(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      certificateType: json['certificate_type'] as String,
      title: json['title'] as String,
      issuedAt: DateTime.parse(json['issued_at'] as String),
      certificateUrl: json['certificate_url'] as String?,
      eventTitle: json['event_title'] as String?,
    );
  }
}

// ── Attendance Analytics ──────────────────────────────────────

class EventAttendanceAnalytics {
  final int totalRegistrations;
  final int totalCheckIns;
  final double attendanceRate;
  final int noShows;

  const EventAttendanceAnalytics({
    required this.totalRegistrations,
    required this.totalCheckIns,
    required this.attendanceRate,
    required this.noShows,
  });

  factory EventAttendanceAnalytics.fromJson(Map<String, dynamic> json) {
    final reg = json['total_registrations'] as int? ?? 0;
    final checkin = json['total_check_ins'] as int? ?? 0;
    return EventAttendanceAnalytics(
      totalRegistrations: reg,
      totalCheckIns: checkin,
      attendanceRate: reg > 0 ? (checkin / reg) * 100 : 0,
      noShows: reg - checkin,
    );
  }
}
