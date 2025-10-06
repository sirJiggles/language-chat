import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for getting clarifications/explanations of messages
class ClarificationService extends ChangeNotifier {
  final String? _openaiApiKey;
  
  ClarificationService({String? openaiApiKey}) : _openaiApiKey = openaiApiKey;
  
  /// Get a clarification of a message in the user's native language
  /// [message] - The message to clarify
  /// [targetLanguage] - The language the message is in
  /// [nativeLanguage] - The user's native language to translate to
  /// [recentMessages] - Recent conversation context for better translation
  Future<String> getClarification({
    required String message,
    required String targetLanguage,
    required String nativeLanguage,
    List<String>? recentMessages,
  }) async {
    if (_openaiApiKey == null || _openaiApiKey.isEmpty) {
      throw Exception('OpenAI API key is not configured');
    }
    
    try {
      final systemPrompt = 'You are a helpful translation assistant. '
          'Translate $targetLanguage messages to $nativeLanguage clearly and naturally. '
          'Use conversation context to provide accurate translations, especially for pronouns and references.';
      
      String userPrompt = '';
      if (recentMessages != null && recentMessages.isNotEmpty) {
        userPrompt = 'Here\'s the recent conversation for context:\n\n';
        userPrompt += recentMessages.join('\n');
        userPrompt += '\n\nNow translate this message to $nativeLanguage:\n"$message"';
      } else {
        userPrompt = 'Translate this $targetLanguage message to $nativeLanguage:\n\n"$message"';
      }
      
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openaiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.3, // Lower temperature for more consistent translations
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'Unable to generate clarification';
      } else {
        throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting clarification: $e');
      throw Exception('Failed to get clarification: $e');
    }
  }
}
