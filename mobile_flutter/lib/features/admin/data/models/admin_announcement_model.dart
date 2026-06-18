class AdminAnnouncementModel {
  final String id;
  final String senderId;
  final String title;
  final String body;
  final String scopeType;
  final String? scopeId;
  final String priority;
  final bool sendPush;
  final bool sendEmail;
  final DateTime createdAt;
  final String? senderName;

  const AdminAnnouncementModel({
    required this.id,
    required this.senderId,
    required this.title,
    required this.body,
    required this.scopeType,
    this.scopeId,
    this.priority = 'normal',
    this.sendPush = false,
    this.sendEmail = false,
    required this.createdAt,
    this.senderName,
  });

  factory AdminAnnouncementModel.fromJson(Map<String, dynamic> json) {
    final profileData = json['profiles'] as Map<String, dynamic>?;
    return AdminAnnouncementModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      scopeType: json['scope_type'] as String,
      scopeId: json['scope_id'] as String?,
      priority: json['priority'] as String? ?? 'normal',
      sendPush: json['send_push'] as bool? ?? false,
      sendEmail: json['send_email'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderName: profileData?['full_name'] as String?,
    );
  }

  String get scopeLabel {
    switch (scopeType) {
      case 'university': return 'University';
      case 'faculty': return 'Faculty';
      case 'department': return 'Department';
      case 'community': return 'Community';
      case 'all': return 'All Users';
      default: return scopeType;
    }
  }
}
