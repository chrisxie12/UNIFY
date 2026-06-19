/// In-app notification from the notifications table.
/// Also holds static helpers for type display, icons, and routing.
class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String? body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      data: json['data'] != null ? Map<String, dynamic>.from(json['data'] as Map) : null,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  NotificationModel copyWith({bool? isRead}) =>
      NotificationModel(
        id: id,
        userId: userId,
        type: type,
        title: title,
        body: body,
        data: data,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  // ── Type helpers ──────────────────────────────────────────────────────

  static const Map<String, String> typeLabels = {
    'new_message': 'New Message',
    'community_announcement': 'Community Announcement',
    'community_join_request': 'Join Request',
    'community_approval': 'Community Approved',
    'marketplace_inquiry': 'Marketplace Inquiry',
    'marketplace_sale': 'Item Sold',
    'event_registration': 'Event Registration',
    'event_reminder': 'Event Reminder',
    'event_checkin_confirmation': 'Checked In',
    'opportunity_deadline_reminder': 'Deadline Reminder',
    'scholarship_alert': 'Scholarship Alert',
    'academic_resource_upload': 'New Resource',
    'verification_approved': 'Verification Approved',
    'role_assigned': 'Role Assigned',
    'admin_broadcast': 'Announcement',
  };

  static const Map<String, String> typeIcons = {
    'new_message': 'chat_bubble',
    'community_announcement': 'campaign',
    'community_join_request': 'group_add',
    'community_approval': 'check_circle',
    'marketplace_inquiry': 'question_answer',
    'marketplace_sale': 'sell',
    'event_registration': 'event',
    'event_reminder': 'alarm',
    'event_checkin_confirmation': 'qr_code_scanner',
    'opportunity_deadline_reminder': 'timer',
    'scholarship_alert': 'school',
    'academic_resource_upload': 'upload_file',
    'verification_approved': 'verified',
    'role_assigned': 'badge',
    'admin_broadcast': 'campaign',
  };
}

/// User notification preferences — maps to notification_preferences table.
class NotificationPreferences {
  final String id;
  final String userId;
  final bool messages;
  final bool communities;
  final bool marketplace;
  final bool events;
  final bool opportunities;
  final bool academicResources;
  final bool adminNotices;
  final bool pushEnabled;
  final bool emailEnabled;

  const NotificationPreferences({
    required this.id,
    required this.userId,
    required this.messages,
    required this.communities,
    required this.marketplace,
    required this.events,
    required this.opportunities,
    required this.academicResources,
    required this.adminNotices,
    required this.pushEnabled,
    required this.emailEnabled,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      messages: json['messages'] as bool? ?? true,
      communities: json['communities'] as bool? ?? true,
      marketplace: json['marketplace'] as bool? ?? true,
      events: json['events'] as bool? ?? true,
      opportunities: json['opportunities'] as bool? ?? true,
      academicResources: json['academic_resources'] as bool? ?? true,
      adminNotices: json['admin_notices'] as bool? ?? true,
      pushEnabled: json['push_enabled'] as bool? ?? true,
      emailEnabled: json['email_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'messages': messages,
    'communities': communities,
    'marketplace': marketplace,
    'events': events,
    'opportunities': opportunities,
    'academic_resources': academicResources,
    'admin_notices': adminNotices,
    'push_enabled': pushEnabled,
    'email_enabled': emailEnabled,
  };
}

/// Analytics entry for a notification delivery/engagement event.
class NotificationLog {
  final String id;
  final String? notificationId;
  final String userId;
  final String type;
  final String channel;
  final String status;
  final String? deviceToken;
  final String? errorMessage;
  final DateTime? openedAt;
  final DateTime? clickedAt;
  final DateTime createdAt;

  const NotificationLog({
    required this.id,
    this.notificationId,
    required this.userId,
    required this.type,
    required this.channel,
    required this.status,
    this.deviceToken,
    this.errorMessage,
    this.openedAt,
    this.clickedAt,
    required this.createdAt,
  });

  factory NotificationLog.fromJson(Map<String, dynamic> json) {
    return NotificationLog(
      id: json['id'] as String,
      notificationId: json['notification_id'] as String?,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      channel: json['channel'] as String,
      status: json['status'] as String,
      deviceToken: json['device_token'] as String?,
      errorMessage: json['error_message'] as String?,
      openedAt: json['opened_at'] != null ? DateTime.parse(json['opened_at'] as String) : null,
      clickedAt: json['clicked_at'] != null ? DateTime.parse(json['clicked_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
