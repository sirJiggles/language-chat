import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/message_store.dart';
import '../models/settings_model.dart';
import 'context_manager.dart';
import 'assessment_service.dart';

class ChatService extends ChangeNotifier {
  final String _ollamaBaseUrl;
  final String _ollamaModel;
  final ContextManager _contextManager;
  final AssessmentService _assessmentService;
  final SettingsModel _settingsModel;
  final String? _openaiApiKey;

  // Separate message stores for conversation and assessment
  late final MessageStore _conversationStore;
  late final MessageStore _assessmentStore;

  ChatService({
    required String ollamaBaseUrl,
    required String ollamaModel,
    required ContextManager contextManager,
    required AssessmentService assessmentService,
    required SettingsModel settingsModel,
    String? openaiApiKey,
    String targetLanguage = 'German',
  }) : _ollamaBaseUrl = ollamaBaseUrl,
       _ollamaModel = ollamaModel,
       _contextManager = contextManager,
       _assessmentService = assessmentService,
       _settingsModel = settingsModel,
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
  List<Map<String, dynamic>> get assessmentResults => _assessmentService.assessmentResults;
  String get assessmentLog => _assessmentService.assessmentLog;

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
          'If the user speaks in another language, gently encourage them to try in $_targetLanguage.\n\n'
          'If you need to include your thinking process or reasoning that should not be shown to the student, '
          'wrap it in <think></think> tags. This content will be hidden from the student but will be used for assessment.';

      String assistantMessage;
      
      // Choose API based on settings
      if (_settingsModel.chatProvider == ChatProvider.ollama) {
        assistantMessage = await _sendMessageToOllama(systemPrompt, prompt);
      } else {
        assistantMessage = await _sendMessageToOpenAI(systemPrompt, prompt);
      }

      // Filter out any content wrapped in <think></think> tags
      final filteredMessage = _filterThinkingContent(assistantMessage);
      
      // Debug the filtering
      debugPrint('Original message: $assistantMessage');
      debugPrint('Filtered message: $filteredMessage');

      // Debug thinking state before removal
      debugPrint('Before removing thinking message: isThinking=$_isThinking, thinkingMessageId=$_thinkingMessageId');
      debugPrint('Thinking messages in store: ${_conversationStore.messages.where((m) => m.isThinking).length}');
      
      // Remove the thinking message
      _conversationStore.removeThinking();
      _isThinking = false;
      _thinkingMessageId = '';
      
      // Debug thinking state after removal
      debugPrint('After removing thinking message: isThinking=$_isThinking, thinkingMessageId=$_thinkingMessageId');
      debugPrint('Thinking messages in store: ${_conversationStore.messages.where((m) => m.isThinking).length}');

      // Only add the message to the conversation if it's not empty after filtering
      if (filteredMessage.isNotEmpty) {
        // Add the real response
        _conversationStore.addMessage(
          Message(content: filteredMessage, source: MessageSource.conversationBot),
        );
      }
      
      // Ensure UI updates
      notifyListeners();

      _lastResponse = filteredMessage;

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

      // Return the filtered message to the user
      return filteredMessage;
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
  
  Future<String> _sendMessageToOllama(String systemPrompt, String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_ollamaBaseUrl/api/chat'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _ollamaModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
          'options': {'temperature': 0.7},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message']?['content'] ?? '';
      } else {
        throw Exception('Ollama API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error with Ollama API: $e');
      throw Exception('Failed to communicate with Ollama: $e');
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

  // Filter out content wrapped in <think></think> tags
  String _filterThinkingContent(String message) {
    // Use regex to remove any content between <think> and </think> tags
    final thinkingPattern = RegExp(r'<think>.*?</think>', dotAll: true);
    final filteredMessage = message.replaceAll(thinkingPattern, '').trim();
    
    // Debug the filtering process
    debugPrint('Filtering message:');
    debugPrint('Original: $message');
    debugPrint('Filtered: $filteredMessage');
    
    // If the message contains thinking content, add it to the assessment store
    if (message.contains('<think>')) {
      // Extract the thinking content
      final thinkingContent = _extractThinkingContent(message);
      if (thinkingContent.isNotEmpty) {
        // Create an assessment message with the thinking content
        _assessmentStore.addMessage(Message(
          content: thinkingContent,
          source: MessageSource.assessmentBot,
        ));
      }
    }
    
    // Make sure we're not returning an empty message
    if (filteredMessage.isEmpty && message.isNotEmpty) {
      // If the entire message was wrapped in think tags, return a placeholder
      debugPrint('Warning: Entire message was filtered out. Using original message.');
      return message;
    }
    
    return filteredMessage;
  }
  
  // Extract content from <think></think> tags
  String _extractThinkingContent(String message) {
    final thinkingPattern = RegExp(r'<think>(.*?)</think>', dotAll: true);
    final match = thinkingPattern.firstMatch(message);
    return match?.group(1)?.trim() ?? '';
  }
}
