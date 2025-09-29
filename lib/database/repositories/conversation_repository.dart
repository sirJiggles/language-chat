import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../database_service.dart';
import '../models/conversation_db.dart';

/// Repository for managing conversations in the database
class ConversationRepository {
  Isar get _isar => DatabaseService.isar;
  
  /// Get all archived conversations, sorted by most recent first
  Future<List<ConversationDB>> getAllArchived() async {
    final results = await _isar.conversationDBs
        .filter()
        .isArchivedEqualTo(true)
        .findAll();
    
    // Sort manually by timestamp descending
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }
  
  /// Get a conversation by ID
  Future<ConversationDB?> getById(int id) async {
    return await _isar.conversationDBs.get(id);
  }
  
  /// Save a new conversation
  Future<int> save(ConversationDB conversation) async {
    return await _isar.writeTxn(() async {
      return await _isar.conversationDBs.put(conversation);
    });
  }
  
  /// Archive a conversation
  Future<void> archive(ConversationDB conversation) async {
    conversation.isArchived = true;
    await save(conversation);
    debugPrint('Conversation archived: ${conversation.title}');
  }
  
  /// Delete a conversation
  Future<bool> delete(int id) async {
    return await _isar.writeTxn(() async {
      return await _isar.conversationDBs.delete(id);
    });
  }
  
  /// Delete all archived conversations
  Future<int> deleteAllArchived() async {
    return await _isar.writeTxn(() async {
      return await _isar.conversationDBs
          .filter()
          .isArchivedEqualTo(true)
          .deleteAll();
    });
  }
  
  /// Search conversations by content
  Future<List<ConversationDB>> search(String query) async {
    final lowerQuery = query.toLowerCase();
    
    // Get all conversations and filter manually
    final allConversations = await _isar.conversationDBs.where().findAll();
    
    return allConversations.where((conv) {
      // Search in title
      if (conv.title.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      // Search in messages
      for (final message in conv.messages) {
        if (message.content.toLowerCase().contains(lowerQuery)) {
          return true;
        }
      }
      
      return false;
    }).toList();
  }
  
  /// Get conversations from a date range
  Future<List<ConversationDB>> getByDateRange(DateTime start, DateTime end) async {
    final results = await _isar.conversationDBs
        .filter()
        .timestampBetween(start, end)
        .findAll();
    
    // Sort manually by timestamp descending
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }
  
  /// Get total message count across all conversations
  Future<int> getTotalMessageCount() async {
    final conversations = await _isar.conversationDBs.where().findAll();
    return conversations.fold<int>(0, (sum, conv) => sum + conv.messages.length);
  }
  
  /// Get conversation count
  Future<int> getCount() async {
    return await _isar.conversationDBs.count();
  }
  
  /// Get archived conversation count
  Future<int> getArchivedCount() async {
    return await _isar.conversationDBs
        .filter()
        .isArchivedEqualTo(true)
        .count();
  }
}
