enum MessageStatus { sent, delivered, read }

class Message {
  final String id;
  final String senderName;
  final bool isMe;
  final String text;
  final DateTime timestamp;
  final bool isLoading;
  final MessageStatus status;

  const Message({
    required this.id,
    required this.senderName,
    required this.isMe,
    required this.text,
    required this.timestamp,
    this.isLoading = false,
    this.status = MessageStatus.sent,
  });
}

// ── Chat entry sealed hierarchy ───────────────────────────────────────────────
// Allows mixing messages and date dividers in a single list.

abstract class ChatEntry {
  const ChatEntry();
}

class ChatMessage extends ChatEntry {
  final Message message;
  const ChatMessage(this.message);
}

class ChatDateDivider extends ChatEntry {
  final String label;
  const ChatDateDivider(this.label);
}

// ── Mock data (newest-first — index 0 is bottom of screen) ───────────────────

final List<ChatEntry> mockChatEntries = [
  // ── Newest (bottom) ──
  ChatMessage(Message(
    id: 'm10',
    senderName: 'Me',
    isMe: true,
    text: 'Haha okay! See you there 🎉',
    timestamp: _t(0),
    status: MessageStatus.delivered,
  )),
  ChatMessage(Message(
    id: 'm9',
    senderName: 'Yaa Debby',
    isMe: false,
    text: "I'm heading out in 20 mins. You coming?",
    timestamp: _t(3),
    status: MessageStatus.read,
  )),
  ChatMessage(Message(
    id: 'm8',
    senderName: 'Me',
    isMe: true,
    text: 'Nice! Send me the location.',
    timestamp: _t(6),
    status: MessageStatus.read,
  )),
  ChatMessage(Message(
    id: 'm7',
    senderName: 'Yaa Debby',
    isMe: false,
    text: 'Yeah there will be free jollof so I lowkey have to go 😂',
    timestamp: _t(8),
    status: MessageStatus.read,
  )),
  ChatMessage(Message(
    id: 'm6',
    senderName: 'Yaa Debby',
    isMe: false,
    text: 'There\'s a UNIFY campus event tonight at the main hall. Are you going?',
    timestamp: _t(10),
    status: MessageStatus.read,
  )),
  ChatMessage(Message(
    id: 'm5',
    senderName: 'Me',
    isMe: true,
    text: 'Just chilling, studying a bit. Exams are next week 😭',
    timestamp: _t(25),
    status: MessageStatus.read,
  )),
  // ── Date divider ──
  const ChatDateDivider('TODAY'),
  // ── Older (top) ──
  ChatMessage(Message(
    id: 'm4',
    senderName: 'Me',
    isMe: true,
    text: 'Heyy! I\'m good thanks. How about you? What\'s up?',
    timestamp: _t(60),
    status: MessageStatus.read,
  )),
  ChatMessage(Message(
    id: 'm3',
    senderName: 'Yaa Debby',
    isMe: false,
    text: 'Hey! How are you doing? Haven\'t heard from you in a while 😊',
    timestamp: _t(65),
    status: MessageStatus.read,
  )),
  ChatMessage(Message(
    id: 'm2',
    senderName: 'Me',
    isMe: true,
    text: 'Thanks for the notes from yesterday, really saved me!',
    timestamp: _t(120),
    status: MessageStatus.read,
  )),
  ChatMessage(Message(
    id: 'm1',
    senderName: 'Yaa Debby',
    isMe: false,
    text: 'Of course! Glad I could help. That lecture was intense 😅',
    timestamp: _t(125),
    status: MessageStatus.read,
  )),
];

// Helper — creates a DateTime n minutes ago
DateTime _t(int minutesAgo) =>
    DateTime.now().subtract(Duration(minutes: minutesAgo));
