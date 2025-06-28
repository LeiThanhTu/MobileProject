enum ChatMessageType { user, bot }

class ChatMessage {
  final String text;
  final ChatMessageType type;

  ChatMessage({
    required this.text,
    required this.type,
  });
}
