import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String? _lastSpokenText;

  // Env-driven defaults
  static const String _envVoiceName = String.fromEnvironment('VOICE_NAME');
  static const String _envTargetLanguage = String.fromEnvironment('TARGET_LANGUAGE', defaultValue: 'Spanish');
  static const String _envRate = String.fromEnvironment('TTS_RATE', defaultValue: '0.5');
  static const String _envPitch = String.fromEnvironment('TTS_PITCH', defaultValue: '1.0');
  // No HTTP mode: device TTS only

  // Runtime-updatable settings (initialized from env defaults)
  String _voiceName = _envVoiceName;
  double _rate = double.tryParse(_envRate) ?? 0.5;
  double _pitch = double.tryParse(_envPitch) ?? 1.0;
  String _preferredLanguage = _envTargetLanguage;
  List<Map<String, String>> _availableVoices = const [];
  final Map<String, String> _preferredVoicesByLang = {}; // langCode -> voiceName

  bool get isSpeaking => _isSpeaking;
  String? get lastSpokenText => _lastSpokenText;
  String get voiceName => _voiceName;
  double get rate => _rate;
  double get pitch => _pitch;
  String get preferredLanguage => _preferredLanguage;
  List<Map<String, String>> get availableVoices => _availableVoices;
  String? getPreferredVoiceForLanguage(String langCode) => _preferredVoicesByLang[langCode];

  Future<void> initialize() async {
    final rate = _rate;
    final pitch = _pitch;

    // Pick a suitable locale (language-region) based on TARGET_LANGUAGE
    final locale = _mapTargetLanguageToLocale(_preferredLanguage);

    // Set basic params first
    await _flutterTts.setLanguage(locale);
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);
    await _flutterTts.setVolume(1.0);

    // Try to select a high-quality voice automatically
    try {
      final voices = await _flutterTts.getVoices;
      if (voices is List) {
        // cache simplified voices for UI (name/locale)
        _availableVoices = voices.map<Map<String, String>>((v) {
          final mv = Map<String, dynamic>.from(v as Map);
          return {
            if (mv['name'] != null) 'name': mv['name'].toString(),
            if (mv['locale'] != null) 'locale': mv['locale'].toString(),
          };
        }).toList();
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
          final voiceMap = <String, String>{
            if (selected['name'] != null) 'name': selected['name'].toString(),
            if (selected['locale'] != null) 'locale': selected['locale'].toString(),
          };
          if (voiceMap.isNotEmpty) {
            await _flutterTts.setVoice(voiceMap);
          }
        }
      }
    } catch (_) {
      // Ignore voice selection failures; default engine voice will be used
    }

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      notifyListeners();
    });
  }

  Future<void> speak(String text, {String? language}) async {
    _lastSpokenText = text;
    final langName = language ?? _preferredLanguage;
    final lang = _mapTargetLanguageToLocale(langName);
    final langCode = _langToCode(langName);

    // Do not speak if text is only/mostly emojis or has no readable content
    if (!_shouldSpeak(text)) {
      notifyListeners();
      return;
    }

    // Strip emojis so we only speak readable text
    final toSpeak = _stripEmojis(text).trim();
    if (toSpeak.isEmpty) {
      notifyListeners();
      return;
    }

    // Apply preferred voice: explicit selection wins, else per-language mapping
    final selectedVoice = _voiceName.isNotEmpty ? _voiceName : (_preferredVoicesByLang[langCode] ?? '');
    if (selectedVoice.isNotEmpty) {
      await _applyVoiceByName(selectedVoice);
    }

    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(toSpeak);
    notifyListeners();
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  // ----------------------- helpers -----------------------
  void setVoiceName(String name) {
    _voiceName = name;
    // Apply immediately if possible
    _applyVoiceByName(name);
    notifyListeners();
  }

  void setRate(double value) {
    _rate = value.clamp(0.1, 1.0);
    _flutterTts.setSpeechRate(_rate);
    notifyListeners();
  }

  void setPitch(double value) {
    _pitch = value.clamp(0.5, 2.0);
    _flutterTts.setPitch(_pitch);
    notifyListeners();
  }

  void setPreferredLanguage(String lang) {
    _preferredLanguage = lang;
    // Re-apply language to engine for next speak
    _flutterTts.setLanguage(_mapTargetLanguageToLocale(_preferredLanguage));
    notifyListeners();
  }

  void setPreferredVoiceForLanguage(String langCode, String voiceName) {
    if (voiceName.isEmpty) {
      _preferredVoicesByLang.remove(langCode);
    } else {
      _preferredVoicesByLang[langCode] = voiceName;
    }
    notifyListeners();
  }

  Future<void> previewVoice(String voiceName, String languageName) async {
    final lang = _mapTargetLanguageToLocale(languageName);
    await _flutterTts.setLanguage(lang);
    await _applyVoiceByName(voiceName);
    await _flutterTts.speak('This is a preview.');
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
    return 'en-US';
  }

  Map<String, dynamic>? _pickBestVoiceForLocale(List voices, String locale) {
    Map<String, dynamic>? exact;
    Map<String, dynamic>? sameLang; // e.g., de-XX if de-DE not available
    for (final v in voices) {
      final mv = Map<String, dynamic>.from(v as Map);
      final vLocale = (mv['locale'] ?? '').toString();
      final vName = (mv['name'] ?? '').toString().toLowerCase();
      // Prefer enhanced/natural voices if flagged in name
      final isEnhanced = vName.contains('enhanced') || vName.contains('premium') || vName.contains('siri') || vName.contains('natural');

      if (vLocale == locale) {
        if (exact == null) exact = mv;
        if (isEnhanced) return mv; // best pick
      } else if (vLocale.split('-').first == locale.split('-').first) {
        if (sameLang == null) sameLang = mv;
      }
    }
    return exact ?? sameLang;
  }

  // Apply a voice by its name using cached available voices
  Future<void> _applyVoiceByName(String name) async {
    if (name.isEmpty || _availableVoices.isEmpty) return;
    final match = _availableVoices.firstWhere(
      (v) => (v['name'] ?? '').toLowerCase() == name.toLowerCase(),
      orElse: () => const {},
    );
    if (match.isEmpty) return;
    final voiceMap = <String, String>{
      if (match['name'] != null) 'name': match['name']!,
      if (match['locale'] != null) 'locale': match['locale']!,
    };
    if (voiceMap.isNotEmpty) {
      await _flutterTts.setVoice(voiceMap);
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
