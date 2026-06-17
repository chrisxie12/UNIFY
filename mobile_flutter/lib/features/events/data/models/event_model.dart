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
  final String? coverUrl;
  final String eventType;
  final int rsvpCount;
  final int? maxAttendees;
  final bool isVirtual;
  final String? meetingLink;
  final String? myRsvpStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    this.coverUrl,
    required this.eventType,
    this.rsvpCount = 0,
    this.maxAttendees,
    this.isVirtual = false,
    this.meetingLink,
    this.myRsvpStatus,
    required this.createdAt,
    required this.updatedAt,
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

  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[eventDate.month - 1]} ${eventDate.day}, ${eventDate.year}';
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
      coverUrl: json['cover_url'] as String?,
      eventType: json['event_type'] as String,
      rsvpCount: json['rsvp_count'] as int? ?? 0,
      maxAttendees: json['max_attendees'] as int?,
      isVirtual: json['is_virtual'] as bool? ?? false,
      meetingLink: json['meeting_link'] as String?,
      myRsvpStatus: json['my_rsvp_status'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'cover_url': coverUrl,
      'event_type': eventType,
      'rsvp_count': rsvpCount,
      'max_attendees': maxAttendees,
      'is_virtual': isVirtual,
      'meeting_link': meetingLink,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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
    };
  }
}
