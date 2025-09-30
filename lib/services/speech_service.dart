import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  String _error = '';
  String _localeId = 'en_US';

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  String get error => _error;
  String get localeId => _localeId;

  Future<bool> initialize() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        _isListening = status == 'listening';
        notifyListeners();
      },
      onError: (error) {
        _error = error.errorMsg;
        notifyListeners();
      },
    );

    return available;
  }

  Future<void> startListening() async {
    _lastWords = '';
    _error = '';

    // Double-check the current locale before starting
    if (_speech.isAvailable) {
      var currentLocale = await _speech.systemLocale();
      debugPrint('SpeechService: Current system locale before listen: ${currentLocale?.localeId}');
    }

    await _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        // Notify on every partial update so UI can show live text
        notifyListeners();
      },
      listenFor: const Duration(seconds: 30),
      localeId: _localeId,
      cancelOnError: true,
      partialResults: true,
    );
    notifyListeners();
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  void clearLastWords() {
    _lastWords = '';
    notifyListeners();
  }

  // Update the recognizer locale from a human language name (e.g., 'German')
  void setLocaleFromLanguage(String languageName) {
    final l = languageName.toLowerCase();
    debugPrint('SpeechService: Setting locale for language: $languageName');
    if (l.startsWith('german') || l.startsWith('de')) {
      _localeId = 'de_DE';
    } else if (l.startsWith('spanish') || l.startsWith('es')) {
      _localeId = 'es_ES';
    } else if (l.startsWith('french') || l.startsWith('fr')) {
      _localeId = 'fr_FR';
    } else if (l.startsWith('italian') || l.startsWith('it')) {
      _localeId = 'it_IT';
    } else if (l.startsWith('portuguese') || l.startsWith('pt')) {
      _localeId = 'pt_PT';
    } else if (l.startsWith('japanese') || l.startsWith('ja')) {
      _localeId = 'ja_JP';
    } else if (l.startsWith('chinese') || l.startsWith('zh')) {
      _localeId = 'zh_CN';
    } else if (l.startsWith('korean') || l.startsWith('ko')) {
      _localeId = 'ko_KR';
    } else if (l.startsWith('dutch') || l.startsWith('nl')) {
      _localeId = 'nl_NL';
    } else if (l.startsWith('swedish') || l.startsWith('sv')) {
      _localeId = 'sv_SE';
    } else if (l.startsWith('norwegian') || l.startsWith('no')) {
      _localeId = 'no_NO';
    } else if (l.startsWith('danish') || l.startsWith('da')) {
      _localeId = 'da_DK';
    } else if (l.startsWith('polish') || l.startsWith('pl')) {
      _localeId = 'pl_PL';
    } else if (l.startsWith('russian') || l.startsWith('ru')) {
      _localeId = 'ru_RU';
    } else if (l.startsWith('turkish') || l.startsWith('tr')) {
      _localeId = 'tr_TR';
    } else {
      _localeId = 'en_US';
    }
    debugPrint('SpeechService: Locale set to: $_localeId');
    notifyListeners();
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
