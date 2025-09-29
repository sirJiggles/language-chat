import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

/// A simple audio player service using just_audio package
class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  Function? _onPlaybackComplete;
  
  bool get isPlaying => _player.playing;
  
  /// Set a callback to be called when playback completes
  set onPlaybackComplete(Function callback) {
    _onPlaybackComplete = callback;
  }
  
  /// Play audio from a byte array
  Future<void> playBytes(Uint8List bytes) async {
    debugPrint('AudioPlayerService: playBytes called with ${bytes.length} bytes');
    if (isPlaying) {
      debugPrint('AudioPlayerService: Already playing, stopping first');
      await stop();
      // Small delay to ensure stop completes
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    try {
      // Save to temporary file
      final tempFile = await _saveBytesToTempFile(bytes);
      debugPrint('AudioPlayerService: Saved audio to temporary file: ${tempFile.path}');
      
      // Remove any existing listeners to avoid duplicates
      _player.playerStateStream.drain();
      
      // Set up completion listener
      _player.playerStateStream.listen((state) {
        debugPrint('AudioPlayerService: Player state changed: ${state.processingState}, playing=${state.playing}');
        if (state.processingState == ProcessingState.completed) {
          debugPrint('AudioPlayerService: Audio playback completed');
          if (_onPlaybackComplete != null) {
            debugPrint('AudioPlayerService: Calling onPlaybackComplete callback');
            _onPlaybackComplete!();
          } else {
            debugPrint('AudioPlayerService: No onPlaybackComplete callback set');
          }
        }
      });
      
      // Play the file
      debugPrint('AudioPlayerService: Setting file path and playing audio');
      await _player.setFilePath(tempFile.path);
      await _player.play();
      debugPrint('AudioPlayerService: play() method returned, isPlaying=${_player.playing}');
    } catch (e) {
      debugPrint('AudioPlayerService: Error playing audio: $e');
      rethrow;
    }
  }
  
  /// Stop audio playback
  Future<void> stop() async {
    debugPrint('AudioPlayerService: stop method called, isPlaying=${_player.playing}');
    try {
      await _player.stop();
      debugPrint('AudioPlayerService: Player stopped');
    } catch (e) {
      debugPrint('AudioPlayerService: Error stopping audio: $e');
    }
  }
  
  /// Save bytes to a temporary file
  Future<File> _saveBytesToTempFile(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.mp3');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    await _player.dispose();
  }
}
