import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../database/repositories/message_metrics_repository.dart';
import '../database/repositories/session_summary_repository.dart';
import '../database/repositories/error_pattern_repository.dart';
import '../database/repositories/vocabulary_progress_repository.dart';
import '../database/repositories/student_fact_repository.dart';
import '../database/repositories/assessment_repository.dart';
import '../database/models/message_metrics_db.dart';
import '../database/models/session_summary_db.dart';
import '../database/models/assessment_db.dart';
import '../models/student_profile_store.dart';
import '../models/language_level_tracker.dart';

/// Comprehensive assessment service that collects data gradually and assesses globally
class ComprehensiveAssessmentService extends ChangeNotifier {
  final String _apiKey;
  final StudentProfileStore _profileStore;
  final LanguageLevelTracker _levelTracker;
  
  // Repositories
  final _metricsRepo = MessageMetricsRepository();
  final _sessionRepo = SessionSummaryRepository();
  final _errorRepo = ErrorPatternRepository();
  final _vocabRepo = VocabularyProgressRepository();
  final _factRepo = StudentFactRepository();
  final _assessmentRepo = AssessmentRepository();
  
  // State
  String? _currentSessionId;
  int _messageCountInSession = 0;
  DateTime? _lastComprehensiveAssessment;
  
  // Configuration
  static const int _comprehensiveAssessmentInterval = 20; // Every 20 messages
  static const int _minMessagesForAssessment = 10; // Need at least 10 messages
  
  ComprehensiveAssessmentService({
    required String apiKey,
    required StudentProfileStore profileStore,
    required LanguageLevelTracker levelTracker,
  })  : _apiKey = apiKey,
        _profileStore = profileStore,
        _levelTracker = levelTracker;
  
  /// Initialize or get current session
  Future<String> _ensureSession() async {
    if (_currentSessionId != null) {
      return _currentSessionId!;
    }
    
    // Check for active session
    final activeSession = await _sessionRepo.getActiveSession();
    if (activeSession != null) {
      _currentSessionId = activeSession.sessionId;
      _messageCountInSession = activeSession.totalMessages;
      return _currentSessionId!;
    }
    
    // Create new session
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final newSession = SessionSummaryDB()
      ..sessionId = _currentSessionId!
      ..startTime = DateTime.now()
      ..totalMessages = 0
      ..totalWords = 0
      ..uniqueWordsUsed = 0
      ..vocabularyDiversity = 0.0
      ..avgMessageLength = 0.0
      ..totalErrors = 0
      ..errorRate = 0.0
      ..topicsDiscussed = []
      ..newVocabulary = []
      ..grammarPointsUsed = [];
    
    await _sessionRepo.saveSummary(newSession);
    debugPrint('Created new assessment session: $_currentSessionId');
    
    return _currentSessionId!;
  }
  
  /// Process a conversation exchange (lightweight data collection)
  Future<void> processConversation(
    String userMessage,
    String assistantMessage,
    String targetLanguage, {
    bool hideUserMessage = false,
  }) async {
    // Skip system messages
    if (hideUserMessage && userMessage == 'Hallo') {
      debugPrint('Skipping assessment for system message');
      return;
    }
    
    final sessionId = await _ensureSession();
    _messageCountInSession++;
    
    // Extract facts (lightweight, no AI call)
    await _extractAndStoreFacts(userMessage, assistantMessage, targetLanguage);
    
    // Collect basic metrics (lightweight, no AI call)
    await _collectMessageMetrics(sessionId, userMessage);
    
    // Update session summary
    await _updateSessionSummary(sessionId);
    
    // Check if it's time for comprehensive assessment
    if (_shouldPerformComprehensiveAssessment()) {
      debugPrint('Triggering comprehensive assessment at $_messageCountInSession messages');
      await _performComprehensiveAssessment(targetLanguage);
    }
    
    notifyListeners();
  }
  
  /// Collect lightweight metrics for a message (no AI call)
  Future<void> _collectMessageMetrics(String sessionId, String userMessage) async {
    final words = userMessage.split(RegExp(r'\s+'));
    final wordCount = words.length;
    final uniqueWords = words.toSet().toList();
    final uniqueWordCount = uniqueWords.length;
    
    double avgWordLength = 0;
    if (wordCount > 0) {
      avgWordLength = words.fold<int>(0, (sum, word) => sum + word.length) / wordCount;
    }
    
    final sentences = userMessage.split(RegExp(r'[.!?]+'));
    final sentenceCount = sentences.where((s) => s.trim().isNotEmpty).length;
    
    final metrics = MessageMetricsDB()
      ..timestamp = DateTime.now()
      ..sessionId = sessionId
      ..wordCount = wordCount
      ..uniqueWordCount = uniqueWordCount
      ..avgWordLength = avgWordLength
      ..sentenceCount = sentenceCount
      ..vocabularyUsed = uniqueWords
      ..grammarStructures = []  // Could be populated by AI later
      ..errorCount = 0  // Would need AI analysis
      ..errorTypes = []
      ..userMessage = userMessage;
    
    await _metricsRepo.saveMetrics(metrics);
  }
  
  /// Update session summary with latest data
  Future<void> _updateSessionSummary(String sessionId) async {
    final session = await _sessionRepo.getSummaryBySessionId(sessionId);
    if (session == null) return;
    
    final metrics = await _metricsRepo.getMetricsBySession(sessionId);
    
    // Calculate aggregates
    int totalWords = 0;
    Set<String> allUniqueWords = {};
    
    for (final metric in metrics) {
      totalWords += metric.wordCount;
      allUniqueWords.addAll(metric.vocabularyUsed);
    }
    
    session.totalMessages = metrics.length;
    session.totalWords = totalWords;
    session.uniqueWordsUsed = allUniqueWords.length;
    session.vocabularyDiversity = totalWords > 0 
        ? allUniqueWords.length / totalWords 
        : 0.0;
    session.avgMessageLength = metrics.isNotEmpty 
        ? totalWords / metrics.length 
        : 0.0;
    
    await _sessionRepo.saveSummary(session);
  }
  
  /// Check if comprehensive assessment should be performed
  bool _shouldPerformComprehensiveAssessment() {
    // Need minimum messages
    if (_messageCountInSession < _minMessagesForAssessment) {
      return false;
    }
    
    // Check if we hit the interval
    if (_messageCountInSession % _comprehensiveAssessmentInterval == 0) {
      return true;
    }
    
    // Check if it's been too long since last assessment (e.g., 30 days)
    if (_lastComprehensiveAssessment != null) {
      final daysSinceAssessment = DateTime.now()
          .difference(_lastComprehensiveAssessment!)
          .inDays;
      if (daysSinceAssessment >= 30) {
        return true;
      }
    } else {
      // Never assessed, do it after minimum messages
      if (_messageCountInSession >= _minMessagesForAssessment) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Perform comprehensive AI-based assessment (expensive, infrequent)
  Future<void> _performComprehensiveAssessment(String targetLanguage) async {
    debugPrint('Starting comprehensive assessment...');
    _lastComprehensiveAssessment = DateTime.now();
    
    // Gather all relevant data
    final recentMetrics = await _metricsRepo.getRecentMetrics(20);
    final recentErrors = await _errorRepo.getRecentErrors(10);
    final vocabularyList = await _vocabRepo.getInProgressVocabulary();
    
    if (recentMetrics.isEmpty) {
      debugPrint('No metrics available for assessment');
      return;
    }
    
    // Build comprehensive context for AI
    final conversationHistory = recentMetrics
        .map((m) => 'User: ${m.userMessage}')
        .join('\n');
    
    final vocabSummary = vocabularyList.isNotEmpty
        ? 'Known vocabulary (${vocabularyList.length} words): ' +
          vocabularyList.take(20).map((v) => v.word).join(', ')
        : 'No vocabulary data yet';
    
    final errorSummary = recentErrors.isNotEmpty
        ? 'Common errors: ' +
          recentErrors.take(5).map((e) => e.errorType).toSet().join(', ')
        : 'No error patterns identified yet';
    
    // Call AI for comprehensive assessment
    final assessment = await _callAIForAssessment(
      targetLanguage,
      conversationHistory,
      vocabSummary,
      errorSummary,
      _messageCountInSession,
    );
    
    // Save assessment to database
    await _saveAssessment(assessment);
    
    debugPrint('Comprehensive assessment completed: ${assessment['level']}');
  }
  
  /// Call AI API for comprehensive assessment
  Future<Map<String, dynamic>> _callAIForAssessment(
    String targetLanguage,
    String conversationHistory,
    String vocabSummary,
    String errorSummary,
    int messageCount,
  ) async {
    // Include self-assessed level if available
    final selfAssessedLevel = _profileStore.getValue('self_assessed_level');
    final selfAssessmentContext = selfAssessedLevel != null
        ? '\n\nSTUDENT\'S SELF-ASSESSMENT: $selfAssessedLevel\nNote: The student believes they are at $selfAssessedLevel level. Consider this but assess objectively based on evidence.'
        : '';
    
    final prompt = '''Analyze this student's $targetLanguage proficiency based on comprehensive data:$selfAssessmentContext

CONVERSATION HISTORY (last 20 messages):
$conversationHistory

VOCABULARY ANALYSIS:
$vocabSummary

ERROR PATTERNS:
$errorSummary

MESSAGES ANALYZED: $messageCount

Provide a comprehensive CEFR assessment (A1-C2) considering:
1. Vocabulary range and sophistication
2. Grammar complexity and accuracy
3. Sentence structure variety
4. Fluency and coherence
5. Error patterns and frequency
6. Progress over time

Format your response as:
LEVEL: [A1|A2|B1|B2|C1|C2]
CONFIDENCE: [0.0-1.0]
ANALYSIS: [2-3 sentences explaining the assessment]
STRENGTHS: [key strengths]
AREAS_FOR_IMPROVEMENT: [key areas to work on]''';
    
    try {
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
              'content': 'You are an expert language assessor. Be thorough and evidence-based.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.3,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] ?? '';
        
        // Parse the structured response
        final levelMatch = RegExp(r'LEVEL:\s*(A1|A2|B1|B2|C1|C2)', caseSensitive: false)
            .firstMatch(content);
        final confidenceMatch = RegExp(r'CONFIDENCE:\s*(0?\.\d+|1\.0)', caseSensitive: false)
            .firstMatch(content);
        
        return {
          'level': levelMatch?.group(1)?.toUpperCase() ?? 'A1',
          'confidence': double.tryParse(confidenceMatch?.group(1) ?? '0.7') ?? 0.7,
          'reasoning': content,
          'messageCount': messageCount,
        };
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in AI assessment: $e');
      return {
        'level': 'A1',
        'confidence': 0.5,
        'reasoning': 'Error during assessment: $e',
        'messageCount': messageCount,
      };
    }
  }
  
  /// Save assessment to database
  Future<void> _saveAssessment(Map<String, dynamic> assessment) async {
    final assessedLevel = assessment['level'] as String;
    final confidence = assessment['confidence'] as double;
    
    // Check if user has a self-assessed level
    final selfAssessedLevel = _profileStore.getValue('self_assessed_level');
    final selfAssessmentDateStr = _profileStore.getValue('self_assessment_date');
    
    bool shouldUpdateLevel = true;
    String finalLevel = assessedLevel;
    double finalConfidence = confidence;
    
    if (selfAssessedLevel != null && selfAssessmentDateStr != null) {
      final selfAssessmentDate = DateTime.parse(selfAssessmentDateStr);
      final daysSinceSelfAssessment = DateTime.now().difference(selfAssessmentDate).inDays;
      
      // Don't override self-assessment too quickly (within first 30 days or 100 messages)
      if (daysSinceSelfAssessment < 30 || _messageCountInSession < 100) {
        // Only update if we're very confident AND the change is small
        final levelDiff = _getLevelDifference(selfAssessedLevel, assessedLevel);
        
        if (levelDiff.abs() <= 1 && confidence >= 0.8) {
          // Allow change by 1 level if confidence is high
          finalLevel = assessedLevel;
          finalConfidence = confidence * 0.7; // Reduce confidence slightly
          debugPrint('Allowing level change from $selfAssessedLevel to $assessedLevel (high confidence)');
        } else if (levelDiff.abs() > 1) {
          // Large difference - blend with self-assessment
          finalLevel = selfAssessedLevel;
          shouldUpdateLevel = false;
          debugPrint('Preserving self-assessed level $selfAssessedLevel (AI suggested $assessedLevel, difference too large)');
        } else {
          // Keep self-assessed level
          finalLevel = selfAssessedLevel;
          shouldUpdateLevel = false;
          debugPrint('Preserving self-assessed level $selfAssessedLevel (not enough confidence)');
        }
      } else {
        // After 30 days or 100 messages, trust the AI assessment more
        finalLevel = assessedLevel;
        finalConfidence = confidence;
      }
    }
    
    // Save to AssessmentDB
    final assessmentDB = AssessmentDB()
      ..timestamp = DateTime.now()
      ..level = finalLevel
      ..confidence = finalConfidence
      ..reasoning = assessment['reasoning']
      ..messageCount = assessment['messageCount'];
    
    await _assessmentRepo.saveAssessment(assessmentDB);
    
    // Update level tracker only if we should
    if (shouldUpdateLevel) {
      await _levelTracker.updateLevel(
        finalLevel,
        assessment['reasoning'],
        confidence: finalConfidence,
      );
    }
    
    // Update session summary
    if (_currentSessionId != null) {
      final session = await _sessionRepo.getSummaryBySessionId(_currentSessionId!);
      if (session != null) {
        session.assessedLevel = finalLevel;
        session.lastAssessmentTime = DateTime.now();
        await _sessionRepo.saveSummary(session);
      }
    }
  }
  
  /// Get the difference between two CEFR levels (e.g., A1 to B2 = 3)
  int _getLevelDifference(String level1, String level2) {
    const levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final index1 = levels.indexOf(level1);
    final index2 = levels.indexOf(level2);
    if (index1 == -1 || index2 == -1) return 0;
    return index2 - index1;
  }
  
  /// Extract facts using AI (separate call, still useful)
  Future<void> _extractAndStoreFacts(
    String userMessage,
    String assistantMessage,
    String targetLanguage,
  ) async {
    final prompt = '''Extract personal facts from this conversation:

User: "$userMessage"
Assistant: "$assistantMessage"

Return ONLY JSON with key-value pairs. Use descriptive keys like "student_name", "hobby_guitar", etc.
If no facts, return: {}

Example: {"student_name": "Maria", "hobby_reading": "enjoys mystery novels"}''';
    
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': 'Extract facts concisely.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.3,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] ?? '';
        
        final jsonMatch = RegExp(r'\{[^{}]*\}').firstMatch(content);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          final facts = jsonDecode(jsonStr) as Map<String, dynamic>;
          
          if (facts.isNotEmpty) {
            debugPrint('Extracted ${facts.length} facts');
            await _profileStore.setValues(facts);
            
            // Also save to database
            for (final entry in facts.entries) {
              await _factRepo.saveFact(entry.key, entry.value.toString());
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error extracting facts: $e');
    }
  }
  
  /// End current session
  Future<void> endSession() async {
    if (_currentSessionId != null) {
      await _sessionRepo.endSession(_currentSessionId!);
      debugPrint('Ended session: $_currentSessionId');
      _currentSessionId = null;
      _messageCountInSession = 0;
    }
  }
  
  /// Start a new session (call when starting new conversation)
  Future<void> startNewSession() async {
    await endSession();
    await _ensureSession();
  }
  
  /// Reset all assessment data
  Future<void> reset() async {
    await _metricsRepo.deleteAll();
    await _sessionRepo.deleteAll();
    await _errorRepo.deleteAll();
    await _vocabRepo.deleteAll();
    await _assessmentRepo.deleteAllAssessments();
    await _levelTracker.reset();
    await _profileStore.clearProfile();
    _currentSessionId = null;
    _messageCountInSession = 0;
    _lastComprehensiveAssessment = null;
    notifyListeners();
    debugPrint('All assessment data reset');
  }
  
  /// Get current session statistics
  Future<Map<String, dynamic>> getSessionStats() async {
    if (_currentSessionId == null) {
      return {};
    }
    
    final session = await _sessionRepo.getSummaryBySessionId(_currentSessionId!);
    if (session == null) return {};
    
    return {
      'sessionId': session.sessionId,
      'totalMessages': session.totalMessages,
      'totalWords': session.totalWords,
      'uniqueWords': session.uniqueWordsUsed,
      'vocabularyDiversity': session.vocabularyDiversity,
      'avgMessageLength': session.avgMessageLength,
      'assessedLevel': session.assessedLevel,
      'messagesUntilNextAssessment': 
          _comprehensiveAssessmentInterval - (_messageCountInSession % _comprehensiveAssessmentInterval),
    };
  }
}
