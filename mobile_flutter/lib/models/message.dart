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
