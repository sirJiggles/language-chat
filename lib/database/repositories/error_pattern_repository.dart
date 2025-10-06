import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../database_service.dart';
import '../models/error_pattern_db.dart';

/// Repository for managing error patterns in the database
class ErrorPatternRepository {
  Isar get _isar => DatabaseService.isar;
  
  /// Save error pattern
  Future<int> saveError(ErrorPatternDB error) async {
    return await _isar.writeTxn(() async {
      return await _isar.errorPatternDBs.put(error);
    });
  }
  
  /// Get all errors for a session
  Future<List<ErrorPatternDB>> getErrorsBySession(String sessionId) async {
    return await _isar.errorPatternDBs
        .filter()
        .sessionIdEqualTo(sessionId)
        .sortByTimestamp()
        .findAll();
  }
  
  /// Get errors by type
  Future<List<ErrorPatternDB>> getErrorsByType(String errorType) async {
    return await _isar.errorPatternDBs
        .filter()
        .errorTypeEqualTo(errorType)
        .sortByTimestampDesc()
        .findAll();
  }
  
  /// Get recurring errors
  Future<List<ErrorPatternDB>> getRecurringErrors() async {
    return await _isar.errorPatternDBs
        .filter()
        .recurringEqualTo(true)
        .sortByOccurrenceCountDesc()
        .findAll();
  }
  
  /// Get errors by category
  Future<List<ErrorPatternDB>> getErrorsByCategory(String category) async {
    return await _isar.errorPatternDBs
        .filter()
        .categoryEqualTo(category)
        .sortByTimestampDesc()
        .findAll();
  }
  
  /// Get recent errors
  Future<List<ErrorPatternDB>> getRecentErrors(int count) async {
    return await _isar.errorPatternDBs
        .where()
        .sortByTimestampDesc()
        .limit(count)
        .findAll();
  }
  
  /// Delete all errors
  Future<void> deleteAll() async {
    await _isar.writeTxn(() async {
      await _isar.errorPatternDBs.clear();
    });
    debugPrint('All error patterns cleared');
  }
  
  /// Get count of errors
  Future<int> getCount() async {
    return await _isar.errorPatternDBs.count();
  }
}
