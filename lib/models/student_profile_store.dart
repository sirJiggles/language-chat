import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Store for student profile data - personal facts about the student
/// that help personalize conversations
class StudentProfileStore extends ChangeNotifier {
  // Key-value store for student facts
  final Map<String, dynamic> _profile = {};
  
  // Predefined categories for organization
  static const String categoryPersonal = 'personal';
  static const String categoryFamily = 'family';
  static const String categoryHobbies = 'hobbies';
  static const String categoryWork = 'work';
  static const String categoryOther = 'other';
  
  // Storage key
  static const String _storageKey = 'student_profile';
  
  StudentProfileStore() {
    _loadProfile();
  }
  
  /// Get all profile data
  Map<String, dynamic> get profile => Map.unmodifiable(_profile);
  
  /// Get a specific value from the profile
  dynamic getValue(String key) => _profile[key];
  
  /// Set a value in the profile
  Future<void> setValue(String key, dynamic value) async {
    _profile[key] = value;
    await _saveProfile();
    notifyListeners();
  }
  
  /// Set multiple values at once
  Future<void> setValues(Map<String, dynamic> values) async {
    _profile.addAll(values);
    await _saveProfile();
    notifyListeners();
  }
  
  /// Remove a value from the profile
  Future<void> removeValue(String key) async {
    _profile.remove(key);
    await _saveProfile();
    notifyListeners();
  }
  
  /// Clear all profile data
  Future<void> clearProfile() async {
    _profile.clear();
    await _saveProfile();
    notifyListeners();
  }
  
  /// Get profile data organized by category
  Map<String, Map<String, dynamic>> getProfileByCategory() {
    final categorized = <String, Map<String, dynamic>>{
      categoryPersonal: {},
      categoryFamily: {},
      categoryHobbies: {},
      categoryWork: {},
      categoryOther: {},
    };
    
    for (final entry in _profile.entries) {
      final category = _categorizeKey(entry.key);
      categorized[category]![entry.key] = entry.value;
    }
    
    return categorized;
  }
  
  /// Categorize a key based on its name
  String _categorizeKey(String key) {
    final lowerKey = key.toLowerCase();
    
    if (lowerKey.contains('name') || lowerKey.contains('age') || 
        lowerKey.contains('birthday') || lowerKey.contains('nationality')) {
      return categoryPersonal;
    }
    
    if (lowerKey.contains('family') || lowerKey.contains('parent') || 
        lowerKey.contains('sibling') || lowerKey.contains('child') ||
        lowerKey.contains('spouse') || lowerKey.contains('partner')) {
      return categoryFamily;
    }
    
    if (lowerKey.contains('hobby') || lowerKey.contains('sport') || 
        lowerKey.contains('music') || lowerKey.contains('game') ||
        lowerKey.contains('pet') || lowerKey.contains('interest')) {
      return categoryHobbies;
    }
    
    if (lowerKey.contains('job') || lowerKey.contains('work') || 
        lowerKey.contains('career') || lowerKey.contains('profession') ||
        lowerKey.contains('study') || lowerKey.contains('school')) {
      return categoryWork;
    }
    
    return categoryOther;
  }
  
  /// Get a formatted string of the profile for context injection
  String getProfileContext() {
    if (_profile.isEmpty) {
      return 'No student profile information available yet.';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('Student Profile:');
    
    final categorized = getProfileByCategory();
    
    for (final category in [categoryPersonal, categoryFamily, categoryHobbies, categoryWork, categoryOther]) {
      final items = categorized[category]!;
      if (items.isNotEmpty) {
        buffer.writeln('\n${_capitalizeFirst(category)}:');
        for (final entry in items.entries) {
          buffer.writeln('- ${_formatKey(entry.key)}: ${entry.value}');
        }
      }
    }
    
    return buffer.toString();
  }
  
  /// Format a key for display (e.g., "user_name" -> "User Name")
  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => _capitalizeFirst(word))
        .join(' ');
  }
  
  /// Capitalize first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  /// Load profile from persistent storage
  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_storageKey);
      
      if (profileJson != null) {
        final decoded = jsonDecode(profileJson) as Map<String, dynamic>;
        _profile.addAll(decoded);
        debugPrint('Loaded student profile with ${_profile.length} entries');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading student profile: $e');
    }
  }
  
  /// Save profile to persistent storage
  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(_profile);
      await prefs.setString(_storageKey, profileJson);
      debugPrint('Saved student profile with ${_profile.length} entries');
    } catch (e) {
      debugPrint('Error saving student profile: $e');
    }
  }
}
