import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks the student's language level over time based on conversation analysis
class LanguageLevelTracker extends ChangeNotifier {
  // Current estimated CEFR level
  String _currentLevel = 'A1';
  
  // History of level assessments
  final List<LevelAssessment> _levelHistory = [];
  
  // Confidence in current level (0.0 to 1.0)
  double _confidence = 0.5;
  
  // Last assessment timestamp
  DateTime? _lastAssessment;
  
  // Storage keys
  static const String _keyCurrentLevel = 'language_level_current';
  static const String _keyHistory = 'language_level_history';
  static const String _keyConfidence = 'language_level_confidence';
  static const String _keyLastAssessment = 'language_level_last_assessment';
  
  // CEFR levels in order
  static const List<String> cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  
  LanguageLevelTracker() {
    _loadData();
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
    
    await _saveData();
    notifyListeners();
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
    await _saveData();
    notifyListeners();
  }
  
  /// Load data from persistent storage
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _currentLevel = prefs.getString(_keyCurrentLevel) ?? 'A1';
      _confidence = prefs.getDouble(_keyConfidence) ?? 0.5;
      
      final lastAssessmentStr = prefs.getString(_keyLastAssessment);
      if (lastAssessmentStr != null) {
        _lastAssessment = DateTime.parse(lastAssessmentStr);
      }
      
      final historyJson = prefs.getString(_keyHistory);
      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _levelHistory.clear();
        _levelHistory.addAll(
          decoded.map((item) => LevelAssessment.fromJson(item as Map<String, dynamic>)),
        );
      }
      
      debugPrint('Loaded language level: $_currentLevel (confidence: ${(_confidence * 100).toStringAsFixed(0)}%)');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language level data: $e');
    }
  }
  
  /// Save data to persistent storage
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_keyCurrentLevel, _currentLevel);
      await prefs.setDouble(_keyConfidence, _confidence);
      
      if (_lastAssessment != null) {
        await prefs.setString(_keyLastAssessment, _lastAssessment!.toIso8601String());
      }
      
      final historyJson = jsonEncode(
        _levelHistory.map((a) => a.toJson()).toList(),
      );
      await prefs.setString(_keyHistory, historyJson);
      
      debugPrint('Saved language level data');
    } catch (e) {
      debugPrint('Error saving language level data: $e');
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
