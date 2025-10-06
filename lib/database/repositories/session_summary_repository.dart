import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../database_service.dart';
import '../models/session_summary_db.dart';

/// Repository for managing session summaries in the database
class SessionSummaryRepository {
  Isar get _isar => DatabaseService.isar;
  
  /// Save or update session summary
  Future<int> saveSummary(SessionSummaryDB summary) async {
    return await _isar.writeTxn(() async {
      return await _isar.sessionSummaryDBs.put(summary);
    });
  }
  
  /// Get session summary by session ID
  Future<SessionSummaryDB?> getSummaryBySessionId(String sessionId) async {
    return await _isar.sessionSummaryDBs
        .filter()
        .sessionIdEqualTo(sessionId)
        .findFirst();
  }
  
  /// Get all session summaries
  Future<List<SessionSummaryDB>> getAllSummaries() async {
    return await _isar.sessionSummaryDBs
        .where()
        .sortByStartTimeDesc()
        .findAll();
  }
  
  /// Get recent sessions (last N)
  Future<List<SessionSummaryDB>> getRecentSessions(int count) async {
    return await _isar.sessionSummaryDBs
        .where()
        .sortByStartTimeDesc()
        .limit(count)
        .findAll();
  }
  
  /// Get active session (no end time)
  Future<SessionSummaryDB?> getActiveSession() async {
    return await _isar.sessionSummaryDBs
        .filter()
        .endTimeIsNull()
        .sortByStartTimeDesc()
        .findFirst();
  }
  
  /// Update session end time
  Future<void> endSession(String sessionId) async {
    await _isar.writeTxn(() async {
      final session = await getSummaryBySessionId(sessionId);
      if (session != null) {
        session.endTime = DateTime.now();
        await _isar.sessionSummaryDBs.put(session);
      }
    });
  }
  
  /// Delete all summaries
  Future<void> deleteAll() async {
    await _isar.writeTxn(() async {
      await _isar.sessionSummaryDBs.clear();
    });
    debugPrint('All session summaries cleared');
  }
  
  /// Get count of sessions
  Future<int> getCount() async {
    return await _isar.sessionSummaryDBs.count();
  }
}
