import 'package:isar/isar.dart';

part 'student_fact_db.g.dart';

/// Represents a fact about the student stored in the database
@collection
class StudentFactDB {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String key;  // e.g., "student_name", "pet_name", "hobby"
  
  late String value;
  
  @Index()
  late DateTime discoveredAt;
  
  late DateTime updatedAt;
}
