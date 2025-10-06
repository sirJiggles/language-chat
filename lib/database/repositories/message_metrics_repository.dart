import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../database_service.dart';
import '../models/message_metrics_db.dart';

/// Repository for managing message metrics in the database
class MessageMetricsRepository {
  Isar get _isar => DatabaseService.isar;
  
  /// Save message metrics
  Future<int> saveMetrics(MessageMetricsDB metrics) async {
    return await _isar.writeTxn(() async {
      return await _isar.messageMetricsDBs.put(metrics);
    });
  }
  
  /// Get metrics for a specific session
  Future<List<MessageMetricsDB>> getMetricsBySession(String sessionId) async {
    return await _isar.messageMetricsDBs
        .filter()
        .sessionIdEqualTo(sessionId)
        .sortByTimestamp()
        .findAll();
  }
  
  /// Get recent metrics (last N entries)
  Future<List<MessageMetricsDB>> getRecentMetrics(int count) async {
    return await _isar.messageMetricsDBs
        .where()
        .sortByTimestampDesc()
        .limit(count)
        .findAll();
  }
  
  /// Get metrics within a date range
  Future<List<MessageMetricsDB>> getMetricsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _isar.messageMetricsDBs
        .filter()
        .timestampBetween(start, end)
        .sortByTimestamp()
        .findAll();
  }
  
  /// Delete all metrics
  Future<void> deleteAll() async {
    await _isar.writeTxn(() async {
      await _isar.messageMetricsDBs.clear();
    });
    debugPrint('All message metrics cleared');
  }
  
  /// Get count of metrics
  Future<int> getCount() async {
    return await _isar.messageMetricsDBs.count();
  }
}
