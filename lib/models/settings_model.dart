import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TtsProvider {
  system,  // Default Flutter TTS
  openai,  // OpenAI TTS API
}

class SettingsModel extends ChangeNotifier {
  static const String _ttsProviderKey = 'tts_provider';
  static const String _openaiTtsVoiceKey = 'openai_tts_voice';
  
  TtsProvider _ttsProvider = TtsProvider.openai; // Default to OpenAI
  String _openaiTtsVoice = 'nova'; // Default OpenAI voice
  
  TtsProvider get ttsProvider => _ttsProvider;
  String get openaiTtsVoice => _openaiTtsVoice;
  
  SettingsModel() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load TTS provider
    final ttsProviderString = prefs.getString(_ttsProviderKey);
    if (ttsProviderString != null) {
      try {
        _ttsProvider = TtsProvider.values.firstWhere(
          (e) => e.toString() == 'TtsProvider.$ttsProviderString',
          orElse: () => TtsProvider.system,
        );
      } catch (_) {
        _ttsProvider = TtsProvider.system;
      }
    }
    
    // Load OpenAI TTS voice
    final openaiVoice = prefs.getString(_openaiTtsVoiceKey);
    if (openaiVoice != null && openaiVoice.isNotEmpty) {
      _openaiTtsVoice = openaiVoice;
    }
    
    notifyListeners();
  }
  
  Future<void> setTtsProvider(TtsProvider provider) async {
    if (_ttsProvider != provider) {
      _ttsProvider = provider;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ttsProviderKey, provider.toString().split('.').last);
      
      notifyListeners();
    }
  }
  
  Future<void> setOpenAITtsVoice(String voice) async {
    if (_openaiTtsVoice != voice) {
      _openaiTtsVoice = voice;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_openaiTtsVoiceKey, voice);
      
      notifyListeners();
    }
  }
}
