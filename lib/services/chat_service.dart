import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'context_manager.dart';
import 'assessment_service.dart';

class ChatService extends ChangeNotifier {
  final String _ollamaBaseUrl;
  final String _ollamaModel;
  final ContextManager _contextManager;
  final AssessmentService _assessmentService;

  ChatService({
    required String ollamaBaseUrl,
    required String ollamaModel,
    required ContextManager contextManager,
    required AssessmentService assessmentService,
    String targetLanguage = 'German',
  }) : _ollamaBaseUrl = ollamaBaseUrl,
       _ollamaModel = ollamaModel,
       _contextManager = contextManager,
       _assessmentService = assessmentService {
    _targetLanguage = targetLanguage;
    // Assessment results are now loaded by AssessmentService
  }

  late String _targetLanguage;
  String _conversation = '';
  String _lastResponse = '';
  bool _isThinking = false;

  // Assessment results are now managed by AssessmentService

  String get conversation => _conversation;
  String get lastResponse => _lastResponse;
  String get targetLanguage => _targetLanguage;
  bool get isThinking => _isThinking;
  List<Map<String, dynamic>> get assessmentResults => _assessmentService.assessmentResults;
  String get assessmentLog => _assessmentService.assessmentLog;

  Future<String> sendMessage(String message, {bool hideUserMessage = false}) async {
    // Only add the user message to the conversation if not hidden
    if (!hideUserMessage) {
      _conversation += 'User: $message\n';
      notifyListeners();
    }

    try {
      _isThinking = true;
      notifyListeners();

      // Prepare context for the conversation
      String context = '';
      if (_contextManager.isInitialized) {
        context = await _contextManager.getContextForPrompt();
      }

      // Prepare the prompt
      final prompt = context.isNotEmpty ? '$context\n\nUser: $message' : 'User: $message';

      // Make API call
      final response = await http.post(
        Uri.parse('$_ollamaBaseUrl/api/chat'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _ollamaModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a friendly language learning assistant for $_targetLanguage. '
                  'Respond in $_targetLanguage at a level appropriate for the student. '
                  'Keep responses concise and helpful for language learning. '
                  'If the user speaks in another language, gently encourage them to try in $_targetLanguage.\n\n'
                  'If you need to include your thinking process or reasoning that should not be shown to the student, '
                  'wrap it in <think></think> tags. This content will be hidden from the student but will be used for assessment.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
          'options': {'temperature': 0.7},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage = data['message']?['content'] ?? '';

        // Filter out any content wrapped in <think></think> tags
        final filteredMessage = _filterThinkingContent(assistantMessage);

        // Add the filtered response to the conversation
        _conversation += 'Assistant: $filteredMessage\n';
        _lastResponse = filteredMessage;

        // Perform background assessment - use the original message for assessment
        _assessmentService.performBackgroundAssessment(message, assistantMessage, _targetLanguage, hideUserMessage: hideUserMessage);

        // Return the filtered message to the user
        return filteredMessage;
      } else {
        final errorMessage = 'Error: ${response.statusCode} - ${response.body}';
        debugPrint(errorMessage);
        return 'Sorry, I encountered an error. Please try again.';
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      return 'Sorry, I encountered an error. Please try again.';
    } finally {
      _isThinking = false;
      notifyListeners();
    }
  }

  // Assessment functionality moved to AssessmentService

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

  // Filter out content wrapped in <think></think> tags
  String _filterThinkingContent(String message) {
    // Use regex to remove any content between <think> and </think> tags
    final thinkingPattern = RegExp(r'<think>.*?</think>', dotAll: true);
    return message.replaceAll(thinkingPattern, '').trim();
  }
}
