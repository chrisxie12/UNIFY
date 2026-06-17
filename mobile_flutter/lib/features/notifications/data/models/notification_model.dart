class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String? body;
  final String? referenceId;
  final String? referenceType;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body,
    this.referenceId,
    this.referenceType,
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
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      referenceId: referenceId,
      referenceType: referenceType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  static const Map<String, String> typeLabels = {
    'community_approved': 'Community Approved',
    'community_rejected': 'Community Rejected',
    'community_changes_requested': 'More Information Needed',
    'admin_new_request': 'New Community Request',
    'announcement_posted': 'New Announcement',
    'discussion_reply': 'New Reply',
    'discussion_mention': 'Mentioned in Discussion',
    'resource_uploaded': 'Resource Uploaded',
    'verification_approved': 'Verification Approved',
    'verification_rejected': 'Verification Rejected',
    'moderator_action': 'Moderator Action',
    'report_update': 'Report Update',
    'community_invite': 'Community Invite',
    'announcement_request_approved': 'Announcement Approved',
    'announcement_request_rejected': 'Announcement Rejected',
    'new_follower': 'New Follower',
  };

  static const Map<String, String> typeIcons = {
    'community_approved': 'check_circle',
    'community_rejected': 'cancel',
    'community_changes_requested': 'feedback',
    'admin_new_request': 'group_add',
    'announcement_posted': 'campaign',
    'discussion_reply': 'reply',
    'resource_uploaded': 'upload_file',
    'verification_approved': 'verified',
    'verification_rejected': 'gpp_bad',
    'moderator_action': 'shield',
    'report_update': 'flag',
    'community_invite': 'group_add',
    'new_follower': 'person_add',
  };
}
