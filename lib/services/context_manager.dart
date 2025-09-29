import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/student_profile.dart';
import '../models/student_profile_store.dart';
import '../models/language_level_tracker.dart';
import 'level_assessment_service.dart';

/// Manages context files and student profiles for the language learning app
class ContextManager extends ChangeNotifier {
  // Services
  final LevelAssessmentService _levelAssessment = LevelAssessmentService();

  // New stores (optional for backward compatibility)
  StudentProfileStore? _profileStore;
  LanguageLevelTracker? _levelTracker;

  // State
  StudentProfile? _studentProfile;
  final Map<String, String> _contextFiles = {};
  bool _isInitialized = false;
  // No longer using initial assessment mode as we're always assessing in background

  // Getters
  StudentProfile? get studentProfile => _studentProfile;
  bool get isInitialized => _isInitialized;
  Map<String, String> get contextFiles => _contextFiles;
  // Always return false for isInitialAssessment since we're always in regular mode
  bool get isInitialAssessment => false;

  // Set the new stores
  void setStores({StudentProfileStore? profileStore, LanguageLevelTracker? levelTracker}) {
    _profileStore = profileStore;
    _levelTracker = levelTracker;
    notifyListeners();
  }

  // Initialize the context manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _ensureContextDirectoryExists();
      await _loadContextFiles();
      await _loadStudentProfile();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing ContextManager: $e');
    }
  }

  // Get the app's context directory
  Future<Directory> _getContextDirectory() async {
    // On iOS, we need to use the application support directory for persistent storage
    // that survives app updates
    try {
      final directory = await getApplicationSupportDirectory();
      debugPrint('Context directory path: ${directory.path}');
      return directory;
    } catch (e) {
      // Fall back to documents directory if application support is not available
      debugPrint('Error getting application support directory: $e');
      debugPrint('Falling back to documents directory');
      final directory = await getApplicationDocumentsDirectory();
      debugPrint('Using documents directory: ${directory.path}');
      return directory;
    }
  }

  // Ensure the context directory exists and copy asset files
  Future<void> _ensureContextDirectoryExists() async {
    final baseDir = await _getContextDirectory();
    final contextDir = Directory('${baseDir.path}/context');

    debugPrint('Ensuring context directory exists: ${contextDir.path}');
    if (!await contextDir.exists()) {
      await contextDir.create(recursive: true);
      debugPrint('Created context directory');
    }

    // Create initial context files from bundle assets
    await _copyBundleAssetsToContext(contextDir.path);
  }

  // Copy bundle assets to context directory
  Future<void> _copyBundleAssetsToContext(String contextDirPath) async {
    debugPrint('Copying bundle assets to context directory');

    // List of context files to copy from assets
    final contextFiles = [
      'teacher_persona.md',
      'level_assessment.md',
      'conversation_strategies.md',
      'error_correction.md',
      'initial_assessment.md',
    ];

    // Import flutter/services.dart at the top of the file
    for (final fileName in contextFiles) {
      try {
        final targetFile = File('$contextDirPath/$fileName');

        // Only copy if the file doesn't exist yet
        if (!await targetFile.exists()) {
          debugPrint('Copying $fileName to context directory');

          // Read asset content from bundle
          final data = await rootBundle.loadString('assets/context/$fileName');

          // Write to app directory
          await targetFile.writeAsString(data);
          debugPrint('Successfully copied $fileName');
        }
      } catch (e) {
        debugPrint('Error copying asset $fileName: $e');
      }
    }
  }

  // Load all context files
  Future<void> _loadContextFiles() async {
    try {
      final baseDir = await _getContextDirectory();
      final contextDir = Directory('${baseDir.path}/context');

      debugPrint('Loading context files from: ${contextDir.path}');
      if (await contextDir.exists()) {
        final files = await contextDir.list().toList();
        debugPrint('Found ${files.length} files in context directory');

        for (var file in files) {
          if (file.path.endsWith('.md')) {
            final fileName = file.path.split('/').last;
            final content = await File(file.path).readAsString();
            _contextFiles[fileName] = content;
            debugPrint('Loaded context file: $fileName');
          }
        }
      } else {
        debugPrint('Context directory does not exist yet');
      }
    } catch (e) {
      debugPrint('Error loading context files: $e');
    }
  }

  // Load student profile
  Future<void> _loadStudentProfile() async {
    try {
      final baseDir = await _getContextDirectory();
      final profileFile = File('${baseDir.path}/context/student_profile.json');

      debugPrint('Loading student profile from: ${profileFile.path}');
      if (await profileFile.exists()) {
        final content = await profileFile.readAsString();
        debugPrint('Student profile content loaded, parsing JSON');
        final json = jsonDecode(content);
        _studentProfile = StudentProfile.fromJson(json);
        debugPrint(
          'Student profile loaded successfully: ${_studentProfile!.targetLanguage} (${_studentProfile!.proficiencyLevel})',
        );
        // No need to set assessment mode flag as we're always in regular mode
      } else {
        debugPrint('No existing student profile found, creating default profile');
        // Create a default profile right away instead of waiting for assessment
        _createDefaultProfile();
      }
    } catch (e) {
      debugPrint('Error loading student profile: $e');
    }
  }

  // Save student profile - ensures the profile is properly saved
  Future<void> saveStudentProfile() async {
    if (_studentProfile == null) {
      debugPrint('Cannot save profile: profile is null');
      return;
    }

    debugPrint(
      'Saving student profile with level: ${_studentProfile!.proficiencyLevel}, interests: ${_studentProfile!.interests.join(', ')}',
    );

    try {
      final baseDir = await _getContextDirectory();
      final profileFile = File('${baseDir.path}/context/student_profile.json');

      // Create directory if it doesn't exist
      final directory = Directory(baseDir.path + '/context');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Convert profile to JSON and save
      final json = jsonEncode(_studentProfile);
      await profileFile.writeAsString(json);
      debugPrint('Student profile saved successfully');

      // Make sure listeners are notified of the change
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving student profile: $e');
    }
  }

  // Create a new student profile
  Future<void> createStudentProfile({
    required String targetLanguage,
    String nativeLanguage = 'English',
    String name = '',
    List<String> interests = const [],
  }) async {
    _studentProfile = StudentProfile(
      name: name,
      targetLanguage: targetLanguage,
      nativeLanguage: nativeLanguage,
      interests: interests,
    );
    await saveStudentProfile();
    notifyListeners();
  }

  // Update student profile with a new conversation session
  // This is now non-blocking to allow the main conversation to continue
  Future<void> updateProfileWithSession({
    required String conversation,
    String? assessedLevel,
    List<String>? discoveredInterests,
    bool isSystemMessage = false,
  }) async {
    // Return early if no profile exists
    if (_studentProfile == null) return;

    try {
      // Make sure we have a mutable conversation history
      try {
        // Try to add to the existing list
        _studentProfile!.conversationHistory.add(conversation);
      } catch (e) {
        // If that fails, create a new mutable list
        debugPrint('Creating mutable conversation history');
        _studentProfile!.conversationHistory = List<String>.from(
          _studentProfile!.conversationHistory,
        );
        _studentProfile!.conversationHistory.add(conversation);
      }

      // Keep only the most recent conversations (limit to 10)
      if (_studentProfile!.conversationHistory.length > 10) {
        _studentProfile!.conversationHistory.removeAt(0);
      }

      // Update level if provided and it's higher than current level
      if (assessedLevel != null && assessedLevel.isNotEmpty) {
        final currentLevelIndex = _getLevelIndex(_studentProfile!.proficiencyLevel);
        final newLevelIndex = _getLevelIndex(assessedLevel);

        // If new level is valid and higher than current level (or current level is empty)
        if (newLevelIndex >= 0 && (currentLevelIndex < 0 || newLevelIndex > currentLevelIndex)) {
          _studentProfile!.proficiencyLevel = assessedLevel;
          debugPrint('Updated proficiency level to: $assessedLevel');
        }
      }

      // Update interests if provided
      if (discoveredInterests != null && discoveredInterests.isNotEmpty) {
        try {
          // Try to add to the existing list
          for (final interest in discoveredInterests) {
            if (!_studentProfile!.interests.contains(interest)) {
              _studentProfile!.interests.add(interest);
              debugPrint('Added interest: $interest');
            }
          }
        } catch (e) {
          // If that fails, create a new mutable list
          debugPrint('Creating mutable interests list');
          _studentProfile!.interests = List<String>.from(_studentProfile!.interests);

          // Try again with the mutable list
          for (final interest in discoveredInterests) {
            if (!_studentProfile!.interests.contains(interest)) {
              _studentProfile!.interests.add(interest);
              debugPrint('Added interest: $interest');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating profile with session: $e');
      // Continue despite errors to avoid blocking the main conversation
    }

    // No longer need to check for completing initial assessment
    // as we're always in regular mode with continuous background assessment

    // Make sure to save the profile and notify listeners
    // This ensures the UI updates with the new profile data
    await saveStudentProfile();

    // Double check that the profile was updated correctly
    debugPrint('Profile updated with new conversation data');
    debugPrint(
      'Current profile - Level: ${_studentProfile!.proficiencyLevel}, Interests: ${_studentProfile!.interests.join(', ')}',
    );
    debugPrint('Conversation history count: ${_studentProfile!.conversationHistory.length}');
  }

  // Get index of CEFR level for comparison
  int _getLevelIndex(String level) {
    final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    return levels.indexOf(level);
  }

  // Save conversation summary
  Future<void> saveConversationSummary(String conversation, String summary) async {
    try {
      final baseDir = await _getContextDirectory();
      final summariesDir = Directory('${baseDir.path}/context/conversations');

      debugPrint('Saving conversation summary to: ${summariesDir.path}');
      if (!await summariesDir.exists()) {
        await summariesDir.create(recursive: true);
        debugPrint('Created conversations directory');
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final summaryFile = File('${summariesDir.path}/summary_$timestamp.md');
      debugPrint('Writing conversation summary to: ${summaryFile.path}');

      final content =
          '''
# Conversation Summary - ${DateTime.now().toString().split('.')[0]}

## Summary
$summary

## Topics Covered
${_extractTopics(conversation).join(', ')}

## Language Level
${_levelAssessment.assessLevel(conversation)}

## New Vocabulary
${_levelAssessment.extractVocabulary(conversation).join(', ')}

## Grammar Points
${_levelAssessment.extractGrammarPoints(conversation).join(', ')}

## Full Conversation
```
$conversation
```
''';

      await summaryFile.writeAsString(content);
      debugPrint('Conversation summary saved successfully');
    } catch (e) {
      debugPrint('Error saving conversation summary: $e');
    }
  }

  // Extract topics from conversation
  List<String> _extractTopics(String conversation) {
    // Simple implementation - in a real app, you'd use more sophisticated NLP
    final commonTopics = [
      'family',
      'work',
      'school',
      'food',
      'travel',
      'hobbies',
      'weather',
      'sports',
      'music',
      'movies',
      'books',
      'technology',
      'health',
      'politics',
      'culture',
      'history',
      'science',
      'art',
    ];

    final lowerConversation = conversation.toLowerCase();
    return commonTopics.where((topic) => lowerConversation.contains(topic)).toList();
  }

  // Create a default profile when none exists
  Future<void> _createDefaultProfile() async {
    _studentProfile = StudentProfile(
      name: 'Student',
      targetLanguage: 'Spanish', // Default language
      nativeLanguage: 'English',
      interests: [], // Will be populated during conversations
    );
    await saveStudentProfile();
    debugPrint('Created default student profile');
    notifyListeners();
  }

  // Build system prompt for the AI based on context and profile
  String buildSystemPrompt() {
    // If we don't have a student profile yet
    if (_studentProfile == null) {
      return 'You are a helpful language learning assistant. Keep responses concise and clear.';
    }

    // We're always in regular conversation mode now

    final level = _studentProfile!.proficiencyLevel;
    final targetLanguage = _studentProfile!.targetLanguage;
    final nativeLanguage = _studentProfile!.nativeLanguage;
    final interests = _studentProfile!.interests.join(', ');

    // Get level-specific teaching approach
    String teachingApproach = '';
    if (level == 'A1' || level == 'A2') {
      teachingApproach =
          'Use simple language, focus on basic vocabulary and structures. Provide lots of examples.';
    } else if (level == 'B1' || level == 'B2') {
      teachingApproach =
          'Use moderately complex language, introduce new vocabulary in context, and focus on communication.';
    } else {
      teachingApproach =
          'Use natural, native-like language. Focus on nuance, idioms, and cultural context.';
    }

    return '''
You are a ${targetLanguage} language teacher speaking with a ${level} level student whose native language is ${nativeLanguage}.

Teaching approach:
${teachingApproach}

Student interests: ${interests.isNotEmpty ? interests : 'Not specified yet'}

Recent topics: ${_studentProfile!.recentTopics.join(', ')}

Instructions:
1. Speak primarily in ${targetLanguage}, but use ${nativeLanguage} sparingly when needed to explain complex concepts.
2. Adapt your language to ${level} level - not too simple, not too complex.
3. Gently correct errors that would impede communication.
4. When correcting, model the correct form rather than explaining grammar rules extensively.
5. Keep responses concise (2-3 sentences).
6. If the student is struggling, provide scaffolding or simplify your language.
7. Encourage the student to express themselves and take conversational risks.
''';
  }

  // Get context for the prompt
  Future<String> getContextForPrompt() async {
    final contextBuilder = StringBuffer();

    // Check if we have basic information about the student
    bool hasBasicInfo = false;
    String? studentName;

    if (_profileStore != null) {
      final profile = _profileStore!.profile;
      // Check for name in various possible keys
      studentName = profile['student_name'] ?? profile['name'] ?? profile['user_name'];
      hasBasicInfo = studentName != null && studentName.isNotEmpty;
    }

    // Add initial conversation strategy if we don't have basic info
    if (!hasBasicInfo) {
      contextBuilder.writeln('IMPORTANT - Initial Conversation Strategy:');
      contextBuilder.writeln(
        'This is a new student. Your first priority is to learn about them in a natural, friendly way.',
      );
      contextBuilder.writeln('Start by asking their name, then gradually learn about:');
      contextBuilder.writeln('- Where they live or are from');
      contextBuilder.writeln('- Their hobbies and interests');
      contextBuilder.writeln('- Why they are learning this language');
      contextBuilder.writeln('- What they do (work/study)');
      contextBuilder.writeln(
        'Ask ONE question at a time in a conversational way. Be warm and encouraging.',
      );
      contextBuilder.writeln('Keep your responses short and focused on getting to know them.');
      contextBuilder.writeln();
    }

    // NEW: Use StudentProfileStore if available (preferred)
    if (_profileStore != null) {
      final profileContext = _profileStore!.getProfileContext();
      if (profileContext.isNotEmpty && !profileContext.contains('No student profile')) {
        contextBuilder.writeln(profileContext);
        contextBuilder.writeln();

        // Add personalization instruction if we have the name
        if (studentName != null && studentName.isNotEmpty) {
          contextBuilder.writeln(
            'IMPORTANT: Address the student by their name ($studentName) naturally in conversation. But not by starting every chat with Hello $studentName!, rather use the name in the conversation without the use of !. Not every response needs to be addressed to the student else it seems false.',
          );
          contextBuilder.writeln(
            'Use the personal facts you know to make the conversation more engaging and relevant.',
          );
          contextBuilder.writeln();
        }
      }
    }

    // NEW: Use LanguageLevelTracker if available (preferred)
    if (_levelTracker != null) {
      final levelContext = _levelTracker!.getLevelContext();
      contextBuilder.writeln(levelContext);
      contextBuilder.writeln();
    }

    // FALLBACK: Use old StudentProfile if new stores aren't available
    if (_studentProfile != null && _profileStore == null) {
      // Add basic profile information
      contextBuilder.writeln('Student Profile:');
      contextBuilder.writeln('- Name: ${_studentProfile!.name}');
      contextBuilder.writeln('- Target Language: ${_studentProfile!.targetLanguage}');
      contextBuilder.writeln('- Native Language: ${_studentProfile!.nativeLanguage}');
      contextBuilder.writeln('- Proficiency Level: ${_studentProfile!.proficiencyLevel}');

      // Add interests if available
      if (_studentProfile!.interests.isNotEmpty) {
        contextBuilder.writeln('- Interests: ${_studentProfile!.interests.join(', ')}');
      }

      // Add recent topics if available
      if (_studentProfile!.recentTopics.isNotEmpty) {
        contextBuilder.writeln('- Recent Topics: ${_studentProfile!.recentTopics.join(', ')}');
      }

      // Add recent conversation snippets (limited to avoid context overflow)
      if (_studentProfile!.conversationHistory.isNotEmpty) {
        contextBuilder.writeln('\nRecent Conversations:');
        // Get the last 2 conversations at most
        final recentConversations = _studentProfile!.conversationHistory.length > 2
            ? _studentProfile!.conversationHistory.sublist(
                _studentProfile!.conversationHistory.length - 2,
              )
            : _studentProfile!.conversationHistory;

        for (final conversation in recentConversations) {
          // Limit each conversation to a reasonable length
          final truncatedConversation = conversation.length > 200
              ? '${conversation.substring(0, 200)}...'
              : conversation;
          contextBuilder.writeln(truncatedConversation);
          contextBuilder.writeln('---');
        }
      }
    }

    return contextBuilder.toString();
  }
}
