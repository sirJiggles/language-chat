import 'dart:convert';

/// Represents a student's language learning profile with proficiency assessment
class StudentProfile {
  String name;
  String targetLanguage;
  String nativeLanguage;
  String proficiencyLevel; // A1, A2, B1, B2, C1, C2
  List<String> interests;
  Map<String, bool> vocabularyProgress;
  Map<String, bool> grammarProgress;
  List<String> recentTopics;
  DateTime lastInteraction;
  int sessionCount;
  List<String> conversationHistory; // Store recent conversations
  
  StudentProfile({
    this.name = '',
    required this.targetLanguage,
    this.nativeLanguage = 'English',
    this.proficiencyLevel = 'A1',
    List<String>? interests,
    Map<String, bool>? vocabularyProgress,
    Map<String, bool>? grammarProgress,
    List<String>? recentTopics,
    DateTime? lastInteraction,
    this.sessionCount = 0,
    List<String>? conversationHistory,
  }) : lastInteraction = lastInteraction ?? DateTime.now(),
       // Create mutable copies of all collections
       interests = interests != null ? List<String>.from(interests) : <String>[],
       vocabularyProgress = vocabularyProgress != null ? Map<String, bool>.from(vocabularyProgress) : <String, bool>{},
       grammarProgress = grammarProgress != null ? Map<String, bool>.from(grammarProgress) : <String, bool>{},
       recentTopics = recentTopics != null ? List<String>.from(recentTopics) : <String>[],
       conversationHistory = conversationHistory != null ? List<String>.from(conversationHistory) : <String>[];

  // Create a profile from JSON
  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      name: json['name'] ?? '',
      targetLanguage: json['targetLanguage'] ?? 'Spanish',
      nativeLanguage: json['nativeLanguage'] ?? 'English',
      proficiencyLevel: json['proficiencyLevel'] ?? 'A1',
      interests: List<String>.from(json['interests'] ?? []),
      vocabularyProgress: Map<String, bool>.from(json['vocabularyProgress'] ?? {}),
      grammarProgress: Map<String, bool>.from(json['grammarProgress'] ?? {}),
      recentTopics: List<String>.from(json['recentTopics'] ?? []),
      lastInteraction: json['lastInteraction'] != null
          ? DateTime.parse(json['lastInteraction'])
          : DateTime.now(),
      sessionCount: json['sessionCount'] ?? 0,
      conversationHistory: List<String>.from(json['conversationHistory'] ?? []),
    );
  }

  // Convert profile to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'targetLanguage': targetLanguage,
      'nativeLanguage': nativeLanguage,
      'proficiencyLevel': proficiencyLevel,
      'interests': interests,
      'vocabularyProgress': vocabularyProgress,
      'grammarProgress': grammarProgress,
      'recentTopics': recentTopics,
      'lastInteraction': lastInteraction.toIso8601String(),
      'sessionCount': sessionCount,
      'conversationHistory': conversationHistory,
    };
  }

  // Update the profile with a new session
  void updateWithSession({
    required String conversation,
    List<String> newVocabulary = const [],
    List<String> newGrammarPoints = const [],
    String? topic,
  }) {
    sessionCount++;
    lastInteraction = DateTime.now();
    
    // Add new topic if provided
    if (topic != null && topic.isNotEmpty) {
      if (!recentTopics.contains(topic)) {
        recentTopics.insert(0, topic);
        // Keep only the 5 most recent topics
        if (recentTopics.length > 5) {
          recentTopics = recentTopics.sublist(0, 5);
        }
      }
    }
    
    // Add new vocabulary
    for (final word in newVocabulary) {
      vocabularyProgress[word] = false; // Initially marked as not mastered
    }
    
    // Add new grammar points
    for (final point in newGrammarPoints) {
      grammarProgress[point] = false; // Initially marked as not mastered
    }
  }
  
  // Mark vocabulary as mastered or not
  void markVocabulary(String word, bool mastered) {
    vocabularyProgress[word] = mastered;
  }
  
  // Mark grammar point as mastered or not
  void markGrammarPoint(String point, bool mastered) {
    grammarProgress[point] = mastered;
  }
  
  // Update proficiency level based on assessment
  void updateProficiencyLevel(String newLevel) {
    if (['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].contains(newLevel)) {
      proficiencyLevel = newLevel;
    }
  }
  
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
