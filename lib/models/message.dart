// Message model for chat application

enum MessageSource {
  user,
  conversationBot,
  assessmentBot,
  system,
}

class Message {
  final String content;
  final MessageSource source;
  final DateTime timestamp;
  final bool isThinking;
  final String? id;

  Message({
    required this.content,
    required this.source,
    DateTime? timestamp,
    this.isThinking = false,
    this.id,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => source == MessageSource.user;
  bool get isConversationBot => source == MessageSource.conversationBot;
  bool get isAssessmentBot => source == MessageSource.assessmentBot;
  bool get isSystem => source == MessageSource.system;

  @override
  String toString() {
    final prefix = switch (source) {
      MessageSource.user => 'User: ',
      MessageSource.conversationBot => 'Assistant: ',
      MessageSource.assessmentBot => 'Assessment: ',
      MessageSource.system => 'System: ',
    };
    return '$prefix$content';
  }

  // Create a message from a string format
  static Message fromString(String message) {
    if (message.startsWith('User:')) {
      return Message(
        content: message.replaceFirst('User:', '').trim(),
        source: MessageSource.user,
      );
    } else if (message.startsWith('Assistant:')) {
      return Message(
        content: message.replaceFirst('Assistant:', '').trim(),
        source: MessageSource.conversationBot,
      );
    } else if (message.contains('<thinking id=')) {
      return Message(
        content: message,
        source: MessageSource.conversationBot,
        isThinking: true,
        id: _extractThinkingId(message),
      );
    } else {
      // Default to conversation bot for backward compatibility
      return Message(
        content: message,
        source: MessageSource.conversationBot,
      );
    }
  }

  static String? _extractThinkingId(String message) {
    final regex = RegExp(r'<thinking id=([^>]+)>');
    final match = regex.firstMatch(message);
    return match?.group(1);
  }
}
