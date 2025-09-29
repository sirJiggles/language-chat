import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/message_store.dart';
import 'context_manager.dart';
import 'assessment_service.dart';

class ChatService extends ChangeNotifier {
  final ContextManager _contextManager;
  final AssessmentService _assessmentService;
  final String? _openaiApiKey;

  // Separate message stores for conversation and assessment
  late final MessageStore _conversationStore;
  late final MessageStore _assessmentStore;

  ChatService({
    required ContextManager contextManager,
    required AssessmentService assessmentService,
    String? openaiApiKey,
    String targetLanguage = 'German',
  }) : _contextManager = contextManager,
       _assessmentService = assessmentService,
       _openaiApiKey = openaiApiKey {
    _targetLanguage = targetLanguage;
    _conversationStore = MessageStore(name: 'conversation');
    _assessmentStore = MessageStore(name: 'assessment');
  }

  late String _targetLanguage;
  String _lastResponse = '';
  bool _isThinking = false;
  String _thinkingMessageId = '';

  // Legacy support for string-based conversation
  String get conversation => _conversationStore.legacyConversation;

  // New message-based access
  MessageStore get conversationStore => _conversationStore;
  MessageStore get assessmentStore => _assessmentStore;

  String get lastResponse => _lastResponse;
  String get targetLanguage => _targetLanguage;
  bool get isThinking => _isThinking;

  Future<String> sendMessage(String message, {bool hideUserMessage = false}) async {
    // Create a user message
    final userMessage = Message(content: message, source: MessageSource.user);

    // Only add the user message to the conversation if not hidden
    if (!hideUserMessage) {
      _conversationStore.addMessage(userMessage);
      notifyListeners();
    }

    try {
      _isThinking = true;

      // Add thinking message to the conversation
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      _thinkingMessageId = 'thinking_$timestamp';

      final thinkingMessage = Message(
        content: '...',  // Simple content for thinking message
        source: MessageSource.conversationBot,
        isThinking: true,
        id: _thinkingMessageId,
      );

      _conversationStore.addMessage(thinkingMessage);
      notifyListeners();

      // Prepare context for the conversation
      String context = '';
      if (_contextManager.isInitialized) {
        context = await _contextManager.getContextForPrompt();
      }

      // Prepare the prompt
      final prompt = context.isNotEmpty ? '$context\n\nUser: $message' : 'User: $message';

      // System prompt for language learning
      final systemPrompt = 'You are a friendly language learning assistant for $_targetLanguage. '
          'Respond in $_targetLanguage at a level appropriate for the student. '
          'Keep responses concise and helpful for language learning. '
          'If the user speaks in another language, gently encourage them to try in $_targetLanguage.';

      // Call OpenAI API
      final assistantMessage = await _sendMessageToOpenAI(systemPrompt, prompt);

      // Remove the thinking message
      _conversationStore.removeThinking();
      _isThinking = false;
      _thinkingMessageId = '';

      // Add the response to conversation
      if (assistantMessage.isNotEmpty) {
        _conversationStore.addMessage(
          Message(content: assistantMessage, source: MessageSource.conversationBot),
        );
      }
      
      // Ensure UI updates
      notifyListeners();

      _lastResponse = assistantMessage;

      // Perform background assessment - use the original message for assessment
      await _assessmentService.performBackgroundAssessment(
        message,
        assistantMessage,
        _targetLanguage,
        hideUserMessage: hideUserMessage,
      );

      // Add assessment messages to the assessment store
      if (_assessmentService.lastAssessmentMessage != null) {
        _assessmentStore.addMessage(_assessmentService.lastAssessmentMessage!);
      }

      // Return the message to the user
      return assistantMessage;
    } catch (e) {
      debugPrint('Error sending message: $e');

      // Add error message to conversation
      _conversationStore.addMessage(
        Message(
          content: 'Sorry, I encountered an error. Please try again.',
          source: MessageSource.system,
        ),
      );

      return 'Sorry, I encountered an error. Please try again.';
    } finally {
      // Make sure the thinking message is removed in case of error
      if (_isThinking) {
        debugPrint('Cleaning up thinking state in finally block');
        _conversationStore.removeThinking();
        _isThinking = false;
        _thinkingMessageId = '';
        notifyListeners();
      }
    }
  }

  Future<String> _sendMessageToOpenAI(String systemPrompt, String prompt) async {
    if (_openaiApiKey == null || _openaiApiKey.isEmpty) {
      throw Exception('OpenAI API key is not configured');
    }
    
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openaiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? '';
      } else {
        throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error with OpenAI API: $e');
      throw Exception('Failed to communicate with OpenAI: $e');
    }
  }

  void clearConversation() {
    _conversationStore.clear();
    _lastResponse = '';
    notifyListeners();
  }

  void clearAssessment() {
    _assessmentStore.clear();
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
}
