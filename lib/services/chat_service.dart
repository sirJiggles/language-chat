import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'context_manager.dart';

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
  final ContextManager _contextManager;

  ChatService({
    String targetLanguage = 'Spanish',
    required ContextManager contextManager,
  }) : _targetLanguage = targetLanguage,
       _contextManager = contextManager;

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
        
        // Update context with conversation data if context manager is initialized
        if (_contextManager.isInitialized) {
          // Ask the AI to assess the language level based on this conversation
          final assessmentPrompt = 'Based on the user\'s message: "$message", assess their proficiency level in $_targetLanguage according to CEFR standards (A1-C2). Consider vocabulary range, grammatical accuracy, fluency, and complexity. Respond with only the level designation (A1, A2, B1, B2, C1, or C2).';
          
          String assessedLevel = 'A1'; // Default level
          try {
            // Make a separate API call just for assessment
            final assessmentResponse = await http.post(
              uri,
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({
                'model': _ollamaModel,
                'messages': [
                  {
                    'role': 'system',
                    'content': 'You are a language assessment expert. Respond only with the CEFR level (A1, A2, B1, B2, C1, or C2).'
                  },
                  {'role': 'user', 'content': assessmentPrompt},
                ],
                'stream': false,
                'options': {'temperature': 0.3}, // Lower temperature for more consistent assessment
              }),
            );
            
            if (assessmentResponse.statusCode == 200) {
              final assessmentData = jsonDecode(assessmentResponse.body);
              final aiAssessment = assessmentData['message']?['content'] ?? '';
              // Extract just the level code (A1, A2, etc.)
              final levelMatch = RegExp(r'(A1|A2|B1|B2|C1|C2)').firstMatch(aiAssessment);
              if (levelMatch != null) {
                assessedLevel = levelMatch.group(0)!;
                debugPrint('AI assessed language level: $assessedLevel');
              }
            }
          } catch (e) {
            debugPrint('Error during language assessment: $e');
          }
          
          // Update student profile with this conversation and the AI-assessed level
          await _contextManager.updateProfileWithSession(
            conversation: 'User: $message\nAssistant: $assistantMessage',
            assessedLevel: assessedLevel,
          );
          
          // Save conversation summary for debugging
          final summary = 'Language: $_targetLanguage\nUser level: $assessedLevel\n\nUser asked about: $message';
          await _contextManager.saveConversationSummary(
            'User: $message\nAssistant: $assistantMessage', 
            summary
          );
        }
        
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
    
    // Update student profile if available and context manager is initialized
    if (_contextManager.isInitialized && _contextManager.studentProfile != null) {
      _contextManager.studentProfile!.targetLanguage = lang;
      _contextManager.saveStudentProfile();
    }
    
    notifyListeners();
  }

  String _stripThinkTags(String text) {
    // Remove <think>...</think> sections for cleaner display/TTS
    final thinkRegex = RegExp(r'<think>[\s\S]*?<\/think>', multiLine: true);
    return text.replaceAll(thinkRegex, '');
  }
}
