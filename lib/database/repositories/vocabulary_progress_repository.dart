import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../database_service.dart';
import '../models/vocabulary_progress_db.dart';

/// Repository for managing vocabulary progress in the database
class VocabularyProgressRepository {
  Isar get _isar => DatabaseService.isar;
  
  /// Save or update vocabulary entry
  Future<int> saveVocabulary(VocabularyProgressDB vocab) async {
    return await _isar.writeTxn(() async {
      return await _isar.vocabularyProgressDBs.put(vocab);
    });
  }
  
  /// Get vocabulary by word
  Future<VocabularyProgressDB?> getVocabularyByWord(String word) async {
    return await _isar.vocabularyProgressDBs
        .filter()
        .wordEqualTo(word)
        .findFirst();
  }
  
  /// Get vocabulary by level
  Future<List<VocabularyProgressDB>> getVocabularyByLevel(String level) async {
    return await _isar.vocabularyProgressDBs
        .filter()
        .levelEqualTo(level)
        .sortByLastUsedDesc()
        .findAll();
  }
  
  /// Get mastered vocabulary
  Future<List<VocabularyProgressDB>> getMasteredVocabulary() async {
    return await _isar.vocabularyProgressDBs
        .filter()
        .masteredEqualTo(true)
        .sortByLastUsedDesc()
        .findAll();
  }
  
  /// Get vocabulary in progress (not mastered)
  Future<List<VocabularyProgressDB>> getInProgressVocabulary() async {
    return await _isar.vocabularyProgressDBs
        .filter()
        .masteredEqualTo(false)
        .sortByLastUsedDesc()
        .findAll();
  }
  
  /// Get all vocabulary
  Future<List<VocabularyProgressDB>> getAllVocabulary() async {
    return await _isar.vocabularyProgressDBs
        .where()
        .sortByLastUsedDesc()
        .findAll();
  }
  
  /// Get vocabulary count by level
  Future<Map<String, int>> getVocabularyCountByLevel() async {
    final allVocab = await getAllVocabulary();
    final counts = <String, int>{};
    
    for (final vocab in allVocab) {
      counts[vocab.level] = (counts[vocab.level] ?? 0) + 1;
    }
    
    return counts;
  }
  
  /// Delete all vocabulary
  Future<void> deleteAll() async {
    await _isar.writeTxn(() async {
      await _isar.vocabularyProgressDBs.clear();
    });
    debugPrint('All vocabulary progress cleared');
  }
  
  /// Get count of vocabulary
  Future<int> getCount() async {
    return await _isar.vocabularyProgressDBs.count();
  }
  
  /// Get mastered vocabulary count
  Future<int> getMasteredCount() async {
    return await _isar.vocabularyProgressDBs
        .filter()
        .masteredEqualTo(true)
        .count();
  }
}
