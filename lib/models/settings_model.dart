import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ChatProvider {
  ollama,
  chatgpt,
}

enum TtsProvider {
  system,  // Default Flutter TTS
  openai,  // OpenAI TTS API
}

class SettingsModel extends ChangeNotifier {
  static const String _chatProviderKey = 'chat_provider';
  static const String _ttsProviderKey = 'tts_provider';
  static const String _openaiTtsVoiceKey = 'openai_tts_voice';
  
  ChatProvider _chatProvider = ChatProvider.ollama;
  TtsProvider _ttsProvider = TtsProvider.system;
  String _openaiTtsVoice = 'alloy'; // Default OpenAI voice
  
  ChatProvider get chatProvider => _chatProvider;
  TtsProvider get ttsProvider => _ttsProvider;
  String get openaiTtsVoice => _openaiTtsVoice;
  
  SettingsModel() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load chat provider
    final chatProviderString = prefs.getString(_chatProviderKey);
    if (chatProviderString != null) {
      try {
        _chatProvider = ChatProvider.values.firstWhere(
          (e) => e.toString() == 'ChatProvider.$chatProviderString',
          orElse: () => ChatProvider.ollama,
        );
      } catch (_) {
        _chatProvider = ChatProvider.ollama;
      }
    }
    
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
  
  Future<void> setChatProvider(ChatProvider provider) async {
    if (_chatProvider != provider) {
      _chatProvider = provider;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chatProviderKey, provider.toString().split('.').last);
      
      notifyListeners();
    }
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
