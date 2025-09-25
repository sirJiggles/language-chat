import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService extends ChangeNotifier {
  // Ollama configuration via environment
  final String _ollamaBaseUrl = const String.fromEnvironment(
    'OLLAMA_BASE_URL',
    defaultValue: 'http://127.0.0.1:11434',
  );
  final String _ollamaModel = const String.fromEnvironment(
    'OLLAMA_MODEL',
    defaultValue: 'deepseek-r1:8b',
  );
  String _targetLanguage;

  ChatService({String targetLanguage = 'Spanish'}) : _targetLanguage = targetLanguage;

  String _conversation = '';
  String _lastResponse = '';
  bool _isThinking = false;

  String get conversation => _conversation;
  String get lastResponse => _lastResponse;
  String get targetLanguage => _targetLanguage;
  bool get isThinking => _isThinking;

  Future<String> sendMessage(String message) async {
    _conversation += 'User: $message\n';
    notifyListeners();

    try {
      _isThinking = true;
      notifyListeners();
      final uri = Uri.parse('$_ollamaBaseUrl/api/chat');
      final response = await http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _ollamaModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful language learning assistant. Speak primarily in $targetLanguage. Keep replies concise (max 2 sentences). If the user makes mistakes, gently correct and provide a short example. Translate to English only when explicitly asked.',
            },
            {'role': 'user', 'content': message},
          ],
          'stream': false,
          'options': {'temperature': 0.7},
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String assistantMessage = responseData['message']?['content'] ?? '';
        // Some models (e.g., DeepSeek R1) include <think>...</think> blocks.
        assistantMessage = _stripThinkTags(assistantMessage).trim();
        _lastResponse = assistantMessage;
        _conversation += 'Assistant: $assistantMessage\n';
        _isThinking = false;
        notifyListeners();
        return assistantMessage;
      } else {
        final body = response.body;
        throw Exception('Ollama error ${response.statusCode}: $body');
      }
    } catch (e) {
      _lastResponse = 'Error: ${e.toString()}';
      _isThinking = false;
      notifyListeners();
      return _lastResponse;
    }
  }

  void clearConversation() {
    _conversation = '';
    _lastResponse = '';
    notifyListeners();
  }

  void setTargetLanguage(String lang) {
    _targetLanguage = lang;
    notifyListeners();
  }

  String _stripThinkTags(String text) {
    // Remove <think>...</think> sections for cleaner display/TTS
    final thinkRegex = RegExp(r'<think>[\s\S]*?<\/think>', multiLine: true);
    return text.replaceAll(thinkRegex, '');
  }
}
