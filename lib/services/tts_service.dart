import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import '../models/settings_model.dart';
import 'openai_tts_service.dart';

/// A class to store audio data with its associated text and metadata
class AudioCacheEntry {
  final String text;
  final Uint8List audioData;
  final DateTime timestamp;
  final String voice;
  
  AudioCacheEntry({
    required this.text,
    required this.audioData,
    required this.timestamp,
    required this.voice,
  });
}

class TtsService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  OpenAITtsService? _openAITts;
  final SettingsModel _settingsModel;
  bool _isSpeaking = false;
  String? _lastSpokenText;
  
  // Audio cache - stores the last 5 messages
  final int _maxCacheSize = 5;
  final Map<String, AudioCacheEntry> _audioCache = {};
  
  // Get a sorted list of cache entries (most recent first)
  List<AudioCacheEntry> get cachedEntries => 
      _audioCache.values.sorted((a, b) => b.timestamp.compareTo(a.timestamp)).toList();
  
  /// Add an entry to the audio cache
  void _addToCache(String text, Uint8List audioData, String voice) {
    // Create a normalized key for the cache (lowercase, trimmed)
    final key = text.trim().toLowerCase();
    
    // Add or update the cache entry
    _audioCache[key] = AudioCacheEntry(
      text: text,
      audioData: audioData,
      timestamp: DateTime.now(),
      voice: voice,
    );
    
    // Enforce the cache size limit (LRU policy)
    _enforceCacheLimit();
    
    debugPrint('TTS Service: Added "${text.substring(0, text.length > 20 ? 20 : text.length)}..." to audio cache');
    debugPrint('TTS Service: Cache now contains ${_audioCache.length} entries');
  }
  
  /// Get an entry from the audio cache if available
  AudioCacheEntry? _getFromCache(String text) {
    // Create a normalized key for the cache (lowercase, trimmed)
    final key = text.trim().toLowerCase();
    
    // Check if the entry exists in the cache
    final entry = _audioCache[key];
    
    if (entry != null) {
      // Update the timestamp to mark it as recently used
      _audioCache[key] = AudioCacheEntry(
        text: entry.text,
        audioData: entry.audioData,
        timestamp: DateTime.now(),
        voice: entry.voice,
      );
      
      debugPrint('TTS Service: Cache hit for "${text.substring(0, text.length > 20 ? 20 : text.length)}..."');
      return entry;
    }
    
    debugPrint('TTS Service: Cache miss for "${text.substring(0, text.length > 20 ? 20 : text.length)}..."');
    return null;
  }
  
  /// Enforce the cache size limit using LRU policy
  void _enforceCacheLimit() {
    if (_audioCache.length <= _maxCacheSize) return;
    
    // Sort entries by timestamp (oldest first)
    final sortedEntries = cachedEntries.reversed.toList();
    
    // Remove oldest entries until we're back at the limit
    while (_audioCache.length > _maxCacheSize) {
      final oldestEntry = sortedEntries.removeAt(0);
      final keyToRemove = oldestEntry.text.trim().toLowerCase();
      _audioCache.remove(keyToRemove);
      debugPrint('TTS Service: Removed oldest cache entry: "${oldestEntry.text.substring(0, oldestEntry.text.length > 20 ? 20 : oldestEntry.text.length)}..."');
    }
  }
  
  /// Clear the audio cache
  void clearCache() {
    _audioCache.clear();
    debugPrint('TTS Service: Audio cache cleared');
  }
  
  TtsService({required SettingsModel settingsModel, String? openaiApiKey}) : _settingsModel = settingsModel {
    // Initialize OpenAI TTS if API key is provided
    if (openaiApiKey != null && openaiApiKey.isNotEmpty) {
      _openAITts = OpenAITtsService(apiKey: openaiApiKey);
      if (_settingsModel.ttsProvider == TtsProvider.openai) {
        _openAITts!.setVoice(_settingsModel.openaiTtsVoice);
      }
      _openAIVoices = _openAITts!.voices;
      
      // Set up completion callback
      _openAITts!.onPlaybackComplete = () {
        _isSpeaking = false;
        debugPrint('TTS Service: OpenAI playback completed, notifying listeners');
        // Make sure to notify on the main thread
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      };
    }
  }

  // Env-driven defaults
  static const String _envTargetLanguage = String.fromEnvironment('TARGET_LANGUAGE', defaultValue: 'Spanish');
  
  // Runtime-updatable settings
  String _voiceName = '';
  String _preferredLanguage = _envTargetLanguage;
  List<Map<String, String>> _availableVoices = const [];
  final Map<String, String> _preferredVoicesByLang = {}; // langCode -> voiceName
  
  // OpenAI TTS settings
  List<Map<String, String>> _openAIVoices = const [];

  // Keys for shared preferences
  static const String _keyVoiceName = 'tts_voice_name';
  static const String _keyPreferredLanguage = 'tts_preferred_language';
  static const String _keyPreferredVoicesByLang = 'tts_preferred_voices_by_lang';

  bool get isSpeaking => _isSpeaking;
  String? get lastSpokenText => _lastSpokenText;
  String get voiceName => _voiceName;
  String get preferredLanguage => _preferredLanguage;
  List<Map<String, String>> get availableVoices => _availableVoices;
  String? getPreferredVoiceForLanguage(String langCode) => _preferredVoicesByLang[langCode];

  Future<void> initialize() async {
    // Load saved settings
    await _loadSettings();
    
    // Initialize OpenAI TTS if API key is provided
    if (_settingsModel.ttsProvider == TtsProvider.openai) {
      _initializeOpenAITts();
    }
    
    // Pick a suitable locale (language-region) based on TARGET_LANGUAGE
    final locale = _mapTargetLanguageToLocale(_preferredLanguage);

    // Set basic params
    await _flutterTts.setLanguage(locale);
    await _flutterTts.setSpeechRate(0.5); // Fixed rate
    await _flutterTts.setPitch(1.0);      // Fixed pitch
    await _flutterTts.setVolume(1.0);

    // Try to select a high-quality voice automatically
    try {
      final voices = await _flutterTts.getVoices;
      if (voices is List) {
        // cache simplified voices for UI (name/locale)
        final List<Map<String, String>> tempVoices = [];
        for (final v in voices) {
          try {
            final mv = Map<String, dynamic>.from(v as Map);
            final voiceMap = <String, String>{};
            
            if (mv['name'] != null) {
              voiceMap['name'] = mv['name'].toString();
            }
            
            if (mv['locale'] != null) {
              voiceMap['locale'] = mv['locale'].toString();
            }
            
            if (voiceMap.isNotEmpty) {
              tempVoices.add(voiceMap);
            }
          } catch (e) {
            debugPrint('Error processing voice: $e');
          }
        }
        _availableVoices = tempVoices;
        Map<String, dynamic>? selected;

        // If VOICE_NAME is specified, try exact name match first
        if (_voiceName.isNotEmpty) {
          for (final v in voices) {
            final mv = Map<String, dynamic>.from(v as Map);
            if ((mv['name'] ?? '').toString().toLowerCase() == _voiceName.toLowerCase()) {
              selected = mv;
              break;
            }
          }
        }

        // Otherwise, try to pick by locale and prefer enhanced voices
        selected ??= _pickBestVoiceForLocale(voices, locale);

        if (selected != null) {
          try {
            final voiceMap = <String, String>{};
            
            if (selected['name'] != null) {
              voiceMap['name'] = selected['name'].toString();
              _voiceName = selected['name'].toString();
            }
            
            if (selected['locale'] != null) {
              voiceMap['locale'] = selected['locale'].toString();
            }
            
            if (voiceMap.isNotEmpty) {
              await _flutterTts.setVoice(voiceMap);
            }
          } catch (e) {
            debugPrint('Error setting voice: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing TTS voices: $e');
    }

    // Set up completion listener for system TTS
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      debugPrint('TTS Service: System TTS playback completed, notifying listeners');
      // Make sure to notify on the main thread
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    });
  }

  Map<String, dynamic>? _pickBestVoiceForLocale(List<dynamic> voices, String locale) {
    // First try exact locale match
    for (final v in voices) {
      try {
        final mv = Map<String, dynamic>.from(v as Map);
        final voiceLocale = (mv['locale'] ?? '').toString().toLowerCase();
        if (voiceLocale == locale.toLowerCase()) {
          return mv;
        }
      } catch (e) {
        debugPrint('Error checking voice locale: $e');
      }
    }

    // Then try language code match (e.g., 'es' for 'es-ES')
    final langCode = locale.split('-').first.toLowerCase();
    for (final v in voices) {
      try {
        final mv = Map<String, dynamic>.from(v as Map);
        final voiceLocale = (mv['locale'] ?? '').toString().toLowerCase();
        if (voiceLocale.startsWith('$langCode-')) {
          return mv;
        }
      } catch (e) {
        debugPrint('Error checking voice language: $e');
      }
    }

    return null;
  }

  Future<void> speak(String text) async {
    debugPrint('TTS Service: speak method called with text length ${text.length}');
    if (text.isEmpty) {
      debugPrint('TTS Service: Empty text, not speaking');
      return;
    }
    
    // Skip if already speaking
    if (_isSpeaking) {
      debugPrint('TTS Service: Already speaking, stopping first');
      await stop();
      // Small delay to ensure stop completes
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Check if we should speak this text (e.g., not just emojis)
    if (!_shouldSpeak(text)) {
      debugPrint('TTS Service: Skipping TTS for text that should not be spoken: $text');
      return;
    }

    // Clean up text for better TTS
    final cleanText = _stripEmojis(text);
    debugPrint('TTS Service: Speaking cleaned text of length ${cleanText.length}');
    
    _lastSpokenText = cleanText;
    _isSpeaking = true;
    debugPrint('TTS Service: Set isSpeaking=true and notifying listeners');
    // Make sure to notify on the main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    
    try {
      // Use OpenAI TTS if selected and available
      if (_settingsModel.ttsProvider == TtsProvider.openai && _openAITts != null) {
        debugPrint('TTS Service: Using OpenAI TTS provider');
        
        // Check if we have this text in the cache
        final cachedEntry = _getFromCache(cleanText);
        final currentVoice = _settingsModel.openaiTtsVoice;
        
        if (cachedEntry != null && cachedEntry.voice == currentVoice) {
          // Use cached audio data
          debugPrint('TTS Service: Using cached audio data');
          await _openAITts!.playAudio(cachedEntry.audioData);
        } else {
          // Generate new audio
          debugPrint('TTS Service: Generating new audio');
          final audioData = await _openAITts!.speak(cleanText);
          
          // Cache the audio data if available
          if (audioData != null) {
            _addToCache(cleanText, audioData, currentVoice);
          }
        }
      } else {
        // Use system TTS
        debugPrint('TTS Service: Using system TTS provider');
        await _flutterTts.speak(cleanText);
        // Note: We can't cache system TTS audio as we don't have access to the raw audio data
      }
    } catch (e) {
      debugPrint('TTS Service: Error speaking text: $e');
      _isSpeaking = false;
      // Make sure to notify on the main thread
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
  
  // Helper methods are defined at the bottom of the class

  Future<void> stop() async {
    debugPrint('TTS Service: stop method called, isSpeaking=$_isSpeaking');
    if (_isSpeaking) {
      if (_settingsModel.ttsProvider == TtsProvider.openai && _openAITts != null) {
        debugPrint('TTS Service: Stopping OpenAI TTS');
        await _openAITts!.stop();
      } else {
        debugPrint('TTS Service: Stopping system TTS');
        await _flutterTts.stop();
      }
      _isSpeaking = false;
      debugPrint('TTS Service: Set isSpeaking=false and notifying listeners');
      // Make sure to notify on the main thread
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      debugPrint('TTS Service: Not speaking, no need to stop');
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _openAITts?.dispose();
    super.dispose();
  }

  // ----------------------- helpers -----------------------
  
  void _initializeOpenAITts() {
    // If OpenAI TTS is already initialized, just update the voice
    if (_openAITts != null) {
      _openAITts!.setVoice(_settingsModel.openaiTtsVoice);
      return;
    }
    
    // Otherwise try to initialize with environment variable
    final apiKey = const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    if (apiKey.isNotEmpty) {
      _openAITts = OpenAITtsService(apiKey: apiKey);
      _openAITts!.setVoice(_settingsModel.openaiTtsVoice);
      _openAIVoices = _openAITts!.voices;
    } else {
      debugPrint('Warning: OpenAI TTS provider selected but no API key available');
    }
  }
  
  void setTtsProvider(TtsProvider provider) {
    _settingsModel.setTtsProvider(provider);
    
    if (provider == TtsProvider.openai && _openAITts == null) {
      _initializeOpenAITts();
    }
    
    notifyListeners();
  }
  
  void setOpenAIVoice(String voiceId) {
    _settingsModel.setOpenAITtsVoice(voiceId);
    if (_openAITts != null) {
      _openAITts!.setVoice(voiceId);
    }
    notifyListeners();
  }
  
  List<Map<String, String>> get openAIVoices => _openAIVoices;
  void setVoiceName(String name) {
    _voiceName = name;
    // Apply immediately if possible
    _applyVoiceByName(name);
    // Save settings
    _saveSettings();
    notifyListeners();
  }

  void setPreferredLanguage(String lang) {
    if (lang == _preferredLanguage) return;
    _preferredLanguage = lang;
    final locale = _mapTargetLanguageToLocale(lang);
    _flutterTts.setLanguage(locale);
    _saveSettings();
    notifyListeners();
    // Re-apply preferred voice for the new language
    final langCode = _langToCode(lang);
    final preferredVoice = _preferredVoicesByLang[langCode] ?? '';
    if (preferredVoice.isNotEmpty) {
      _applyVoiceByName(preferredVoice);
    }
  }

  void setPreferredVoiceForLanguage(String langCode, String voiceName) {
    if (voiceName.isEmpty) {
      _preferredVoicesByLang.remove(langCode);
    } else {
      _preferredVoicesByLang[langCode] = voiceName;
    }
    _saveSettings();
    notifyListeners();
  }

  Future<void> previewVoice(String voiceName, String languageName) async {
    if (_settingsModel.ttsProvider == TtsProvider.openai) {
      if (_openAITts == null) {
        debugPrint('Initializing OpenAI TTS for preview');
        _initializeOpenAITts();
      }
      
      if (_openAITts != null) {
        debugPrint('Previewing OpenAI voice: $voiceName');
        _openAITts!.setVoice(voiceName);
        await _openAITts!.speak('This is a preview of the $voiceName voice.');
      } else {
        debugPrint('Error: Could not initialize OpenAI TTS for preview');
      }
    } else {
      final lang = _mapTargetLanguageToLocale(languageName);
      await _flutterTts.setLanguage(lang);
      await _applyVoiceByName(voiceName);
      await _flutterTts.speak('This is a preview.');
    }
  }
  
  String _mapTargetLanguageToLocale(String language) {
    final l = language.toLowerCase();
    if (l.startsWith('spanish') || l.startsWith('es')) return 'es-ES';
    if (l.startsWith('german') || l.startsWith('de')) return 'de-DE';
    if (l.startsWith('french') || l.startsWith('fr')) return 'fr-FR';
    if (l.startsWith('italian') || l.startsWith('it')) return 'it-IT';
    if (l.startsWith('portuguese') || l.startsWith('pt')) return 'pt-PT';
    if (l.startsWith('japanese') || l.startsWith('ja')) return 'ja-JP';
    if (l.startsWith('chinese') || l.startsWith('zh')) return 'zh-CN';
    if (l.startsWith('korean') || l.startsWith('ko')) return 'ko-KR';
    if (l.startsWith('english') || l.startsWith('en')) return 'en-US';
    if (l.startsWith('dutch') || l.startsWith('nl')) return 'nl-NL';
    if (l.startsWith('swedish') || l.startsWith('sv')) return 'sv-SE';
    if (l.startsWith('norwegian') || l.startsWith('no')) return 'no-NO';
    if (l.startsWith('danish') || l.startsWith('da')) return 'da-DK';
    if (l.startsWith('polish') || l.startsWith('pl')) return 'pl-PL';
    if (l.startsWith('russian') || l.startsWith('ru')) return 'ru-RU';
    if (l.startsWith('turkish') || l.startsWith('tr')) return 'tr-TR';
    return 'en-US';
  }

  Future<void> _applyVoiceByName(String name) async {
    if (name.isEmpty) return;
    
    try {
      // Find the voice by name
      Map<String, String>? match;
      for (final voice in _availableVoices) {
        if ((voice['name'] ?? '').toLowerCase() == name.toLowerCase()) {
          match = Map<String, String>.from(voice); // Create a mutable copy
          break;
        }
      }
      
      if (match == null || match.isEmpty) return;
      
      // Create a new mutable map to avoid unmodifiable collection issues
      final voiceMap = <String, String>{};
      if (match.containsKey('name') && match['name'] != null) {
        voiceMap['name'] = match['name']!;
      }
      if (match.containsKey('locale') && match['locale'] != null) {
        voiceMap['locale'] = match['locale']!;
      }
      
      if (voiceMap.isNotEmpty) {
        await _flutterTts.setVoice(voiceMap);
      }
    } catch (e) {
      debugPrint('Error applying voice by name: $e');
    }
  }

  // Map human language name to ISO code for per-language voice mapping
  String _langToCode(String language) {
    final l = language.toLowerCase();
    if (l.startsWith('spanish') || l.startsWith('es')) return 'es';
    if (l.startsWith('german') || l.startsWith('de')) return 'de';
    if (l.startsWith('french') || l.startsWith('fr')) return 'fr';
    if (l.startsWith('italian') || l.startsWith('it')) return 'it';
    if (l.startsWith('portuguese') || l.startsWith('pt')) return 'pt';
    if (l.startsWith('japanese') || l.startsWith('ja')) return 'ja';
    if (l.startsWith('chinese') || l.startsWith('zh')) return 'zh';
    if (l.startsWith('korean') || l.startsWith('ko')) return 'ko';
    if (l.startsWith('english') || l.startsWith('en')) return 'en';
    if (l.startsWith('dutch') || l.startsWith('nl')) return 'nl';
    if (l.startsWith('swedish') || l.startsWith('sv')) return 'sv';
    if (l.startsWith('norwegian') || l.startsWith('no')) return 'no';
    if (l.startsWith('danish') || l.startsWith('da')) return 'da';
    if (l.startsWith('polish') || l.startsWith('pl')) return 'pl';
    if (l.startsWith('russian') || l.startsWith('ru')) return 'ru';
    if (l.startsWith('turkish') || l.startsWith('tr')) return 'tr';
    return 'en';
  }

  // Load settings from shared preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load voice name
      final savedVoiceName = prefs.getString(_keyVoiceName);
      if (savedVoiceName != null && savedVoiceName.isNotEmpty) {
        _voiceName = savedVoiceName;
      }
      
      // Load preferred language
      final savedLanguage = prefs.getString(_keyPreferredLanguage);
      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        _preferredLanguage = savedLanguage;
      }
      
      // Load preferred voices by language
      final savedVoicesByLang = prefs.getString(_keyPreferredVoicesByLang);
      if (savedVoicesByLang != null && savedVoicesByLang.isNotEmpty) {
        try {
          final Map<String, dynamic> voicesMap = jsonDecode(savedVoicesByLang);
          _preferredVoicesByLang.clear();
          voicesMap.forEach((key, value) {
            if (value is String) {
              _preferredVoicesByLang[key] = value;
            }
          });
        } catch (e) {
          debugPrint('Error parsing saved voices by language: $e');
        }
      }
      
      debugPrint('Loaded TTS settings from preferences');
    } catch (e) {
      debugPrint('Error loading TTS settings: $e');
    }
  }
  
  // Save settings to shared preferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save voice name
      await prefs.setString(_keyVoiceName, _voiceName);
      
      // Save preferred language
      await prefs.setString(_keyPreferredLanguage, _preferredLanguage);
      
      // Save preferred voices by language
      await prefs.setString(_keyPreferredVoicesByLang, jsonEncode(_preferredVoicesByLang));
      
      debugPrint('Saved TTS settings to preferences');
    } catch (e) {
      debugPrint('Error saving TTS settings: $e');
    }
  }

  // ------------- speak filters -------------
  bool _shouldSpeak(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    // Count emoji vs. non-emoji, treat punctuation/whitespace as neutral
    int emojiCount = 0;
    int alphaNumCount = 0;
    for (final r in trimmed.runes) {
      if (_isEmojiRune(r)) {
        emojiCount++;
      } else if (_isAlphaNumRune(r)) {
        alphaNumCount++;
      } else {
        // ignore punctuation/space/ZWJ etc.
      }
    }

    if (alphaNumCount == 0 && emojiCount > 0) return false; // only emojis
    if (emojiCount > 0 && alphaNumCount > 0) return true; // mixed, speak
    return alphaNumCount > 0; // speak only if we have real text
  }

  bool _isAlphaNumRune(int r) {
    // Basic Latin letters/digits and many Latin-1 supplements
    return (r >= 0x30 && r <= 0x39) || // 0-9
        (r >= 0x41 && r <= 0x5A) || // A-Z
        (r >= 0x61 && r <= 0x7A) || // a-z
        (r >= 0x00C0 && r <= 0x024F) || // Latin-1 supplement + extended
        (r >= 0x0400 && r <= 0x04FF) || // Cyrillic
        (r >= 0x0370 && r <= 0x03FF) || // Greek
        (r >= 0x4E00 && r <= 0x9FFF); // CJK Unified Ideographs (rough text proxy)
  }

  bool _isEmojiRune(int r) {
    // Common emoji ranges + regional indicators + variation selectors + ZWJ
    return (r >= 0x1F600 && r <= 0x1F64F) || // Emoticons
        (r >= 0x1F300 && r <= 0x1F5FF) || // Misc Symbols and Pictographs
        (r >= 0x1F680 && r <= 0x1F6FF) || // Transport & Map Symbols
        (r >= 0x1F900 && r <= 0x1F9FF) || // Supplemental Symbols and Pictographs
        (r >= 0x1FA70 && r <= 0x1FAFF) || // Symbols & Pictographs Extended-A
        (r >= 0x2600 && r <= 0x26FF) || // Misc symbols
        (r >= 0x2700 && r <= 0x27BF) || // Dingbats
        (r >= 0x1F1E6 && r <= 0x1F1FF) || // Regional indicator symbols (flags)
        r == 0x200D || // Zero-width joiner used in emoji sequences
        (r >= 0xFE00 && r <= 0xFE0F); // Variation selectors
  }

  String _stripEmojis(String text) {
    final buf = StringBuffer();
    for (final r in text.runes) {
      if (!_isEmojiRune(r)) {
        buf.writeCharCode(r);
      }
    }
    return buf.toString();
  }
}
