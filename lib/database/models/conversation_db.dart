import 'package:isar/isar.dart';

part 'conversation_db.g.dart';

/// Represents a conversation stored in the database
@collection
class ConversationDB {
  Id id = Isar.autoIncrement;
  
  @Index()
  late DateTime timestamp;
  
  late String title;
  late bool isArchived;
  
  List<MessageDB> messages = [];
}

/// Represents a message within a conversation
@embedded
class MessageDB {
  late String content;
  late bool isUser;
  late DateTime timestamp;
}
