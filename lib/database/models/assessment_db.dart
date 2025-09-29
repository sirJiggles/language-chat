import 'package:isar/isar.dart';

part 'assessment_db.g.dart';

/// Represents a language level assessment stored in the database
@collection
class AssessmentDB {
  Id id = Isar.autoIncrement;
  
  @Index()
  late DateTime timestamp;
  
  late String level;  // A1, A2, B1, B2, C1, C2
  late double confidence;  // 0.0 to 1.0
  late String reasoning;
  late int messageCount;  // Number of messages at time of assessment
}

/// Represents a level history entry for tracking progress
@collection
class LevelHistoryDB {
  Id id = Isar.autoIncrement;
  
  @Index()
  late DateTime timestamp;
  
  late String level;
  late double confidence;
  late String reasoning;
}
