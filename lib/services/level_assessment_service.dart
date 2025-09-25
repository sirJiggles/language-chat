import 'package:flutter/foundation.dart';

/// Service for assessing language proficiency level based on conversation
class LevelAssessmentService {
  // CEFR levels
  static const List<String> levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  
  // Vocabulary complexity indicators by level
  static final Map<String, List<String>> _levelVocabulary = {
    'A1': ['hello', 'goodbye', 'yes', 'no', 'please', 'thank', 'sorry', 'day', 'night', 'food', 'water'],
    'A2': ['yesterday', 'tomorrow', 'because', 'sometimes', 'usually', 'often', 'never', 'always'],
    'B1': ['however', 'although', 'therefore', 'despite', 'nevertheless', 'furthermore', 'moreover'],
    'B2': ['consequently', 'subsequently', 'presumably', 'allegedly', 'apparently', 'evidently'],
    'C1': ['notwithstanding', 'hitherto', 'heretofore', 'aforementioned', 'quintessential'],
    'C2': ['ubiquitous', 'surreptitious', 'perfunctory', 'pernicious', 'egregious', 'ephemeral'],
  };
  
  // Grammar complexity indicators by level
  static final Map<String, List<String>> _levelGrammar = {
    'A1': ['am', 'is', 'are', 'do', 'does', 'can', 'have', 'has'],
    'A2': ['was', 'were', 'did', 'had', 'could', 'would', 'should', 'will'],
    'B1': ['have been', 'has been', 'had been', 'would have', 'could have', 'should have'],
    'B2': ['having been', 'would have been', 'could have been', 'should have been'],
    'C1': ['were to', 'were it not for', 'had it not been', 'would it not have been'],
    'C2': ['were it to have been', 'had it not been for the fact that', 'notwithstanding the fact that'],
  };
  
  // Sentence structure complexity by level
  static final Map<String, List<String>> _levelSentenceStructures = {
    'A1': ['.', '?', '!'],
    'A2': ['and', 'but', 'or', 'so', 'because'],
    'B1': ['while', 'when', 'after', 'before', 'if', 'unless', 'until'],
    'B2': ['whereas', 'whereby', 'wherein', 'such that', 'in order to', 'so as to'],
    'C1': ['notwithstanding', 'albeit', 'lest', 'provided that', 'in case'],
    'C2': ['insofar as', 'inasmuch as', 'in the event that', 'on the condition that'],
  };
  
  /// Assess language level based on a conversation
  /// Returns a CEFR level (A1, A2, B1, B2, C1, C2)
  String assessLevel(String conversation) {
    try {
      // Clean up the conversation text
      final cleanText = _cleanText(conversation);
      
      // Calculate metrics
      final metrics = _calculateMetrics(cleanText);
      
      // Determine level based on metrics
      return _determineLevelFromMetrics(metrics);
    } catch (e) {
      debugPrint('Error assessing language level: $e');
      return 'A1'; // Default to beginner if assessment fails
    }
  }
  
  // Clean text for analysis
  String _cleanText(String text) {
    // Remove user/assistant prefixes
    final cleanedText = text
        .replaceAll(RegExp(r'User:\s*'), '')
        .replaceAll(RegExp(r'Assistant:\s*'), '')
        .toLowerCase();
    
    return cleanedText;
  }
  
  // Calculate language metrics from text
  Map<String, double> _calculateMetrics(String text) {
    final words = text.split(RegExp(r'\s+'));
    final sentences = text.split(RegExp(r'[.!?]+'));
    
    // Basic metrics
    final wordCount = words.length;
    final uniqueWordCount = words.toSet().length;
    final avgWordLength = words.fold<int>(0, (sum, word) => sum + word.length) / 
        (wordCount > 0 ? wordCount : 1);
    final avgSentenceLength = wordCount / (sentences.length > 0 ? sentences.length : 1);
    
    // Lexical diversity (type-token ratio)
    final lexicalDiversity = uniqueWordCount / (wordCount > 0 ? wordCount : 1);
    
    // Calculate level scores based on vocabulary, grammar, and sentence structure
    final levelScores = _calculateLevelScores(text);
    
    return {
      'avgWordLength': avgWordLength,
      'avgSentenceLength': avgSentenceLength,
      'lexicalDiversity': lexicalDiversity,
      'a1Score': levelScores['A1'] ?? 0,
      'a2Score': levelScores['A2'] ?? 0,
      'b1Score': levelScores['B1'] ?? 0,
      'b2Score': levelScores['B2'] ?? 0,
      'c1Score': levelScores['C1'] ?? 0,
      'c2Score': levelScores['C2'] ?? 0,
    };
  }
  
  // Calculate level scores based on vocabulary, grammar, and sentence structure
  Map<String, double> _calculateLevelScores(String text) {
    final Map<String, double> scores = {};
    
    // Initialize scores for each level
    for (final level in levels) {
      scores[level] = 0;
    }
    
    // Check for vocabulary indicators
    for (final level in _levelVocabulary.keys) {
      for (final word in _levelVocabulary[level]!) {
        if (text.contains(word)) {
          scores[level] = (scores[level] ?? 0) + 0.5;
        }
      }
    }
    
    // Check for grammar indicators
    for (final level in _levelGrammar.keys) {
      for (final pattern in _levelGrammar[level]!) {
        try {
          // Escape special regex characters in the pattern
          final escapedPattern = RegExp.escape(pattern);
          final matches = RegExp('\\b$escapedPattern\\b').allMatches(text);
          scores[level] = (scores[level] ?? 0) + matches.length * 0.7;
        } catch (e) {
          debugPrint('Error in grammar pattern "$pattern": $e');
        }
      }
    }
    
    // Check for sentence structure indicators
    for (final level in _levelSentenceStructures.keys) {
      for (final pattern in _levelSentenceStructures[level]!) {
        try {
          // For punctuation and special characters, don't use word boundaries
          if (pattern.length == 1 && !RegExp(r'[a-zA-Z0-9]').hasMatch(pattern)) {
            // For single punctuation characters
            final matches = RegExp(RegExp.escape(pattern)).allMatches(text);
            scores[level] = (scores[level] ?? 0) + matches.length * 0.3;
          } else {
            // For words and phrases
            final escapedPattern = RegExp.escape(pattern);
            final matches = RegExp('\\b$escapedPattern\\b').allMatches(text);
            scores[level] = (scores[level] ?? 0) + matches.length * 0.3;
          }
        } catch (e) {
          debugPrint('Error in sentence structure pattern "$pattern": $e');
        }
      }
    }
    
    return scores;
  }
  
  // Determine CEFR level from metrics
  String _determineLevelFromMetrics(Map<String, double> metrics) {
    // Weighted scoring for each level
    final Map<String, double> levelWeights = {};
    
    for (final level in levels) {
      final levelKey = level.toLowerCase() + 'Score';
      levelWeights[level] = metrics[levelKey] ?? 0;
    }
    
    // Add additional weight based on general metrics
    if (metrics['lexicalDiversity']! < 0.4) {
      levelWeights['A1'] = (levelWeights['A1'] ?? 0) + 3;
      levelWeights['A2'] = (levelWeights['A2'] ?? 0) + 1;
    } else if (metrics['lexicalDiversity']! < 0.5) {
      levelWeights['A2'] = (levelWeights['A2'] ?? 0) + 3;
      levelWeights['B1'] = (levelWeights['B1'] ?? 0) + 1;
    } else if (metrics['lexicalDiversity']! < 0.6) {
      levelWeights['B1'] = (levelWeights['B1'] ?? 0) + 3;
      levelWeights['B2'] = (levelWeights['B2'] ?? 0) + 1;
    } else if (metrics['lexicalDiversity']! < 0.7) {
      levelWeights['B2'] = (levelWeights['B2'] ?? 0) + 3;
      levelWeights['C1'] = (levelWeights['C1'] ?? 0) + 1;
    } else {
      levelWeights['C1'] = (levelWeights['C1'] ?? 0) + 2;
      levelWeights['C2'] = (levelWeights['C2'] ?? 0) + 2;
    }
    
    if (metrics['avgWordLength']! < 4) {
      levelWeights['A1'] = (levelWeights['A1'] ?? 0) + 2;
    } else if (metrics['avgWordLength']! < 4.5) {
      levelWeights['A2'] = (levelWeights['A2'] ?? 0) + 2;
    } else if (metrics['avgWordLength']! < 5) {
      levelWeights['B1'] = (levelWeights['B1'] ?? 0) + 2;
    } else if (metrics['avgWordLength']! < 5.5) {
      levelWeights['B2'] = (levelWeights['B2'] ?? 0) + 2;
    } else if (metrics['avgWordLength']! < 6) {
      levelWeights['C1'] = (levelWeights['C1'] ?? 0) + 2;
    } else {
      levelWeights['C2'] = (levelWeights['C2'] ?? 0) + 2;
    }
    
    if (metrics['avgSentenceLength']! < 5) {
      levelWeights['A1'] = (levelWeights['A1'] ?? 0) + 2;
    } else if (metrics['avgSentenceLength']! < 8) {
      levelWeights['A2'] = (levelWeights['A2'] ?? 0) + 2;
    } else if (metrics['avgSentenceLength']! < 12) {
      levelWeights['B1'] = (levelWeights['B1'] ?? 0) + 2;
    } else if (metrics['avgSentenceLength']! < 16) {
      levelWeights['B2'] = (levelWeights['B2'] ?? 0) + 2;
    } else if (metrics['avgSentenceLength']! < 20) {
      levelWeights['C1'] = (levelWeights['C1'] ?? 0) + 2;
    } else {
      levelWeights['C2'] = (levelWeights['C2'] ?? 0) + 2;
    }
    
    // Find the level with the highest weight
    String highestLevel = 'A1';
    double highestWeight = 0;
    
    for (final level in levelWeights.keys) {
      final weight = levelWeights[level] ?? 0;
      if (weight > highestWeight) {
        highestWeight = weight;
        highestLevel = level;
      }
    }
    
    return highestLevel;
  }
  
  // Extract vocabulary from conversation
  List<String> extractVocabulary(String conversation) {
    final text = _cleanText(conversation);
    final words = text.split(RegExp(r'\s+'));
    
    // Filter out common words, short words, and non-alphabetic words
    final vocabulary = words.where((word) {
      final cleaned = word.replaceAll(RegExp(r'[^\w]'), '');
      return cleaned.length > 3 && RegExp(r'^[a-zA-Z]+$').hasMatch(cleaned);
    }).toSet().toList();
    
    return vocabulary;
  }
  
  // Extract grammar points from conversation
  List<String> extractGrammarPoints(String conversation) {
    final text = _cleanText(conversation);
    final grammarPoints = <String>[];
    
    // Check for various grammar structures
    // Past tense
    if (RegExp(r'\b(was|were|had|did)\b').hasMatch(text)) {
      grammarPoints.add('Past Simple');
    }
    
    // Present perfect
    if (RegExp(r'\b(have|has)\s+\w+ed\b').hasMatch(text)) {
      grammarPoints.add('Present Perfect');
    }
    
    // Past perfect
    if (RegExp(r'\b(had)\s+\w+ed\b').hasMatch(text)) {
      grammarPoints.add('Past Perfect');
    }
    
    // Future tense
    if (RegExp(r'\b(will|going to)\b').hasMatch(text)) {
      grammarPoints.add('Future Tense');
    }
    
    // Conditionals
    if (RegExp(r'\bif\b.*\bwould\b').hasMatch(text)) {
      grammarPoints.add('Conditionals');
    }
    
    // Passive voice
    if (RegExp(r'\b(is|are|was|were)\s+\w+ed\b').hasMatch(text)) {
      grammarPoints.add('Passive Voice');
    }
    
    return grammarPoints;
  }
}
