import 'package:flutter/foundation.dart';
import 'message.dart';

class MessageStore extends ChangeNotifier {
  final List<Message> _messages = [];
  final String name;

  MessageStore({required this.name});

  List<Message> get messages => List.unmodifiable(_messages);

  void addMessage(Message message) {
    // If this is a thinking message and we already have a thinking message, replace it
    if (message.isThinking) {
      final existingThinkingIndex = _messages.indexWhere((m) => m.isThinking);
      if (existingThinkingIndex >= 0) {
        _messages[existingThinkingIndex] = message;
        notifyListeners();
        return;
      }
    }

    _messages.add(message);
    notifyListeners();
  }

  void removeMessage(Message message) {
    _messages.remove(message);
    notifyListeners();
  }

  void removeThinking() {
    _messages.removeWhere((m) => m.isThinking);
    notifyListeners();
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }

  // Legacy support for string-based conversation
  String get legacyConversation {
    return _messages.map((m) => m.toString()).join('\n');
  }

  // Create a MessageStore from a legacy conversation string
  static MessageStore fromLegacyConversation(String conversation, {required String name}) {
    final store = MessageStore(name: name);
    
    if (conversation.isEmpty) return store;
    
    final lines = conversation.split('\n');
    for (final line in lines) {
      if (line.isNotEmpty) {
        store.addMessage(Message.fromString(line));
      }
    }
    
    return store;
  }
}
