import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/message_store.dart';
import '../models/conversation_archive.dart';
import 'context_manager.dart';
import 'comprehensive_assessment_service.dart';

class ChatService extends ChangeNotifier {
  final ContextManager _contextManager;
  final ComprehensiveAssessmentService _assessmentService;
  final ConversationArchiveStore? _archiveStore;
  final String? _openaiApiKey;

  // Separate message stores for conversation and assessment
  late final MessageStore _conversationStore;
  late final MessageStore _assessmentStore;

  ChatService({
    required ContextManager contextManager,
    required ComprehensiveAssessmentService assessmentService,
    ConversationArchiveStore? archiveStore,
    String? openaiApiKey,
    String targetLanguage = 'German',
  }) : _contextManager = contextManager,
       _assessmentService = assessmentService,
       _archiveStore = archiveStore,
       _openaiApiKey = openaiApiKey {
    _targetLanguage = targetLanguage;
    _conversationStore = MessageStore(name: 'conversation');
    _assessmentStore = MessageStore(name: 'assessment');
  }

  late String _targetLanguage;
  String _lastResponse = '';
  bool _isThinking = false;
  String _thinkingMessageId = '';
  String? _currentArchiveId; // Track the current "live" archive

  // Legacy support for string-based conversation
  String get conversation => _conversationStore.legacyConversation;

  // New message-based access
  MessageStore get conversationStore => _conversationStore;
  MessageStore get assessmentStore => _assessmentStore;

  String get lastResponse => _lastResponse;
  String get targetLanguage => _targetLanguage;
  bool get isThinking => _isThinking;

  /// Speculatively fetch a response without updating the UI
  /// Returns a Future that resolves to the API response
  Future<String> fetchResponseSpeculatively(String message) async {
    try {
      // Prepare context for the conversation
      String context = '';
      if (_contextManager.isInitialized) {
        context = await _contextManager.getContextForPrompt();
      }

      // Prepare the prompt
      final prompt = context.isNotEmpty ? '$context\n\nUser: $message' : 'User: $message';

      // System prompt for language learning
      final systemPrompt = 'You are a $_targetLanguage language teacher having a natural conversation with your student. '
          'YOU lead the conversation - ask questions, introduce topics, and guide the discussion. '
          'Respond ONLY in $_targetLanguage at a level appropriate for the student. '
          'Be proactive: share interesting facts, ask about their day, suggest activities, or discuss topics. '
          'Act like a real teacher who is genuinely interested in engaging the student, not a passive assistant waiting for commands. '
          'Keep responses conversational and natural (2-3 sentences). '
          'If the student speaks in another language, gently encourage them to try in $_targetLanguage.';

      // Call OpenAI API only (no UI updates)
      final assistantMessage = await _sendMessageToOpenAI(systemPrompt, prompt);
      
      debugPrint('ChatService: Speculative response received (${assistantMessage.length} chars)');
      
      return assistantMessage;
    } catch (e) {
      debugPrint('Error in fetchResponseSpeculatively: $e');
      rethrow;
    }
  }

  Future<String> sendMessage(String message, {bool hideUserMessage = false, String? cachedResponse}) async {
    // Create a user message
    final userMessage = Message(content: message, source: MessageSource.user);

    // Only add the user message to the conversation if not hidden
    if (!hideUserMessage) {
      _conversationStore.addMessage(userMessage);
      notifyListeners();
    }

    try {
      // Use cached response if available, otherwise call API
      final String assistantMessage;
      if (cachedResponse != null) {
        debugPrint('ChatService: Using cached speculative response - skipping thinking indicator');
        assistantMessage = cachedResponse;
      } else {
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
        final systemPrompt = 'You are a $_targetLanguage language teacher having a natural conversation with your student. '
            'YOU lead the conversation - ask questions, introduce topics, and guide the discussion. '
            'Respond ONLY in $_targetLanguage at a level appropriate for the student. '
            'Be proactive: share interesting facts, ask about their day, suggest activities, or discuss topics. '
            'Act like a real teacher who is genuinely interested in engaging the student, not a passive assistant waiting for commands. '
            'Keep responses conversational and natural (2-3 sentences). '
            'If the student speaks in another language, gently encourage them to try in $_targetLanguage.';

        // Call OpenAI API
        assistantMessage = await _sendMessageToOpenAI(systemPrompt, prompt);
      }

      // Store the response but keep thinking indicator for now
      // It will be removed when audio starts or immediately if audio is disabled
      _lastResponse = assistantMessage;

      // Process conversation for comprehensive assessment
      await _assessmentService.processConversation(
        message,
        assistantMessage,
        _targetLanguage,
        hideUserMessage: hideUserMessage,
      );

      // Notify listeners to update UI
      notifyListeners();

      // Auto-save to archive after each message
      await _autoSaveToArchive();

      return _lastResponse;
    } catch (e) {
      debugPrint('Error in sendMessage: $e');
      _isThinking = false;
      _conversationStore.removeThinking();
      notifyListeners();
      rethrow;
    }
  }

  /// Automatically save/update the current conversation as a live archive
  Future<void> _autoSaveToArchive() async {
    if (_archiveStore == null) return;
    
    // Only save if there are actual messages (not just thinking indicators)
    final realMessages = _conversationStore.messages
        .where((m) => !m.isThinking && m.content.isNotEmpty)
        .toList();
    
    if (realMessages.isEmpty) return;

    // Convert to archived messages
    final archivedMessages = realMessages
        .map((m) => ArchivedMessage(
              content: m.content,
              isUser: m.isUser,
              timestamp: DateTime.now(),
            ))
        .toList();

    final title = ConversationArchiveStore.generateTitle(archivedMessages);

    if (_currentArchiveId == null) {
      // Create new archive for this conversation
      _currentArchiveId = DateTime.now().millisecondsSinceEpoch.toString();
      final archived = ArchivedConversation(
        id: _currentArchiveId!,
        timestamp: DateTime.now(),
        messages: archivedMessages,
        title: title,
      );
      _archiveStore.archiveConversation(archived);
      debugPrint('Created live archive: $title');
    } else {
      // Update existing archive
      _archiveStore.updateConversation(
        _currentArchiveId!,
        archivedMessages,
        title,
      );
      debugPrint('Updated live archive: $title');
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

  /// Reveal the bot's message (remove thinking indicator and show text)
  /// Call this when audio starts playing or immediately if audio is disabled
  void revealBotMessage() {
    if (_lastResponse.isNotEmpty) {
      // Remove thinking message if it exists
      if (_isThinking) {
        _conversationStore.removeThinking();
        _isThinking = false;
        _thinkingMessageId = '';
      }

      // Add the actual response
      _conversationStore.addMessage(
        Message(content: _lastResponse, source: MessageSource.conversationBot),
      );
      
      notifyListeners();
      debugPrint('Bot message revealed: $_lastResponse');
    }
  }

  /// Archive current conversation and start a new one
  /// Note: With auto-save enabled, the current conversation is already archived.
  /// This method just resets the archive ID to start a fresh conversation.
  Future<void> archiveAndStartNew() async {
    // Reset the current archive ID to start a new conversation
    _currentArchiveId = null;

    // Clear current conversation
    clearConversation();
    clearAssessment();

    debugPrint('Starting new conversation (previous auto-saved)');
  }

  void setTargetLanguage(String lang) {
    _targetLanguage = lang;
    // Note: Profile updates are now handled by StudentProfileStore
    notifyListeners();
  }
}
