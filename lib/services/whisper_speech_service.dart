import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Speech-to-text service using OpenAI Whisper API
/// Provides superior accuracy compared to native speech recognition,
/// especially for language learning where accents and non-native pronunciation are common
class WhisperSpeechService extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final String _apiKey;
  
  bool _isRecording = false;
  bool _isTranscribing = false;
  String _lastWords = '';
  String _error = '';
  String _localeId = 'en';
  String? _currentRecordingPath;
  double _currentAmplitude = 0.0;

  bool get isListening => _isRecording;
  bool get isTranscribing => _isTranscribing;
  String get lastWords => _lastWords;
  String get error => _error;
  String get localeId => _localeId;
  double get currentAmplitude => _currentAmplitude;

  WhisperSpeechService({required String apiKey}) : _apiKey = apiKey;

  Future<bool> initialize() async {
    try {
      // Check if we have permission to record
      if (await _recorder.hasPermission()) {
        debugPrint('WhisperSpeechService: Microphone permission granted');
        return true;
      } else {
        debugPrint('WhisperSpeechService: Microphone permission denied');
        _error = 'Microphone permission denied';
        return false;
      }
    } catch (e) {
      debugPrint('WhisperSpeechService: Error initializing: $e');
      _error = 'Failed to initialize: $e';
      return false;
    }
  }

  Future<void> startListening() async {
    try {
      _lastWords = '';
      _error = '';
      _currentAmplitude = 0.0;
      
      // Check permission again before recording
      if (!await _recorder.hasPermission()) {
        _error = 'Microphone permission denied';
        notifyListeners();
        return;
      }

      // Get temporary directory for recording
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/recording_$timestamp.m4a';

      // Start recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      debugPrint('WhisperSpeechService: Started recording to $_currentRecordingPath');
      
      // Start monitoring amplitude
      _monitorAmplitude();
      
      notifyListeners();
    } catch (e) {
      debugPrint('WhisperSpeechService: Error starting recording: $e');
      _error = 'Failed to start recording: $e';
      _isRecording = false;
      notifyListeners();
    }
  }

  Future<void> _monitorAmplitude() async {
    while (_isRecording) {
      try {
        final amplitude = await _recorder.getAmplitude();
        // Normalize amplitude (usually between -50 and 0 dB)
        // Convert to 0.0 - 1.0 range
        final normalized = ((amplitude.current + 50) / 50).clamp(0.0, 1.0);
        
        if (_currentAmplitude != normalized) {
          _currentAmplitude = normalized;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('WhisperSpeechService: Error getting amplitude: $e');
      }
      
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> stopListening({bool skipTranscription = false}) async {
    try {
      if (!_isRecording) {
        debugPrint('WhisperSpeechService: Not recording, nothing to stop');
        return;
      }

      // Stop recording
      final path = await _recorder.stop();
      _isRecording = false;
      _currentAmplitude = 0.0;
      
      // If skipping transcription (cancelled), don't process
      if (skipTranscription) {
        debugPrint('WhisperSpeechService: Skipping transcription (cancelled)');
        if (path != null && path.isNotEmpty) {
          try {
            await File(path).delete();
            debugPrint('WhisperSpeechService: Deleted cancelled recording');
          } catch (e) {
            debugPrint('WhisperSpeechService: Error deleting cancelled recording: $e');
          }
        }
        notifyListeners();
        return;
      }
      
      _isTranscribing = true;
      notifyListeners();

      if (path == null || path.isEmpty) {
        debugPrint('WhisperSpeechService: No recording path returned');
        _error = 'No recording found';
        _isTranscribing = false;
        notifyListeners();
        return;
      }

      debugPrint('WhisperSpeechService: Recording stopped, file at: $path');

      // Check if file exists and has content
      final file = File(path);
      if (!await file.exists()) {
        debugPrint('WhisperSpeechService: Recording file does not exist');
        _error = 'Recording file not found';
        _isTranscribing = false;
        notifyListeners();
        return;
      }

      final fileSize = await file.length();
      debugPrint('WhisperSpeechService: Recording file size: $fileSize bytes');

      if (fileSize < 1000) {
        debugPrint('WhisperSpeechService: Recording too short');
        _error = 'Recording too short, please try again';
        _isTranscribing = false;
        notifyListeners();
        return;
      }

      // Send to Whisper API for transcription
      await _transcribeAudio(path);

      // Clean up the recording file
      try {
        await file.delete();
        debugPrint('WhisperSpeechService: Deleted recording file');
      } catch (e) {
        debugPrint('WhisperSpeechService: Error deleting recording file: $e');
      }
    } catch (e) {
      debugPrint('WhisperSpeechService: Error stopping recording: $e');
      _error = 'Failed to stop recording: $e';
      _isRecording = false;
      notifyListeners();
    }
  }

  Future<void> _transcribeAudio(String audioPath) async {
    try {
      debugPrint('WhisperSpeechService: Transcribing audio with language: $_localeId');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
      );

      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = _localeId;
      request.fields['response_format'] = 'json';

      // Add the audio file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        audioPath,
        filename: 'audio.m4a',
      ));

      debugPrint('WhisperSpeechService: Sending request to Whisper API...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('WhisperSpeechService: Response status: ${response.statusCode}');

      _isTranscribing = false;
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _lastWords = jsonResponse['text'] ?? '';
        debugPrint('WhisperSpeechService: Transcription: $_lastWords');
        _error = '';
      } else {
        debugPrint('WhisperSpeechService: Error response: ${response.body}');
        _error = 'Transcription failed: ${response.statusCode}';
        
        // Try to parse error message
        try {
          final errorJson = json.decode(response.body);
          if (errorJson['error'] != null && errorJson['error']['message'] != null) {
            _error = errorJson['error']['message'];
          }
        } catch (e) {
          // Use default error message
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('WhisperSpeechService: Error transcribing audio: $e');
      _error = 'Transcription error: $e';
      _isTranscribing = false;
      notifyListeners();
    }
  }

  void clearLastWords() {
    _lastWords = '';
    notifyListeners();
  }

  /// Update the language for transcription from a human language name (e.g., 'German')
  /// Whisper uses ISO-639-1 language codes (2-letter codes)
  void setLocaleFromLanguage(String languageName) {
    final l = languageName.toLowerCase();
    debugPrint('WhisperSpeechService: Setting locale for language: $languageName');
    
    if (l.startsWith('german') || l.startsWith('de')) {
      _localeId = 'de';
    } else if (l.startsWith('spanish') || l.startsWith('es')) {
      _localeId = 'es';
    } else if (l.startsWith('french') || l.startsWith('fr')) {
      _localeId = 'fr';
    } else if (l.startsWith('italian') || l.startsWith('it')) {
      _localeId = 'it';
    } else if (l.startsWith('portuguese') || l.startsWith('pt')) {
      _localeId = 'pt';
    } else if (l.startsWith('japanese') || l.startsWith('ja')) {
      _localeId = 'ja';
    } else if (l.startsWith('chinese') || l.startsWith('zh')) {
      _localeId = 'zh';
    } else if (l.startsWith('korean') || l.startsWith('ko')) {
      _localeId = 'ko';
    } else if (l.startsWith('dutch') || l.startsWith('nl')) {
      _localeId = 'nl';
    } else if (l.startsWith('swedish') || l.startsWith('sv')) {
      _localeId = 'sv';
    } else if (l.startsWith('norwegian') || l.startsWith('no')) {
      _localeId = 'no';
    } else if (l.startsWith('danish') || l.startsWith('da')) {
      _localeId = 'da';
    } else if (l.startsWith('polish') || l.startsWith('pl')) {
      _localeId = 'pl';
    } else if (l.startsWith('russian') || l.startsWith('ru')) {
      _localeId = 'ru';
    } else if (l.startsWith('turkish') || l.startsWith('tr')) {
      _localeId = 'tr';
    } else {
      _localeId = 'en';
    }
    
    debugPrint('WhisperSpeechService: Locale set to: $_localeId');
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}
