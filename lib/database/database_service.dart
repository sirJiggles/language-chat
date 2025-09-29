import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/conversation_db.dart';
import 'models/student_fact_db.dart';
import 'models/assessment_db.dart';

/// Service to manage Isar database initialization and access
class DatabaseService {
  static Isar? _isar;
  
  /// Get the Isar instance
  static Isar get isar {
    if (_isar == null) {
      throw Exception('Database not initialized. Call DatabaseService.initialize() first.');
    }
    return _isar!;
  }
  
  /// Check if database is initialized
  static bool get isInitialized => _isar != null;
  
  /// Initialize the Isar database
  static Future<void> initialize() async {
    if (_isar != null) {
      debugPrint('Database already initialized');
      return;
    }
    
    try {
      final dir = await getApplicationDocumentsDirectory();
      
      _isar = await Isar.open(
        [
          ConversationDBSchema,
          StudentFactDBSchema,
          AssessmentDBSchema,
          LevelHistoryDBSchema,
        ],
        directory: dir.path,
        name: 'language_learning_db',
      );
      
      debugPrint('Isar database initialized at: ${dir.path}');
      debugPrint('Database size: ${await _getDatabaseSize()}');
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }
  
  /// Close the database
  static Future<void> close() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
      debugPrint('Database closed');
    }
  }
  
  /// Get database statistics
  static Future<Map<String, int>> getStats() async {
    if (_isar == null) return {};
    
    return {
      'conversations': await _isar!.conversationDBs.count(),
      'facts': await _isar!.studentFactDBs.count(),
      'assessments': await _isar!.assessmentDBs.count(),
      'levelHistory': await _isar!.levelHistoryDBs.count(),
    };
  }
  
  /// Get database size in bytes
  static Future<int> _getDatabaseSize() async {
    if (_isar == null) return 0;
    return await _isar!.getSize();
  }
  
  /// Clear all data (for testing/debugging)
  static Future<void> clearAllData() async {
    if (_isar == null) return;
    
    await _isar!.writeTxn(() async {
      await _isar!.clear();
    });
    
    debugPrint('All database data cleared');
  }
}
