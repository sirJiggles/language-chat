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
  
  // Queue to store pending messages for assessment
  final List<Map<String, String>> _pendingAssessments = [];
  bool _isAssessing = false;

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
      
      // Get system prompt from context manager
      String systemPrompt = _contextManager.isInitialized
          ? _contextManager.buildSystemPrompt()
          : 'You are a helpful language learning assistant. Speak primarily in $_targetLanguage. Keep replies concise (max 2 sentences). If the user makes mistakes, gently correct and provide a short example. Translate to English only when explicitly asked.';
      
      final response = await http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _ollamaModel,
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
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
          // Check if this is the first conversation in initial assessment mode
          // and we need to create a student profile
          if (_contextManager.isInitialAssessment && _contextManager.studentProfile == null) {
            // Create a student profile based on the first conversation
            await _contextManager.createStudentProfile(
              targetLanguage: _targetLanguage,
              nativeLanguage: 'English', // Default, can be updated later
              name: 'Student',
              interests: [], // Will be populated during assessment
            );
            debugPrint('Created initial student profile after first conversation');
          }
          
          // If we're in initial assessment mode, try to extract interests as well
          List<String>? discoveredInterests;
          if (_contextManager.isInitialAssessment) {
            // Ask the AI to extract interests from the conversation
            final interestsPrompt = 'Based on the conversation:\n\nUser: "$message"\nAssistant: "$assistantMessage"\n\nIdentify the user\'s interests and learning goals. List only the specific interests or topics (e.g., travel, cooking, literature) as a comma-separated list. If no clear interests are mentioned, respond with "None detected".';
            
            try {
              // Make a separate API call to extract interests
              final interestsResponse = await http.post(
                uri,
                headers: const {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'model': _ollamaModel,
                  'messages': [
                    {
                      'role': 'system',
                      'content': 'You are an expert at identifying user interests from conversations. Extract only specific topics of interest.'
                    },
                    {'role': 'user', 'content': interestsPrompt},
                  ],
                  'stream': false,
                  'options': {'temperature': 0.3},
                }),
              );
              
              if (interestsResponse.statusCode == 200) {
                final interestsData = jsonDecode(interestsResponse.body);
                final aiInterests = interestsData['message']?['content'] ?? '';
                
                if (aiInterests.toLowerCase() != 'none detected') {
                  // Use a completely manual approach to avoid type issues
                  try {
                    // Split by commas
                    final parts = aiInterests.split(',');
                    
                    // Process each part manually
                    final List<String> interests = [];
                    for (final part in parts) {
                      final trimmed = part.trim();
                      if (trimmed.isNotEmpty) {
                        interests.add(trimmed);
                      }
                    }
                    
                    discoveredInterests = interests;
                    
                    if (discoveredInterests.isNotEmpty) {
                      debugPrint('AI discovered interests: ${discoveredInterests.join(', ')}');
                    }
                  } catch (e) {
                    debugPrint('Error processing interests: $e');
                    // If all else fails, just use the raw response
                    discoveredInterests = [aiInterests.trim()];
                  }
                }
              }
            } catch (e) {
              debugPrint('Error extracting interests: $e');
            }
          }
          
          // Update student profile with this conversation and any discovered interests
          // Don't wait for assessment, it will be updated later
          _contextManager.updateProfileWithSession(
            conversation: 'User: $message\nAssistant: $assistantMessage',
            discoveredInterests: discoveredInterests,
          ).then((_) {
            // Save conversation summary for debugging after profile is updated
            final summary = 'Language: $_targetLanguage\n\nUser asked about: $message';
            _contextManager.saveConversationSummary(
              'User: $message\nAssistant: $assistantMessage', 
              summary
            );
          }).catchError((e) {
            debugPrint('Error updating profile: $e');
          });
          
          // Perform assessment in the background without blocking the conversation
          // This is completely separate from the main conversation flow
          _performBackgroundAssessment(message, assistantMessage);
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

  // Strip <think>...</think> tags from the response
  String _stripThinkTags(String text) {
    return text.replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '');
  }
  
  // Perform language assessment in the background
  void _performBackgroundAssessment(String userMessage, String assistantMessage) {
    // Add this conversation to the pending queue
    _pendingAssessments.add({
      'userMessage': userMessage,
      'assistantMessage': assistantMessage,
    });
    
    // Start processing if not already in progress
    if (!_isAssessing) {
      _processAssessmentQueue();
    }
  }
  
  // Process the assessment queue in the background
  Future<void> _processAssessmentQueue() async {
    if (_pendingAssessments.isEmpty || _isAssessing) return;
    
    _isAssessing = true;
    
    try {
      // Process one assessment at a time to avoid overloading
      if (_pendingAssessments.isNotEmpty) {
        final conversation = _pendingAssessments.removeAt(0);
        final userMessage = conversation['userMessage']!;
        final assistantMessage = conversation['assistantMessage']!;
        
        // Run this on a separate isolate or at least a separate async task
        // to ensure it doesn't block the main conversation
        Future.delayed(Duration.zero, () async {
          try {
            // Assess language level
            final assessmentPrompt = 'Based on the conversation:\n\nUser: "$userMessage"\nAssistant: "$assistantMessage"\n\nAssess the user\'s proficiency level in $_targetLanguage according to CEFR standards (A1-C2). Consider vocabulary range, grammatical accuracy, fluency, and complexity. Respond with only the level designation (A1, A2, B1, B2, C1, or C2).';
            
            // Make API call for assessment
            final assessmentResponse = await http.post(
              Uri.parse('$_ollamaBaseUrl/api/chat'),
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
                'options': {'temperature': 0.3},
              }),
            );
            
            if (assessmentResponse.statusCode == 200) {
              final assessmentData = jsonDecode(assessmentResponse.body);
              final aiAssessment = assessmentData['message']?['content'] ?? '';
              final levelMatch = RegExp(r'(A1|A2|B1|B2|C1|C2)').firstMatch(aiAssessment);
              if (levelMatch != null) {
                final assessedLevel = levelMatch.group(0)!;
                debugPrint('Background assessment complete: $assessedLevel');
                
                // Update the profile with the assessment result
                if (_contextManager.isInitialized) {
                  await _contextManager.updateProfileWithSession(
                    conversation: 'User: $userMessage\nAssistant: $assistantMessage',
                    assessedLevel: assessedLevel,
                  );
                }
              }
            }
          } catch (e) {
            debugPrint('Error in background assessment: $e');
          } finally {
            // Process the next item in the queue
            _isAssessing = false;
            _processAssessmentQueue();
          }
        });
      } else {
        _isAssessing = false;
      }
    } catch (e) {
      debugPrint('Error starting assessment queue processing: $e');
      _isAssessing = false;
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
}
