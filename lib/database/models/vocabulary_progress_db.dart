import 'package:isar/isar.dart';

part 'vocabulary_progress_db.g.dart';

/// Tracks student's vocabulary usage and progress
@collection
class VocabularyProgressDB {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String word;  // The vocabulary word in target language
  
  @Index()
  late String level;  // A1, A2, B1, B2, C1, C2
  
  late DateTime firstUsed;
  late DateTime lastUsed;
  
  late int usageCount;
  late int correctUsageCount;
  late int incorrectUsageCount;
  
  late bool mastered;  // Used correctly multiple times (e.g., 3+ times)
  
  String? translationOrMeaning;  // Optional: what this word means
  
  List<String> contextExamples = [];  // Example sentences where word was used
}
