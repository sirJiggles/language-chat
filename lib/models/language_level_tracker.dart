import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/repositories/assessment_repository.dart';
import '../database/models/assessment_db.dart';

/// Tracks the student's language level over time based on conversation analysis (now using Isar)
class LanguageLevelTracker extends ChangeNotifier {
  final AssessmentRepository _repository = AssessmentRepository();
  
  // Current estimated CEFR level
  String _currentLevel = 'A1';
  
  // History of level assessments
  final List<LevelAssessment> _levelHistory = [];
  
  // Confidence in current level (0.0 to 1.0)
  double _confidence = 0.5;
  
  // Last assessment timestamp
  DateTime? _lastAssessment;
  
  // Legacy storage keys for migration
  static const String _legacyKeyCurrentLevel = 'language_level_current';
  static const String _legacyKeyHistory = 'language_level_history';
  static const String _legacyKeyConfidence = 'language_level_confidence';
  static const String _legacyKeyLastAssessment = 'language_level_last_assessment';
  
  // CEFR levels in order
  static const List<String> cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;
  
  /// Initialize and load data from database
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Migrate from SharedPreferences if needed
      await _migrateFromSharedPreferences();
      
      // Load from Isar
      await _loadData();
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing LanguageLevelTracker: $e');
      _isInitialized = true;
    }
  }
  
  /// Get current level
  String get currentLevel => _currentLevel;
  
  /// Get confidence in current level
  double get confidence => _confidence;
  
  /// Get level history
  List<LevelAssessment> get levelHistory => List.unmodifiable(_levelHistory);
  
  /// Get last assessment time
  DateTime? get lastAssessment => _lastAssessment;
  
  /// Get level description
  String getLevelDescription() {
    switch (_currentLevel) {
      case 'A1':
        return 'Beginner - Can understand and use familiar everyday expressions';
      case 'A2':
        return 'Elementary - Can communicate in simple routine tasks';
      case 'B1':
        return 'Intermediate - Can deal with most situations while traveling';
      case 'B2':
        return 'Upper Intermediate - Can interact with fluency and spontaneity';
      case 'C1':
        return 'Advanced - Can express ideas fluently and spontaneously';
      case 'C2':
        return 'Proficient - Can express themselves spontaneously and precisely';
      default:
        return 'Unknown level';
    }
  }
  
  /// Update level based on new assessment
  Future<void> updateLevel(String newLevel, String reasoning, {double? confidence}) async {
    if (!cefrLevels.contains(newLevel)) {
      debugPrint('Invalid CEFR level: $newLevel');
      return;
    }
    
    final assessment = LevelAssessment(
      level: newLevel,
      reasoning: reasoning,
      timestamp: DateTime.now(),
      confidence: confidence ?? 0.7,
    );
    
    _levelHistory.add(assessment);
    _lastAssessment = assessment.timestamp;
    
    // Update current level if it's different
    if (_currentLevel != newLevel) {
      debugPrint('Language level changed: $_currentLevel -> $newLevel');
      _currentLevel = newLevel;
    }
    
    // Update confidence based on consistency
    _updateConfidence();
    
    // Keep only last 20 assessments
    if (_levelHistory.length > 20) {
      _levelHistory.removeAt(0);
    }
    
    // Save to Isar
    await _saveToDatabase(assessment);
    notifyListeners();
  }
  
  /// Save assessment to database
  Future<void> _saveToDatabase(LevelAssessment assessment) async {
    try {
      // Save to level history
      final historyDB = LevelHistoryDB()
        ..timestamp = assessment.timestamp
        ..level = assessment.level
        ..confidence = assessment.confidence
        ..reasoning = assessment.reasoning;
      
      await _repository.saveLevelHistory(historyDB);
      debugPrint('Saved level assessment to Isar: ${assessment.level}');
    } catch (e) {
      debugPrint('Error saving assessment to database: $e');
    }
  }
  
  /// Calculate confidence based on recent assessment consistency
  void _updateConfidence() {
    if (_levelHistory.length < 3) {
      _confidence = 0.5;
      return;
    }
    
    // Look at last 5 assessments
    final recentCount = _levelHistory.length < 5 ? _levelHistory.length : 5;
    final recent = _levelHistory.sublist(_levelHistory.length - recentCount);
    
    // Count how many match current level
    final matchCount = recent.where((a) => a.level == _currentLevel).length;
    
    // Calculate confidence (higher if more consistent)
    _confidence = matchCount / recentCount;
    
    // Adjust based on adjacent levels (B1 and B2 are closer than A1 and C2)
    final currentIndex = cefrLevels.indexOf(_currentLevel);
    for (final assessment in recent) {
      final assessmentIndex = cefrLevels.indexOf(assessment.level);
      final distance = (currentIndex - assessmentIndex).abs();
      
      // If assessments are within 1 level, increase confidence slightly
      if (distance == 1) {
        _confidence += 0.05;
      }
    }
    
    // Clamp confidence between 0.3 and 1.0
    _confidence = _confidence.clamp(0.3, 1.0);
  }
  
  /// Get trend (improving, stable, or declining)
  String getTrend() {
    if (_levelHistory.length < 3) {
      return 'Not enough data';
    }
    
    final recentCount = _levelHistory.length < 5 ? _levelHistory.length : 5;
    final recent = _levelHistory.sublist(_levelHistory.length - recentCount);
    
    final levels = recent.map((a) => cefrLevels.indexOf(a.level)).toList();
    
    // Calculate average change
    int totalChange = 0;
    for (int i = 1; i < levels.length; i++) {
      totalChange += levels[i] - levels[i - 1];
    }
    
    if (totalChange > 0) {
      return 'Improving';
    } else if (totalChange < 0) {
      return 'Needs attention';
    } else {
      return 'Stable';
    }
  }
  
  /// Get formatted context for AI
  String getLevelContext() {
    final buffer = StringBuffer();
    buffer.writeln('Student Language Level: $_currentLevel (${getLevelDescription()})');
    buffer.writeln('Confidence: ${(_confidence * 100).toStringAsFixed(0)}%');
    buffer.writeln('Trend: ${getTrend()}');
    
    if (_lastAssessment != null) {
      final daysSince = DateTime.now().difference(_lastAssessment!).inDays;
      buffer.writeln('Last assessed: $daysSince days ago');
    }
    
    return buffer.toString();
  }
  
  /// Reset all data
  Future<void> reset() async {
    _currentLevel = 'A1';
    _levelHistory.clear();
    _confidence = 0.5;
    _lastAssessment = null;
    await _repository.deleteAllLevelHistory();
    notifyListeners();
  }
  
  /// Migrate from SharedPreferences to Isar
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if legacy data exists
      final historyJson = prefs.getString(_legacyKeyHistory);
      if (historyJson != null) {
        debugPrint('Found legacy level history in SharedPreferences, migrating to Isar...');
        final List<dynamic> decoded = jsonDecode(historyJson);
        
        for (final item in decoded) {
          final assessment = LevelAssessment.fromJson(item as Map<String, dynamic>);
          final historyDB = LevelHistoryDB()
            ..timestamp = assessment.timestamp
            ..level = assessment.level
            ..confidence = assessment.confidence
            ..reasoning = assessment.reasoning;
          
          await _repository.saveLevelHistory(historyDB);
        }
        
        debugPrint('Migrated ${decoded.length} level assessments to Isar');
        
        // Remove from SharedPreferences after successful migration
        await prefs.remove(_legacyKeyCurrentLevel);
        await prefs.remove(_legacyKeyHistory);
        await prefs.remove(_legacyKeyConfidence);
        await prefs.remove(_legacyKeyLastAssessment);
      }
    } catch (e) {
      debugPrint('Error migrating level history from SharedPreferences: $e');
    }
  }
  
  /// Load data from Isar database
  Future<void> _loadData() async {
    try {
      final historyDB = await _repository.getAllLevelHistory();
      
      _levelHistory.clear();
      _levelHistory.addAll(historyDB.map((db) => LevelAssessment(
        level: db.level,
        reasoning: db.reasoning,
        timestamp: db.timestamp,
        confidence: db.confidence,
      )));
      
      // Set current level from most recent assessment
      if (_levelHistory.isNotEmpty) {
        _currentLevel = _levelHistory.last.level;
        _lastAssessment = _levelHistory.last.timestamp;
        _updateConfidence();
      }
      
      debugPrint('Loaded language level from Isar: $_currentLevel (${_levelHistory.length} assessments)');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language level data: $e');
    }
  }
}

/// Represents a single level assessment
class LevelAssessment {
  final String level;
  final String reasoning;
  final DateTime timestamp;
  final double confidence;
  
  LevelAssessment({
    required this.level,
    required this.reasoning,
    required this.timestamp,
    required this.confidence,
  });
  
  Map<String, dynamic> toJson() => {
    'level': level,
    'reasoning': reasoning,
    'timestamp': timestamp.toIso8601String(),
    'confidence': confidence,
  };
  
  factory LevelAssessment.fromJson(Map<String, dynamic> json) => LevelAssessment(
    level: json['level'] as String,
    reasoning: json['reasoning'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    confidence: (json['confidence'] as num).toDouble(),
  );
}
