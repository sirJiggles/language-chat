import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/student_profile.dart';
import 'level_assessment_service.dart';

/// Manages context files and student profiles for the language learning app
class ContextManager extends ChangeNotifier {
  // Services
  final LevelAssessmentService _levelAssessment = LevelAssessmentService();
  
  // State
  StudentProfile? _studentProfile;
  final Map<String, String> _contextFiles = {};
  bool _isInitialized = false;
  
  // Getters
  StudentProfile? get studentProfile => _studentProfile;
  bool get isInitialized => _isInitialized;
  Map<String, String> get contextFiles => _contextFiles;
  
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
        debugPrint('Student profile loaded successfully: ${_studentProfile!.targetLanguage} (${_studentProfile!.proficiencyLevel})');
      } else {
        debugPrint('No existing student profile found, creating default profile');
        // Create a default profile
        await createStudentProfile(
          targetLanguage: 'Spanish', // Default language
          nativeLanguage: 'English',
          name: 'Student',
          interests: ['language learning', 'conversation'],
        );
        debugPrint('Created default student profile');
      }
    } catch (e) {
      debugPrint('Error loading student profile: $e');
    }
  }
  
  // Save student profile
  Future<void> saveStudentProfile() async {
    if (_studentProfile == null) return;
    
    try {
      final baseDir = await _getContextDirectory();
      final contextDir = Directory('${baseDir.path}/context');
      
      if (!await contextDir.exists()) {
        await contextDir.create(recursive: true);
        debugPrint('Created context directory for saving profile');
      }
      
      final profileFile = File('${baseDir.path}/context/student_profile.json');
      debugPrint('Saving student profile to: ${profileFile.path}');
      
      final jsonData = _studentProfile!.toJson();
      await profileFile.writeAsString(jsonEncode(jsonData));
      debugPrint('Student profile saved successfully');
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
  
  // Update student profile with session data
  Future<void> updateProfileWithSession({
    required String conversation,
    String? topic,
  }) async {
    if (_studentProfile == null) return;
    
    // Extract vocabulary and grammar points
    final newVocabulary = _levelAssessment.extractVocabulary(conversation);
    final newGrammarPoints = _levelAssessment.extractGrammarPoints(conversation);
    
    // Assess language level
    final assessedLevel = _levelAssessment.assessLevel(conversation);
    
    // Update profile
    _studentProfile!.updateWithSession(
      conversation: conversation,
      newVocabulary: newVocabulary,
      newGrammarPoints: newGrammarPoints,
      topic: topic,
    );
    
    // Update proficiency level if assessment is higher than current level
    final currentLevelIndex = _getLevelIndex(_studentProfile!.proficiencyLevel);
    final assessedLevelIndex = _getLevelIndex(assessedLevel);
    
    if (assessedLevelIndex > currentLevelIndex) {
      _studentProfile!.updateProficiencyLevel(assessedLevel);
    }
    
    await saveStudentProfile();
    notifyListeners();
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
      
      final content = '''
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
      'family', 'work', 'school', 'food', 'travel', 'hobbies',
      'weather', 'sports', 'music', 'movies', 'books', 'technology',
      'health', 'politics', 'culture', 'history', 'science', 'art'
    ];
    
    final lowerConversation = conversation.toLowerCase();
    return commonTopics.where((topic) => lowerConversation.contains(topic)).toList();
  }
  
  // Build system prompt for the AI based on context and profile
  String buildSystemPrompt() {
    if (_studentProfile == null) {
      return 'You are a helpful language learning assistant. Keep responses concise and clear.';
    }
    
    final level = _studentProfile!.proficiencyLevel;
    final targetLanguage = _studentProfile!.targetLanguage;
    final nativeLanguage = _studentProfile!.nativeLanguage;
    final interests = _studentProfile!.interests.join(', ');
    
    // Get level-specific teaching approach
    String teachingApproach = '';
    if (level == 'A1' || level == 'A2') {
      teachingApproach = 'Use simple language, focus on basic vocabulary and structures. Provide lots of examples.';
    } else if (level == 'B1' || level == 'B2') {
      teachingApproach = 'Use moderately complex language, introduce new vocabulary in context, and focus on communication.';
    } else {
      teachingApproach = 'Use natural, native-like language. Focus on nuance, idioms, and cultural context.';
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
}
