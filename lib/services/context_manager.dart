import 'package:flutter/foundation.dart';
import '../models/student_profile_store.dart';
import '../models/language_level_tracker.dart';
import '../database/repositories/error_pattern_repository.dart';
import '../database/repositories/vocabulary_progress_repository.dart';
import '../database/repositories/session_summary_repository.dart';

/// Manages context and prompts for language learning conversations
/// Uses StudentProfileStore and LanguageLevelTracker for all data - no file I/O
class ContextManager extends ChangeNotifier {
  StudentProfileStore? _profileStore;
  LanguageLevelTracker? _levelTracker;
  bool _isInitialized = false;
  
  // Repositories for data access
  final _errorRepo = ErrorPatternRepository();
  final _vocabRepo = VocabularyProgressRepository();
  final _sessionRepo = SessionSummaryRepository();

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isInitialAssessment => false; // Always in regular conversation mode

  // Set the stores this manager should use
  void setStores({StudentProfileStore? profileStore, LanguageLevelTracker? levelTracker}) {
    _profileStore = profileStore;
    _levelTracker = levelTracker;
    notifyListeners();
  }

  // Initialize the context manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isInitialized = true;
      debugPrint('ContextManager: Initialized');
    } catch (e) {
      debugPrint('ContextManager: Error initializing: $e');
    }
  }


  // Get context for the prompt
  Future<String> getContextForPrompt() async {
    final contextBuilder = StringBuffer();

    // Check if we have basic information about the student
    bool hasName = false;
    String? studentName;

    if (_profileStore != null) {
      final profile = _profileStore!.profile;
      // Check for name in various possible keys
      studentName = profile['student_name'] ?? profile['name'] ?? profile['user_name'];
      hasName = studentName != null && studentName.isNotEmpty;
    }

    // Add initial conversation strategy if we don't have name yet
    if (!hasName) {
      contextBuilder.writeln('=== INITIAL CONVERSATION INSTRUCTIONS ===');
      contextBuilder.writeln('This is a new student. Start by learning their NAME in a natural way.');
      contextBuilder.writeln('Once you know their name, gradually discover more about them through conversation.');
      contextBuilder.writeln('Ask ONE question at a time. Be conversational, not interview-like.');
      contextBuilder.writeln();
    }

    // Add conversation style guidelines
    contextBuilder.writeln('=== CONVERSATION STYLE ===');
    contextBuilder.writeln('- Be natural and authentic - talk like a real person, not a language bot');
    contextBuilder.writeln('- DO NOT repeat what the student just said back to them');
    contextBuilder.writeln('- DO NOT use phrases like "Great that you..." or "I\'m glad you..."');
    contextBuilder.writeln('- Instead, react naturally and move the conversation forward');
    contextBuilder.writeln('- Example: If they say "I like the lake" → "The lake is beautiful! Do you swim there?"');
    contextBuilder.writeln('- NOT: "Great that you like the lake! The lake is nice."');
    contextBuilder.writeln('- Keep responses SHORT (1-2 sentences maximum)');
    contextBuilder.writeln('- Use the student\'s name occasionally, but not in every message');
    contextBuilder.writeln();

    // Use StudentProfileStore for profile context
    if (_profileStore != null) {
      final profileContext = _profileStore!.getProfileContext();
      if (profileContext.isNotEmpty && !profileContext.contains('No student profile')) {
        contextBuilder.writeln('=== WHAT YOU KNOW ABOUT THE STUDENT ===');
        contextBuilder.writeln(profileContext);
        
        if (hasName) {
          contextBuilder.writeln();
          contextBuilder.writeln('IMPORTANT: You already know their name is $studentName. DO NOT ask for it again!');
          contextBuilder.writeln('Use this information naturally to personalize the conversation.');
        }
        contextBuilder.writeln();
      }
    }

    // Use LanguageLevelTracker for level context with teaching instructions
    if (_levelTracker != null) {
      final levelContext = _levelTracker!.getLevelContext();
      if (levelContext.isNotEmpty) {
        contextBuilder.writeln('=== STUDENT LANGUAGE LEVEL (from assessments) ===');
        contextBuilder.writeln(levelContext);
        
        // Add level-specific teaching guidance
        final level = _levelTracker!.currentLevel;
        contextBuilder.writeln();
        contextBuilder.writeln('ADAPT YOUR LANGUAGE TO ${level.toUpperCase()}:');
        
        if (level == 'A1' || level == 'A2') {
          contextBuilder.writeln('- Use simple present tense, basic vocabulary');
          contextBuilder.writeln('- Speak slowly, use short sentences');
          contextBuilder.writeln('- Avoid idioms and complex grammar');
        } else if (level == 'B1' || level == 'B2') {
          contextBuilder.writeln('- Use varied tenses, everyday vocabulary');
          contextBuilder.writeln('- Encourage longer responses and opinions');
          contextBuilder.writeln('- Introduce some idioms and colloquial expressions');
        } else {
          contextBuilder.writeln('- Use natural native-level language');
          contextBuilder.writeln('- Challenge with complex topics and nuanced vocabulary');
          contextBuilder.writeln('- Use idioms, slang, and cultural references freely');
        }
        contextBuilder.writeln();
      }
    }
    
    // Add error patterns if available
    final recentErrors = await _errorRepo.getRecentErrors(5);
    if (recentErrors.isNotEmpty) {
      contextBuilder.writeln('=== COMMON MISTAKES TO ADDRESS ===');
      final errorTypes = <String, int>{};
      for (final error in recentErrors) {
        errorTypes[error.errorType] = (errorTypes[error.errorType] ?? 0) + 1;
      }
      
      contextBuilder.writeln('The student frequently makes these errors:');
      for (final entry in errorTypes.entries) {
        contextBuilder.writeln('- ${entry.key} (${entry.value}x)');
      }
      contextBuilder.writeln('Gently correct these in your responses and provide examples.');
      contextBuilder.writeln();
    }
    
    // Add vocabulary progress if available
    final vocabCount = await _vocabRepo.getCount();
    final masteredCount = await _vocabRepo.getMasteredCount();
    if (vocabCount > 0) {
      contextBuilder.writeln('=== VOCABULARY TRACKING ===');
      contextBuilder.writeln('Student has used $vocabCount unique words');
      contextBuilder.writeln('Mastered: $masteredCount words');
      contextBuilder.writeln('Use words they know, but introduce new ones gradually.');
      contextBuilder.writeln();
    }
    
    // Add clarification usage if available
    final activeSession = await _sessionRepo.getActiveSession();
    if (activeSession != null && activeSession.totalClarificationRequests > 0) {
      final clarificationRate = activeSession.totalMessages > 0 
          ? (activeSession.totalClarificationRequests / activeSession.totalMessages * 100).toStringAsFixed(1)
          : '0';
      
      contextBuilder.writeln('=== COMPREHENSION FEEDBACK ===');
      contextBuilder.writeln('Student requested clarification $clarificationRate% of the time');
      
      if (activeSession.totalClarificationRequests > activeSession.totalMessages * 0.3) {
        contextBuilder.writeln('⚠️ HIGH CLARIFICATION RATE - Simplify your language significantly!');
        contextBuilder.writeln('Use shorter sentences, basic vocabulary, and speak more slowly.');
      } else if (activeSession.totalClarificationRequests > activeSession.totalMessages * 0.15) {
        contextBuilder.writeln('⚠️ MODERATE CLARIFICATION RATE - Content may be slightly too difficult.');
        contextBuilder.writeln('Simplify slightly and check understanding more often.');
      }
      contextBuilder.writeln();
    }

    return contextBuilder.toString();
  }
}
