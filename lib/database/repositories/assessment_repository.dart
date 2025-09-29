import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../database_service.dart';
import '../models/assessment_db.dart';

/// Repository for managing assessments and level history in the database
class AssessmentRepository {
  Isar get _isar => DatabaseService.isar;
  
  /// Save an assessment
  Future<int> saveAssessment(AssessmentDB assessment) async {
    return await _isar.writeTxn(() async {
      return await _isar.assessmentDBs.put(assessment);
    });
  }
  
  /// Save a level history entry
  Future<int> saveLevelHistory(LevelHistoryDB history) async {
    return await _isar.writeTxn(() async {
      return await _isar.levelHistoryDBs.put(history);
    });
  }
  
  /// Get all assessments, sorted by most recent first
  Future<List<AssessmentDB>> getAllAssessments() async {
    final results = await _isar.assessmentDBs.where().findAll();
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }
  
  /// Get all level history, sorted by most recent first
  Future<List<LevelHistoryDB>> getAllLevelHistory() async {
    final results = await _isar.levelHistoryDBs.where().findAll();
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }
  
  /// Get the most recent assessment
  Future<AssessmentDB?> getLatestAssessment() async {
    final assessments = await getAllAssessments();
    return assessments.isEmpty ? null : assessments.first;
  }
  
  /// Get the most recent level history entry
  Future<LevelHistoryDB?> getLatestLevelHistory() async {
    final history = await getAllLevelHistory();
    return history.isEmpty ? null : history.first;
  }
  
  /// Get assessments from a date range
  Future<List<AssessmentDB>> getAssessmentsByDateRange(DateTime start, DateTime end) async {
    final allAssessments = await getAllAssessments();
    return allAssessments
        .where((a) => a.timestamp.isAfter(start) && a.timestamp.isBefore(end))
        .toList();
  }
  
  /// Get level history from a date range
  Future<List<LevelHistoryDB>> getLevelHistoryByDateRange(DateTime start, DateTime end) async {
    final allHistory = await getAllLevelHistory();
    return allHistory
        .where((h) => h.timestamp.isAfter(start) && h.timestamp.isBefore(end))
        .toList();
  }
  
  /// Get assessments for a specific level
  Future<List<AssessmentDB>> getAssessmentsByLevel(String level) async {
    return await _isar.assessmentDBs
        .filter()
        .levelEqualTo(level)
        .findAll();
  }
  
  /// Get average confidence across all assessments
  Future<double> getAverageConfidence() async {
    final assessments = await getAllAssessments();
    if (assessments.isEmpty) return 0.0;
    
    final totalConfidence = assessments.fold<double>(
      0.0,
      (sum, assessment) => sum + assessment.confidence,
    );
    
    return totalConfidence / assessments.length;
  }
  
  /// Delete all assessments
  Future<void> deleteAllAssessments() async {
    await _isar.writeTxn(() async {
      await _isar.assessmentDBs.clear();
    });
    debugPrint('All assessments cleared');
  }
  
  /// Delete all level history
  Future<void> deleteAllLevelHistory() async {
    await _isar.writeTxn(() async {
      await _isar.levelHistoryDBs.clear();
    });
    debugPrint('All level history cleared');
  }
  
  /// Get assessment count
  Future<int> getAssessmentCount() async {
    return await _isar.assessmentDBs.count();
  }
  
  /// Get level history count
  Future<int> getLevelHistoryCount() async {
    return await _isar.levelHistoryDBs.count();
  }
}
