import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Manages conversation archives
class ConversationArchiveStore extends ChangeNotifier {
  static const String _storageKey = 'conversation_archives';
  final List<ArchivedConversation> _archives = [];
  bool _isInitialized = false;

  List<ArchivedConversation> get archives => List.unmodifiable(_archives);
  bool get isInitialized => _isInitialized;

  /// Initialize and load archives from storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? archivesJson = prefs.getString(_storageKey);
      
      if (archivesJson != null) {
        final List<dynamic> decoded = jsonDecode(archivesJson);
        _archives.clear();
        _archives.addAll(
          decoded.map((item) => ArchivedConversation.fromJson(item as Map<String, dynamic>)),
        );
        debugPrint('Loaded ${_archives.length} archived conversations');
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading archives: $e');
      _isInitialized = true;
    }
  }

  /// Save archives to storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> archivesJson = _archives.map((a) => a.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(archivesJson));
      debugPrint('Saved ${_archives.length} archived conversations');
    } catch (e) {
      debugPrint('Error saving archives: $e');
    }
  }

  /// Add a conversation to the archive
  Future<void> archiveConversation(ArchivedConversation conversation) async {
    _archives.insert(0, conversation); // Add to beginning (most recent first)
    await _saveToStorage();
    notifyListeners();
  }

  /// Remove a conversation from the archive
  Future<void> deleteConversation(String id) async {
    _archives.removeWhere((conv) => conv.id == id);
    await _saveToStorage();
    notifyListeners();
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
    _archives.clear();
    await _saveToStorage();
    notifyListeners();
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
