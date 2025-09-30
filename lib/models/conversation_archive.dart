import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/repositories/conversation_repository.dart';
import '../database/models/conversation_db.dart';

/// Represents an archived conversation
class ArchivedConversation {
  final String id;
  final DateTime timestamp;
  final List<ArchivedMessage> messages;
  final String title; // Auto-generated or user-defined

  ArchivedConversation({
    required this.id,
    required this.timestamp,
    required this.messages,
    required this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'title': title,
    };
  }

  factory ArchivedConversation.fromJson(Map<String, dynamic> json) {
    return ArchivedConversation(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      messages: (json['messages'] as List)
          .map((m) => ArchivedMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String,
    );
  }
}

/// Represents a message in an archived conversation
class ArchivedMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ArchivedMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ArchivedMessage.fromJson(Map<String, dynamic> json) {
    return ArchivedMessage(
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Manages conversation archives using Isar database
class ConversationArchiveStore extends ChangeNotifier {
  static const String _legacyStorageKey = 'conversation_archives';
  final ConversationRepository _repository = ConversationRepository();
  final List<ArchivedConversation> _archives = [];
  bool _isInitialized = false;

  List<ArchivedConversation> get archives => List.unmodifiable(_archives);
  bool get isInitialized => _isInitialized;

  /// Initialize and load archives from Isar database
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Migrate from SharedPreferences if needed
      await _migrateFromSharedPreferences();
      
      // Load from Isar
      await _loadFromDatabase();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading archives: $e');
      _isInitialized = true;
    }
  }

  /// Migrate old SharedPreferences data to Isar
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? archivesJson = prefs.getString(_legacyStorageKey);
      
      if (archivesJson != null) {
        debugPrint('Found legacy archives in SharedPreferences, migrating to Isar...');
        final List<dynamic> decoded = jsonDecode(archivesJson);
        
        for (final item in decoded) {
          final archived = ArchivedConversation.fromJson(item as Map<String, dynamic>);
          
          // Convert to Isar model
          final conversationDB = ConversationDB()
            ..timestamp = archived.timestamp
            ..title = archived.title
            ..isArchived = true
            ..messages = archived.messages.map((m) => MessageDB()
              ..content = m.content
              ..isUser = m.isUser
              ..timestamp = m.timestamp
            ).toList();
          
          await _repository.save(conversationDB);
        }
        
        debugPrint('Migrated ${decoded.length} conversations to Isar');
        
        // Remove from SharedPreferences after successful migration
        await prefs.remove(_legacyStorageKey);
      }
    } catch (e) {
      debugPrint('Error migrating from SharedPreferences: $e');
    }
  }

  /// Load archives from Isar database
  Future<void> _loadFromDatabase() async {
    try {
      final conversationsDB = await _repository.getAllArchived();
      
      _archives.clear();
      _archives.addAll(conversationsDB.map((db) => ArchivedConversation(
        id: db.id.toString(),
        timestamp: db.timestamp,
        title: db.title,
        messages: db.messages.map((m) => ArchivedMessage(
          content: m.content,
          isUser: m.isUser,
          timestamp: m.timestamp,
        )).toList(),
      )));
      
      debugPrint('Loaded ${_archives.length} archived conversations from Isar');
    } catch (e) {
      debugPrint('Error loading from database: $e');
    }
  }

  /// Add a conversation to the archive
  Future<void> archiveConversation(ArchivedConversation conversation) async {
    // Save to Isar
    final conversationDB = ConversationDB()
      ..timestamp = conversation.timestamp
      ..title = conversation.title
      ..isArchived = true
      ..messages = conversation.messages.map((m) => MessageDB()
        ..content = m.content
        ..isUser = m.isUser
        ..timestamp = m.timestamp
      ).toList();
    
    final id = await _repository.save(conversationDB);
    
    // Update in-memory list
    final archived = ArchivedConversation(
      id: id.toString(),
      timestamp: conversation.timestamp,
      title: conversation.title,
      messages: conversation.messages,
    );
    
    _archives.insert(0, archived);
    notifyListeners();
    
    debugPrint('Conversation archived to Isar: ${conversation.title}');
  }

  /// Update an existing conversation in the archive
  Future<void> updateConversation(
    String id,
    List<ArchivedMessage> messages,
    String title,
  ) async {
    final numId = int.tryParse(id);
    if (numId == null) return;

    // Update in database
    final conversationDB = ConversationDB()
      ..id = numId
      ..timestamp = DateTime.now()
      ..title = title
      ..isArchived = true
      ..messages = messages.map((m) => MessageDB()
        ..content = m.content
        ..isUser = m.isUser
        ..timestamp = m.timestamp
      ).toList();
    
    await _repository.save(conversationDB);
    
    // Update in-memory list
    final index = _archives.indexWhere((conv) => conv.id == id);
    if (index != -1) {
      _archives[index] = ArchivedConversation(
        id: id,
        timestamp: DateTime.now(),
        title: title,
        messages: messages,
      );
      notifyListeners();
    }
    
    debugPrint('Conversation updated in Isar: $title');
  }

  /// Remove a conversation from the archive
  Future<void> deleteConversation(String id) async {
    final numId = int.tryParse(id);
    if (numId != null) {
      await _repository.delete(numId);
    }
    
    _archives.removeWhere((conv) => conv.id == id);
    notifyListeners();
    
    debugPrint('Conversation deleted from Isar: $id');
  }

  /// Get a specific conversation by ID
  ArchivedConversation? getConversation(String id) {
    try {
      return _archives.firstWhere((conv) => conv.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear all archives
  Future<void> clearAll() async {
    await _repository.deleteAllArchived();
    _archives.clear();
    notifyListeners();
    
    debugPrint('All archives cleared from Isar');
  }

  /// Generate a title from the first few messages
  static String generateTitle(List<ArchivedMessage> messages) {
    if (messages.isEmpty) return 'Empty Conversation';
    
    // Find first user message
    final firstUserMessage = messages.firstWhere(
      (m) => m.isUser,
      orElse: () => messages.first,
    );
    
    // Take first 30 characters
    String title = firstUserMessage.content;
    if (title.length > 30) {
      title = '${title.substring(0, 30)}...';
    }
    
    return title;
  }

  /// Get archives as JSON for persistence
  List<Map<String, dynamic>> toJson() {
    return _archives.map((a) => a.toJson()).toList();
  }

  /// Load archives from JSON
  void fromJson(List<dynamic> json) {
    _archives.clear();
    _archives.addAll(
      json.map((item) => ArchivedConversation.fromJson(item as Map<String, dynamic>)),
    );
    notifyListeners();
  }
}
