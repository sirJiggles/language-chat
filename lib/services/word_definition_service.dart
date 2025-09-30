import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WordDefinitionService {
  final String? _openaiApiKey;
  
  WordDefinitionService({required String? openaiApiKey})
      : _openaiApiKey = openaiApiKey;
  
  /// Get a short definition of a word in the user's native language
  /// Returns a brief explanation without audio
  Future<String> getWordDefinition({
    required String word,
    required String targetLanguage,
    required String nativeLanguage,
  }) async {
    if (_openaiApiKey == null || _openaiApiKey.isEmpty) {
      throw Exception('OpenAI API key is not configured');
    }
    
    try {
      final systemPrompt = 'You are a language learning assistant. '
          'Provide a very brief, concise definition of words in the user\'s native language. '
          'Keep your response to 1-2 sentences maximum. '
          'Focus on the most common meaning in the context of language learning.';
      
      final userPrompt = 'Define the $targetLanguage word "$word" in $nativeLanguage. '
          'Keep it very short and simple.';
      
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
          'temperature': 0.3,
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final definition = data['choices'][0]['message']['content'] ?? '';
        return definition.trim();
      } else {
        throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting word definition: $e');
      throw Exception('Failed to get word definition: $e');
    }
  }
}
