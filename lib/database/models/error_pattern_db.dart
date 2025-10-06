import 'package:isar/isar.dart';

part 'error_pattern_db.g.dart';

/// Tracks recurring error patterns for targeted learning
@collection
class ErrorPatternDB {
  Id id = Isar.autoIncrement;
  
  @Index()
  late DateTime timestamp;
  
  @Index()
  late String errorType;  // e.g., "verb_conjugation", "word_order", "article_usage"
  
  late String context;  // The sentence/phrase with error
  late String correction;  // How it should be corrected
  
  @Index()
  late String category;  // "grammar", "vocabulary", "pronunciation", "syntax"
  
  late bool recurring;  // Has this error pattern appeared before?
  late int occurrenceCount;  // How many times this type of error has occurred
  
  late String sessionId;  // Link to the session where error occurred
}
