import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../database_service.dart';
import '../models/student_fact_db.dart';

/// Repository for managing student facts in the database
class StudentFactRepository {
  Isar get _isar => DatabaseService.isar;
  
  /// Get all student facts
  Future<List<StudentFactDB>> getAll() async {
    return await _isar.studentFactDBs.where().findAll();
  }
  
  /// Get a fact by key
  Future<StudentFactDB?> getByKey(String key) async {
    return await _isar.studentFactDBs
        .filter()
        .keyEqualTo(key)
        .findFirst();
  }
  
  /// Save or update a fact
  Future<int> save(StudentFactDB fact) async {
    return await _isar.writeTxn(() async {
      return await _isar.studentFactDBs.put(fact);
    });
  }
  
  /// Save or update a fact by key-value
  Future<void> saveFact(String key, String value) async {
    final existing = await getByKey(key);
    
    if (existing != null) {
      // Update existing
      existing.value = value;
      existing.updatedAt = DateTime.now();
      await save(existing);
      debugPrint('Updated fact: $key = $value');
    } else {
      // Create new
      final fact = StudentFactDB()
        ..key = key
        ..value = value
        ..discoveredAt = DateTime.now()
        ..updatedAt = DateTime.now();
      await save(fact);
      debugPrint('Created fact: $key = $value');
    }
  }
  
  /// Delete a fact by key
  Future<bool> deleteByKey(String key) async {
    final fact = await getByKey(key);
    if (fact == null) return false;
    
    return await _isar.writeTxn(() async {
      return await _isar.studentFactDBs.delete(fact.id);
    });
  }
  
  /// Delete all facts
  Future<void> deleteAll() async {
    await _isar.writeTxn(() async {
      await _isar.studentFactDBs.clear();
    });
    debugPrint('All student facts cleared');
  }
  
  /// Get facts as a map (key -> value)
  Future<Map<String, String>> getAsMap() async {
    final facts = await getAll();
    return Map.fromEntries(
      facts.map((f) => MapEntry(f.key, f.value)),
    );
  }
  
  /// Get recently discovered facts (last N days)
  Future<List<StudentFactDB>> getRecentlyDiscovered(int days) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final allFacts = await getAll();
    
    return allFacts.where((f) => f.discoveredAt.isAfter(cutoffDate)).toList()
      ..sort((a, b) => b.discoveredAt.compareTo(a.discoveredAt));
  }
  
  /// Get recently updated facts (last N days)
  Future<List<StudentFactDB>> getRecentlyUpdated(int days) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final allFacts = await getAll();
    
    return allFacts.where((f) => f.updatedAt.isAfter(cutoffDate)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
  
  /// Get fact count
  Future<int> getCount() async {
    return await _isar.studentFactDBs.count();
  }
}
