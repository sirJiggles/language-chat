import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/student_profile_store.dart';
import '../models/language_level_tracker.dart';

/// Service for handling language assessment functionality
/// New architecture: Extracts facts + Tracks level over time
class AssessmentService extends ChangeNotifier {
  final String _apiKey;
  final StudentProfileStore _profileStore;
  final LanguageLevelTracker _levelTracker;

  // Queue to store pending assessments
  final List<Map<String, String>> _pendingAssessments = [];
  bool _isProcessing = false;

  // Counter for level assessments (assess every N messages)
  int _messageCount = 0;
  static const int _levelAssessmentInterval = 5; // Assess level every 5 messages

  // Last assessment message for display
  Message? _lastAssessmentMessage;

  AssessmentService({
    required String apiKey,
    required StudentProfileStore profileStore,
    required LanguageLevelTracker levelTracker,
  })  : _apiKey = apiKey,
        _profileStore = profileStore,
        _levelTracker = levelTracker;

  // Getters
  Message? get lastAssessmentMessage => _lastAssessmentMessage;
  StudentProfileStore get profileStore => _profileStore;
  LanguageLevelTracker get levelTracker => _levelTracker;

  /// Perform background assessment on a conversation
  Future<void> performBackgroundAssessment(
    String userMessage,
    String assistantMessage,
    String targetLanguage, {
    bool hideUserMessage = false,
  }) async {
    // Skip assessment for hidden system messages
    if (hideUserMessage && userMessage == 'Hallo') {
      debugPrint('Skipping assessment for hidden system message');
      return;
    }

    _messageCount++;

    // Add to queue
    _pendingAssessments.add({
      'userMessage': userMessage,
      'assistantMessage': assistantMessage,
      'targetLanguage': targetLanguage,
    });

    // Start processing if not already running
    if (!_isProcessing) {
      await _processQueue();
    }
  }

  /// Process the assessment queue
  Future<void> _processQueue() async {
    if (_pendingAssessments.isEmpty || _isProcessing) return;

    _isProcessing = true;

    try {
      while (_pendingAssessments.isNotEmpty) {
        final conversation = _pendingAssessments.removeAt(0);
        final userMessage = conversation['userMessage']!;
        final assistantMessage = conversation['assistantMessage']!;
        final targetLanguage = conversation['targetLanguage']!;

        try {
          // Always extract facts
          await _extractFacts(userMessage, assistantMessage, targetLanguage);

          // Assess level periodically
          if (_messageCount % _levelAssessmentInterval == 0) {
            await _assessLevel(userMessage, assistantMessage, targetLanguage);
          }
        } catch (e) {
          debugPrint('Error in background assessment: $e');
        }

        // Small delay between assessments
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Extract facts from conversation and store in profile
  Future<void> _extractFacts(
    String userMessage,
    String assistantMessage,
    String targetLanguage,
  ) async {
    debugPrint('Extracting facts from conversation...');

    final prompt = '''Analyze this conversation and extract any personal facts about the student that could help personalize future conversations.

Conversation:
User: "$userMessage"
Assistant: "$assistantMessage"

Extract facts like:
- Name, age, location
- Family members (names, relationships)
- Pets (names, types)
- Hobbies, interests, sports
- Job, studies, career
- Preferences, favorites

Return ONLY a JSON object with key-value pairs of facts. Use clear, descriptive keys (e.g., "student_name", "pet_dog_name", "hobby_guitar").
If no new facts are found, return an empty JSON object: {}

Example output:
{"student_name": "Maria", "pet_cat_name": "Whiskers", "hobby_reading": "enjoys mystery novels"}''';

    try {
      final response = await _callOpenAI(prompt, 0.3);
      
      if (response.isNotEmpty) {
        // Try to parse JSON
        try {
          // Extract JSON from response (might have extra text)
          final jsonMatch = RegExp(r'\{[^{}]*\}').firstMatch(response);
          if (jsonMatch != null) {
            final jsonStr = jsonMatch.group(0)!;
            final facts = jsonDecode(jsonStr) as Map<String, dynamic>;
            
            if (facts.isNotEmpty) {
              debugPrint('Extracted ${facts.length} facts: ${facts.keys.join(", ")}');
              await _profileStore.setValues(facts);
            } else {
              debugPrint('No new facts extracted');
            }
          }
        } catch (e) {
          debugPrint('Error parsing facts JSON: $e');
        }
      }
    } catch (e) {
      debugPrint('Error extracting facts: $e');
    }
  }

  /// Assess language level based on recent conversation history
  Future<void> _assessLevel(
    String userMessage,
    String assistantMessage,
    String targetLanguage,
  ) async {
    debugPrint('Assessing language level...');

    final prompt = '''Analyze the student's language proficiency in $targetLanguage based on this conversation:

User: "$userMessage"
Assistant: "$assistantMessage"

Assess according to CEFR standards (A1-C2). Consider:
- Vocabulary range and sophistication
- Grammatical accuracy and complexity
- Sentence structure variety
- Fluency and coherence
- Error patterns

Provide:
1. Brief analysis (2-3 sentences)
2. CEFR level on a new line: "LEVEL: [A1|A2|B1|B2|C1|C2]"

Focus on the user's actual language use, not the topic complexity.''';

    try {
      final response = await _callOpenAI(prompt, 0.3);
      
      if (response.isNotEmpty) {
        // Extract CEFR level
        final levelMatch = RegExp(r'LEVEL:\s*(A1|A2|B1|B2|C1|C2)', caseSensitive: false)
            .firstMatch(response);
        
        String assessedLevel = 'A1';
        if (levelMatch != null) {
          assessedLevel = levelMatch.group(1)!.toUpperCase();
        } else {
          // Fallback: find any CEFR level mention
          final simpleLevelMatch = RegExp(r'\b(A1|A2|B1|B2|C1|C2)\b')
              .firstMatch(response);
          if (simpleLevelMatch != null) {
            assessedLevel = simpleLevelMatch.group(0)!;
          }
        }

        debugPrint('Assessed level: $assessedLevel');
        
        // Update level tracker
        await _levelTracker.updateLevel(
          assessedLevel,
          response,
          confidence: 0.7,
        );

        // Create assessment message
        _lastAssessmentMessage = Message(
          content: 'Level Assessment: $assessedLevel\n\n$response',
          source: MessageSource.assessmentBot,
          timestamp: DateTime.now(),
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error assessing level: $e');
    }
  }

  /// Call OpenAI API
  Future<String> _callOpenAI(String prompt, double temperature) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a language assessment expert. Be concise and precise.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': temperature,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ?? '';
    } else {
      throw Exception('OpenAI API error: ${response.statusCode}');
    }
  }

  /// Reset all assessment data
  Future<void> reset() async {
    await _profileStore.clearProfile();
    await _levelTracker.reset();
    _messageCount = 0;
    _pendingAssessments.clear();
    _lastAssessmentMessage = null;
    notifyListeners();
  }
}
