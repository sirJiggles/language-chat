import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TtsProvider {
  system,  // Default Flutter TTS
  openai,  // OpenAI TTS API
}

class SettingsModel extends ChangeNotifier {
  static const String _ttsProviderKey = 'tts_provider';
  static const String _openaiTtsVoiceKey = 'openai_tts_voice';
  static const String _nativeLanguageKey = 'native_language';
  static const String _audioEnabledKey = 'audio_enabled';
  static const String _darkModeKey = 'dark_mode';
  static const String _conversationModeKey = 'conversation_mode';
  static const String _profilePictureKey = 'profile_picture';
  
  TtsProvider _ttsProvider = TtsProvider.openai; // Default to OpenAI
  String _openaiTtsVoice = 'nova'; // Default OpenAI voice
  String _nativeLanguage = 'English'; // Default native language
  bool _audioEnabled = true; // Default audio on
  bool _isDarkMode = false; // Default light mode on
  bool _conversationMode = true; // Default conversation mode on
  String? _profilePicturePath; // Profile picture path
  
  TtsProvider get ttsProvider => _ttsProvider;
  String get openaiTtsVoice => _openaiTtsVoice;
  String get nativeLanguage => _nativeLanguage;
  bool get audioEnabled => _audioEnabled;
  bool get isDarkMode => _isDarkMode;
  bool get conversationMode => _conversationMode;
  String? get profilePicturePath => _profilePicturePath;
  
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
    
    // Load native language
    final nativeLang = prefs.getString(_nativeLanguageKey);
    if (nativeLang != null && nativeLang.isNotEmpty) {
      _nativeLanguage = nativeLang;
    }
    
    // Load audio enabled
    _audioEnabled = prefs.getBool(_audioEnabledKey) ?? true;
    
    // Load dark mode
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    
    // Load conversation mode
    _conversationMode = prefs.getBool(_conversationModeKey) ?? true;
    
    // Load profile picture path
    _profilePicturePath = prefs.getString(_profilePictureKey);
    
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
  
  Future<void> setNativeLanguage(String language) async {
    if (_nativeLanguage != language) {
      _nativeLanguage = language;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_nativeLanguageKey, language);
      
      notifyListeners();
    }
  }
  
  Future<void> setAudioEnabled(bool enabled) async {
    if (_audioEnabled != enabled) {
      _audioEnabled = enabled;
      
      // Conversation mode requires audio, so disable it when audio is disabled
      if (!enabled && _conversationMode) {
        _conversationMode = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_conversationModeKey, false);
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_audioEnabledKey, enabled);
      
      notifyListeners();
    }
  }
  
  Future<void> setDarkMode(bool enabled) async {
    if (_isDarkMode != enabled) {
      _isDarkMode = enabled;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, enabled);
      
      notifyListeners();
    }
  }
  
  Future<void> setConversationMode(bool enabled) async {
    if (_conversationMode != enabled) {
      _conversationMode = enabled;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_conversationModeKey, enabled);
      
      notifyListeners();
    }
  }
  
  Future<void> setProfilePicture(String? path) async {
    _profilePicturePath = path;
    
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString(_profilePictureKey, path);
    } else {
      await prefs.remove(_profilePictureKey);
    }
    
    notifyListeners();
  }
}
