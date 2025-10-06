import 'package:isar/isar.dart';

part 'message_metrics_db.g.dart';

/// Tracks metrics for individual message exchanges
@collection
class MessageMetricsDB {
  Id id = Isar.autoIncrement;
  
  @Index()
  late DateTime timestamp;
  
  @Index()
  late String sessionId;  // Links to conversation session
  
  // Message content analysis
  late int wordCount;
  late int uniqueWordCount;
  late double avgWordLength;
  late int sentenceCount;
  
  // Lists of identified elements
  late List<String> vocabularyUsed;
  late List<String> grammarStructures;
  
  // Error tracking
  late int errorCount;
  late List<String> errorTypes;
  
  // User message for reference
  late String userMessage;
  
  // AI response for reference (optional)
  String? aiResponse;
}
