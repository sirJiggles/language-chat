import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/student_profile.dart';

class TeacherContextService extends ChangeNotifier {
  StudentProfile? _studentProfile;
  final Map<String, String> _contextFiles = {};
  bool _isInitialized = false;
  
  // Getters
  StudentProfile? get studentProfile => _studentProfile;
  bool get isInitialized => _isInitialized;
  
  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadContextFiles();
    await _loadStudentProfile();
    
    _isInitialized = true;
    notifyListeners();
  }
  
  // Load all context files
  Future<void> _loadContextFiles() async {
    try {
      final directory = await _getContextDirectory();
      final contextDir = Directory('${directory.path}/context');
      
      if (!await contextDir.exists()) {
        await contextDir.create(recursive: true);
        await _createInitialContextFiles(contextDir.path);
      }
      
      // Load all .md files in the context directory
      final files = await contextDir.list().toList();
      for (var file in files) {
        if (file.path.endsWith('.md')) {
          final fileName = file.path.split('/').last;
          final content = await File(file.path).readAsString();
          _contextFiles[fileName] = content;
        }
      }
    } catch (e) {
      debugPrint('Error loading context files: $e');
    }
  }
  
  // Create initial context files if they don't exist
  Future<void> _createInitialContextFiles(String contextDirPath) async {
    // Teacher personas for different levels
    await File('$contextDirPath/teacher_persona.md').writeAsString('''
# Language Teacher Persona

## Teaching Approach
- Adapt teaching style to student's level
- Use comprehensible input appropriate for level
- Provide gentle error correction
- Focus on communication over perfection
- Use scaffolding techniques to build confidence

## Level-Specific Approaches

### Beginner (A1-A2)
- Use simple, clear language with visual support
- Focus on high-frequency vocabulary and basic structures
- Provide lots of repetition and pattern practice
- Give immediate, supportive feedback
- Use student's native language sparingly when needed

### Intermediate (B1-B2)
- Introduce more complex grammatical structures
- Expand vocabulary beyond basics
- Encourage longer responses and discussions
- Correct errors that impede communication
- Challenge students to express more complex thoughts

### Advanced (C1-C2)
- Focus on nuance, idioms, and cultural context
- Discuss complex topics and abstract concepts
- Provide feedback on style and register
- Encourage native-like fluency and accuracy
- Use authentic materials and discussions
''');

    // Conversation strategies
    await File('$contextDirPath/conversation_strategies.md').writeAsString('''
# Conversation Strategies

## Beginner Level
- Use simple questions: who, what, where, when
- Focus on concrete topics: family, food, daily routines
- Provide sentence frames to support responses
- Use yes/no questions to build confidence
- Repeat and rephrase frequently

## Intermediate Level
- Ask open-ended questions requiring explanation
- Discuss hypothetical situations
- Encourage storytelling and narration
- Introduce debates on familiar topics
- Practice circumlocution strategies

## Advanced Level
- Discuss abstract concepts and complex issues
- Use authentic cultural materials as conversation starters
- Encourage expression of nuanced opinions
- Focus on register and appropriate language use
- Challenge with unexpected questions and topics
''');

    // Error correction strategies
    await File('$contextDirPath/error_correction.md').writeAsString('''
# Error Correction Strategies

## General Principles
- Focus on errors that impede communication
- Consider the student's proficiency level
- Balance fluency and accuracy
- Provide positive reinforcement
- Use a variety of correction techniques

## Correction Techniques
- Recast: Reformulate the student's error correctly
- Clarification request: "I'm sorry, could you say that again?"
- Metalinguistic feedback: Provide information about the error
- Elicitation: "How do we say that in past tense?"
- Explicit correction: Clearly indicate the error and provide correction

## Level-Specific Approaches
- Beginners: Focus on basic structures, use recasts frequently
- Intermediate: Balance explicit and implicit correction
- Advanced: Focus on nuance, register, and pragmatics
''');

    // Assessment criteria
    await File('$contextDirPath/level_assessment.md').writeAsString('''
# Language Proficiency Assessment

## CEFR Levels Overview

### A1 (Beginner)
- Can understand and use familiar everyday expressions and very basic phrases
- Can introduce themselves and others and ask/answer questions about personal details
- Can interact in a simple way if the other person talks slowly and clearly

### A2 (Elementary)
- Can understand sentences and frequently used expressions related to immediate relevance
- Can communicate in simple and routine tasks requiring direct exchange of information
- Can describe in simple terms aspects of their background and immediate environment

### B1 (Intermediate)
- Can understand the main points of clear standard input on familiar matters
- Can deal with most situations likely to arise while traveling
- Can produce simple connected text on familiar topics
- Can describe experiences, events, dreams, hopes & ambitions

### B2 (Upper Intermediate)
- Can understand the main ideas of complex text on concrete and abstract topics
- Can interact with a degree of fluency and spontaneity with native speakers
- Can produce clear, detailed text on a wide range of subjects
- Can explain a viewpoint on an issue giving advantages and disadvantages

### C1 (Advanced)
- Can understand a wide range of demanding, longer texts
- Can express ideas fluently and spontaneously without obvious searching for expressions
- Can use language flexibly and effectively for social, academic and professional purposes
- Can produce clear, well-structured, detailed text on complex subjects

### C2 (Proficiency)
- Can understand with ease virtually everything heard or read
- Can summarize information from different spoken and written sources
- Can express themselves spontaneously, very fluently and precisely
- Can differentiate finer shades of meaning even in more complex situations
''');

    // Student profile template
    await File('$contextDirPath/student_profile_template.md').writeAsString('''
# Student Profile

## Personal Information
- Name: [Student Name]
- Native Language: [Native Language]
- Target Language: [Target Language]
- Current Proficiency Level: [A1/A2/B1/B2/C1/C2]
- Learning Goals: [Goals]
- Interests: [Interests]

## Learning History
- Time studying the language: [Duration]
- Previous learning experiences: [Experiences]
- Strengths: [Strengths]
- Areas for improvement: [Areas]

## Recent Progress
- Recent topics covered: [Topics]
- Vocabulary focus: [Vocabulary]
- Grammar focus: [Grammar]
- Communication skills: [Skills]

## Notes
[Additional notes about the student's learning style, preferences, etc.]
''');
  }
  
  // Load student profile
  Future<void> _loadStudentProfile() async {
    try {
      final directory = await _getContextDirectory();
      final profileFile = File('${directory.path}/student_profile.json');
      
      if (await profileFile.exists()) {
        final content = await profileFile.readAsString();
        final json = jsonDecode(content);
        _studentProfile = StudentProfile.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error loading student profile: $e');
    }
  }
  
  // Save student profile
  Future<void> saveStudentProfile() async {
    if (_studentProfile == null) return;
    
    try {
      final directory = await _getContextDirectory();
      final profileFile = File('${directory.path}/student_profile.json');
      
      await profileFile.writeAsString(jsonEncode(_studentProfile!.toJson()));
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
    List<String> newVocabulary = const [],
    List<String> newGrammarPoints = const [],
    String? topic,
  }) async {
    if (_studentProfile == null) return;
    
    _studentProfile!.updateWithSession(
      conversation: conversation,
      newVocabulary: newVocabulary,
      newGrammarPoints: newGrammarPoints,
      topic: topic,
    );
    
    await saveStudentProfile();
    notifyListeners();
  }
  
  // Assess language level based on conversation
  Future<String> assessLanguageLevel(String conversation) async {
    // This is a simple implementation - in a real app, you'd use more sophisticated analysis
    // or potentially call an AI service for assessment
    
    // Count words, unique words, and sentence length as basic metrics
    final words = conversation.split(RegExp(r'\s+'));
    final uniqueWords = words.toSet().length;
    final avgWordLength = words.fold<int>(0, (sum, word) => sum + word.length) / words.length;
    
    // Simple heuristic based on lexical diversity and word length
    final lexicalDiversity = uniqueWords / words.length;
    
    if (lexicalDiversity > 0.7 && avgWordLength > 5.5) return 'C1';
    if (lexicalDiversity > 0.6 && avgWordLength > 5.0) return 'B2';
    if (lexicalDiversity > 0.5 && avgWordLength > 4.5) return 'B1';
    if (lexicalDiversity > 0.4 && avgWordLength > 4.0) return 'A2';
    return 'A1';
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
  
  // Get the app's documents directory
  Future<Directory> _getContextDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }
}
