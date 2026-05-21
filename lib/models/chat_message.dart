// ============================================================
// CHAT MESSAGE MODEL — ELSA Health Chatbot
// ============================================================

enum MessageSender { user, bot, system }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isTyping;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isTyping = false,
  });

  factory ChatMessage.user(String text) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.bot(String text) => ChatMessage(
        id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.typing() => ChatMessage(
        id: 'typing_indicator',
        text: '',
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
        isTyping: true,
      );

  factory ChatMessage.system(String text) => ChatMessage(
        id: 'system_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        sender: MessageSender.system,
        timestamp: DateTime.now(),
      );

  ChatMessage copyWith({String? text, bool? isTyping}) => ChatMessage(
        id: id,
        text: text ?? this.text,
        sender: sender,
        timestamp: timestamp,
        isTyping: isTyping ?? this.isTyping,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ChatMessage && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
