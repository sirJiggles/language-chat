import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'audio_player_service.dart';

typedef PlaybackCompleteCallback = void Function();

class OpenAITtsService {
  final String _apiKey;
  final AudioPlayerService _audioPlayer = AudioPlayerService();
  bool _isSpeaking = false;
  String? _lastSpokenText;
  String _currentVoice = 'nova'; // Default OpenAI voice
  PlaybackCompleteCallback? _onPlaybackComplete;

  // Available OpenAI TTS voices
  static const List<Map<String, String>> availableVoices = [
    {'id': 'alloy', 'name': 'Alloy', 'description': 'Versatile, general purpose voice'},
    {'id': 'echo', 'name': 'Echo', 'description': 'Clear and crisp voice'},
    {'id': 'fable', 'name': 'Fable', 'description': 'Narrative and storytelling voice'},
    {'id': 'onyx', 'name': 'Onyx', 'description': 'Deep and authoritative voice'},
    {'id': 'nova', 'name': 'Nova', 'description': 'Energetic and bright voice'},
    {'id': 'shimmer', 'name': 'Shimmer', 'description': 'Warm and pleasant voice'},
  ];

  OpenAITtsService({required String apiKey}) : _apiKey = apiKey {
    debugPrint('OpenAI TTS: Service initialized');
    // Set up audio player completion callback
    _audioPlayer.onPlaybackComplete = _handlePlaybackComplete;
  }
  
  void _handlePlaybackComplete() {
    debugPrint('OpenAI TTS: Audio playback completed callback triggered');
    _isSpeaking = false;
    debugPrint('OpenAI TTS: Set isSpeaking=false');
    
    // Notify listeners if callback is set
    if (_onPlaybackComplete != null) {
      debugPrint('OpenAI TTS: Calling onPlaybackComplete callback');
      _onPlaybackComplete!();
    } else {
      debugPrint('OpenAI TTS: No onPlaybackComplete callback set');
    }
  }

  bool get isSpeaking => _isSpeaking;
  String? get lastSpokenText => _lastSpokenText;
  String get currentVoice => _currentVoice;
  
  /// Set a callback to be called when playback completes
  set onPlaybackComplete(PlaybackCompleteCallback callback) {
    _onPlaybackComplete = callback;
  }
  
  List<Map<String, String>> get voices => availableVoices;

  void setVoice(String voiceId) {
    if (availableVoices.any((v) => v['id'] == voiceId)) {
      _currentVoice = voiceId;
    }
  }

  /// Generate and play speech from text
  /// Returns the audio data if successful, null otherwise
  Future<Uint8List?> speak(String text) async {
    debugPrint('OpenAI TTS: speak method called with text length ${text.length}');
    if (text.isEmpty) {
      debugPrint('OpenAI TTS: Empty text, nothing to speak');
      return null;
    }
    
    if (_apiKey.isEmpty) {
      debugPrint('OpenAI TTS: No API key provided');
      throw Exception('OpenAI API key is not configured');
    }
    
    // Skip if already speaking
    if (_isSpeaking) {
      debugPrint('OpenAI TTS: Already speaking, stopping first');
      await stop();
      // Small delay to ensure stop completes
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _lastSpokenText = text;
    _isSpeaking = true;
    debugPrint('OpenAI TTS: Set isSpeaking=true');
    debugPrint('OpenAI TTS: Starting to speak with voice $_currentVoice');
    
    try {
      debugPrint('OpenAI TTS: Generating speech from text');
      final audioData = await _generateSpeech(text);
      if (audioData != null) {
        debugPrint('OpenAI TTS: Audio data generated successfully, playing audio');
        await playAudio(audioData);
        debugPrint('OpenAI TTS: playAudio method returned');
        return audioData; // Return the audio data for caching
      } else {
        debugPrint('OpenAI TTS: No audio data generated');
        _isSpeaking = false;
      }
    } catch (e) {
      debugPrint('Error in OpenAI TTS: $e');
      _isSpeaking = false;
    }
    return null; // Return null if there was an error
  }

  Future<Uint8List?> _generateSpeech(String text) async {
    try {
      debugPrint('OpenAI TTS: Sending request to API');
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/audio/speech'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'tts-1',
          'input': text,
          'voice': _currentVoice,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('OpenAI TTS: Successfully received audio data');
        return response.bodyBytes;
      } else {
        final errorMsg = 'OpenAI TTS API error: ${response.statusCode} - ${response.body}';
        debugPrint(errorMsg);
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error generating speech: $e');
      throw e; // Re-throw to handle in the calling function
    }
  }

  /// Play audio from bytes
  Future<void> playAudio(Uint8List audioData) async {
    try {
      debugPrint('OpenAI TTS: Playing audio bytes of size ${audioData.length}');
      // Play the audio directly from bytes
      await _audioPlayer.playBytes(audioData);
      
      // Update speaking state based on player state
      _isSpeaking = _audioPlayer.isPlaying;
      debugPrint('OpenAI TTS: After playBytes, isPlaying=${_audioPlayer.isPlaying}');
    } catch (e) {
      debugPrint('OpenAI TTS: Error playing audio: $e');
      _isSpeaking = false;
    }
  }

  Future<void> stop() async {
    if (_isSpeaking) {
      await _audioPlayer.stop();
      _isSpeaking = false;
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
