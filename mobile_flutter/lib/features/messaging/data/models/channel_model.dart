class ChannelModel {
  final String id;
  final String conversationId;
  final String name;
  final String? description;
  final String type;
  final String? createdBy;
  final int position;
  final DateTime createdAt;
  final int unreadCount;

  ChannelModel({
    required this.id,
    required this.conversationId,
    required this.name,
    this.description,
    this.type = 'text',
    this.createdBy,
    this.position = 0,
    required this.createdAt,
    this.unreadCount = 0,
  });

  bool get isAnnouncement => type == 'announcement';
  bool get isVoice => type == 'voice';

  factory ChannelModel.fromMap(Map<String, dynamic> map) {
    return ChannelModel(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      type: map['type'] as String? ?? 'text',
      createdBy: map['created_by'] as String?,
      position: map['position'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      unreadCount: map['unread_count'] as int? ?? 0,
    );
  }

  String get displayName => '#$name';
}
