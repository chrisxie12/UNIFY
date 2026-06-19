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

// ── Mock chat data ────────────────────────────────────────────────────────────

final List<ChatItem> mockChats = [
  const ChatItem(
    id: '1',
    name: 'Ama Asante',
    initials: 'AA',
    avatarColorIndex: 0,
    lastMessage: 'Are you coming to the lecture?',
    timestamp: 'Now',
    isTyping: true,
    typingUser: 'Ama',
    isOnline: true,
    hasUnviewedStory: true,
  ),
  const ChatItem(
    id: '2',
    name: 'KNUST SRC',
    initials: 'KS',
    avatarColorIndex: 1,
    lastMessage: 'Campus event highlights',
    timestamp: '2:34 PM',
    unreadCount: 15,
    hasMedia: true,
    mediaType: 'photo',
  ),
  const ChatItem(
    id: '3',
    name: 'Kofi Mensah',
    initials: 'KM',
    avatarColorIndex: 2,
    lastMessage: 'Thanks for the notes! Really helped a lot.',
    timestamp: '1:15 PM',
    isRead: true,
    isOnline: true,
  ),
  const ChatItem(
    id: '4',
    name: 'Study Group — CS 301',
    initials: 'SG',
    avatarColorIndex: 3,
    lastMessage: 'Chapter 5 summary is ready for review',
    timestamp: '12:00 PM',
    unreadCount: 3,
    isMuted: true,
    isPinned: true,
  ),
  const ChatItem(
    id: '5',
    name: 'Prof. Dr. Owusu',
    initials: 'PO',
    avatarColorIndex: 4,
    lastMessage: 'The assignment deadline has been extended to Friday.',
    timestamp: '11:30 AM',
    isPinned: true,
    isRead: true,
  ),
  const ChatItem(
    id: '6',
    name: 'UNIFY Support',
    initials: 'US',
    avatarColorIndex: 5,
    lastMessage: 'Your verification is complete. Welcome aboard!',
    timestamp: 'Yesterday',
    isForwarded: true,
    isRead: true,
  ),
  const ChatItem(
    id: '7',
    name: 'Efua Tetteh',
    initials: 'ET',
    avatarColorIndex: 6,
    lastMessage: 'See you at the social event later tonight!',
    timestamp: 'Yesterday',
    unreadCount: 5,
    hasUnviewedStory: true,
  ),
  const ChatItem(
    id: '8',
    name: 'Yaw Osei',
    initials: 'YO',
    avatarColorIndex: 7,
    lastMessage: 'Can you share the slides from today\'s lecture?',
    timestamp: 'Monday',
    isOnline: true,
    isRead: true,
  ),
  const ChatItem(
    id: '9',
    name: 'Campus Housing Office',
    initials: 'CH',
    avatarColorIndex: 0,
    lastMessage: 'Your room allocation has been updated.',
    timestamp: 'Monday',
    unreadCount: 2,
    isMuted: true,
  ),
  const ChatItem(
    id: '10',
    name: 'Abena Darkoa',
    initials: 'AD',
    avatarColorIndex: 2,
    lastMessage: 'Photo',
    timestamp: 'Sunday',
    hasMedia: true,
    mediaType: 'photo',
    isRead: true,
    hasUnviewedStory: true,
  ),
];

// ── Mock story data ───────────────────────────────────────────────────────────

final List<StoryItem> mockStories = [
  const StoryItem(id: 's0', name: 'Your Story', initials: 'ME', colorIndex: 0, isSelf: true),
  const StoryItem(id: 's1', name: 'Ama Asante', initials: 'AA', colorIndex: 0, hasUnviewed: true),
  const StoryItem(id: 's2', name: 'KNUST SRC',  initials: 'KS', colorIndex: 1, hasUnviewed: true),
  const StoryItem(id: 's3', name: 'Kofi M.',    initials: 'KM', colorIndex: 2, hasUnviewed: false),
  const StoryItem(id: 's4', name: 'Efua T.',    initials: 'ET', colorIndex: 6, hasUnviewed: true),
  const StoryItem(id: 's5', name: 'Yaw O.',     initials: 'YO', colorIndex: 7, hasUnviewed: true),
  const StoryItem(id: 's6', name: 'Abena D.',   initials: 'AD', colorIndex: 2, hasUnviewed: false),
];
