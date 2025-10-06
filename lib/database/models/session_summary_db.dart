import 'package:isar/isar.dart';

part 'session_summary_db.g.dart';

/// Aggregated metrics for a conversation session
@collection
class SessionSummaryDB {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String sessionId;
  
  @Index()
  late DateTime startTime;
  
  DateTime? endTime;
  
  // Aggregate metrics
  late int totalMessages;
  late int totalWords;
  late int uniqueWordsUsed;
  late double vocabularyDiversity;  // unique words / total words
  late double avgMessageLength;
  late int totalErrors;
  late double errorRate;  // errors per message
  
  // Progress indicators
  late List<String> topicsDiscussed;
  late List<String> newVocabulary;
  late List<String> grammarPointsUsed;
  
  // Assessment reference
  String? assessedLevel;  // Last assessed CEFR level for this session
  DateTime? lastAssessmentTime;
}
