/// Data model for a single chat list entry.
class ChatItem {
  final String id;
  final String name;
  final String? avatarUrl;
  final String initials;
  final int avatarColorIndex;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isRead;
  final bool isOnline;
  final bool isMuted;
  final bool isPinned;
  final bool isTyping;
  final String? typingUser;
  final bool isForwarded;
  final bool hasMedia;
  final String? mediaType; // 'photo' | 'video' | 'voice'
  final bool hasUnviewedStory;

  const ChatItem({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.initials,
    this.avatarColorIndex = 0,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isRead = false,
    this.isOnline = false,
    this.isMuted = false,
    this.isPinned = false,
    this.isTyping = false,
    this.typingUser,
    this.isForwarded = false,
    this.hasMedia = false,
    this.mediaType,
    this.hasUnviewedStory = false,
  });
}

/// Story data for the horizontal story row.
class StoryItem {
  final String id;
  final String name;
  final String? avatarUrl;
  final String initials;
  final int colorIndex;
  final bool hasUnviewed;
  final bool isSelf;

  const StoryItem({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.initials,
    this.colorIndex = 0,
    this.hasUnviewed = true,
    this.isSelf = false,
  });
}

// ── Avatar color palette ──────────────────────────────────────────────────────

const List<int> kAvatarColors = [
  0xFF2563EB,
  0xFF7C3AED,
  0xFF10B981,
  0xFFEF4444,
  0xFFF59E0B,
  0xFF06B6D4,
  0xFFEC4899,
  0xFF8B5CF6,
];

