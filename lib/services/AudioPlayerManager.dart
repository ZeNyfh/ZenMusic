import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../models/AudioTrack.dart';
import 'AudioService.dart';

class AudioPlayerManager {
  static const _channel = MethodChannel('com.zenyfh.zenmusic/audio');
  static final AudioService _audioService = AudioService();

  // Metadata extraction
  static Future<String> getLyrics(List<String> query) async {
    try {
      return await _channel.invokeMethod("getLyrics", {'query': query});
    } on Exception {
      return "Could not get lyrics";
    }
  }

  static Future<List<AudioTrack>> search(String query) async {
    try {
      final result = await _channel.invokeMethod('search', {'query': query});
      return (result as List).map((e) => audioTrackFromMap(e)).toList();
    } on PlatformException catch (e) {
      throw AudioServiceException(e.code, e.message ?? 'Search failed');
    }
  }

  static Future<AudioTrack> extractAudioTrack(String videoId) async {
    try {
      final result = await _channel.invokeMethod('extractAudioTrack', {'videoId': videoId});
      return audioTrackFromMap(result);
    } on PlatformException catch (e) {
      throw AudioServiceException(e.code, e.message ?? 'Extraction failed');
    }
  }

  // Playback control
  static Future<void> play(String videoId) async {
    try {
      AudioTrack track = await extractAudioTrack(videoId);
      await enqueueTrack(track);
    } on PlatformException catch (e) {
      throw AudioServiceException(e.code, e.message ?? 'Play failed');
    }
  }

  static Future<void> enqueueTrack(AudioTrack track) async {
    await _audioService.addToQueue(track);
  }

  // Getters
  static List<AudioTrack> get queue => _audioService.queue;

  static AudioTrack? get currentTrack => _audioService.currentTrack;

  static bool get isPlaying => _audioService.isPlaying;

  // Streams
  static Stream<AudioTrack> get trackChanged => _audioService.trackChanged;

  static Stream<List<AudioTrack>> get queueUpdated => _audioService.queueUpdated;

  static Stream<PlayerState> get playerStateChanged => _audioService.playerStateChanged;

  static Stream<int> get positionChanged => _audioService.positionChanged;

  static Future<int> get currentPosition async =>
      (await _audioService.currentPosition)!.inSeconds.isNaN ? (_audioService.currentPosition as Duration).inSeconds : 0;

  // Other methods (unchanged)
  static Future<void> pause() async => _audioService.pause();

  static Future<void> resume() async => _audioService.resume();

  static Future<void> seek(int position) async => _audioService.seek(position);

  static Future<void> next() async => _audioService.next();

  static Future<void> previous() async => _audioService.previous();

  static Future<void> removeFromQueue(int index) async => _audioService.removeFromQueue(index);
}

AudioTrack audioTrackFromMap(Map<dynamic, dynamic> map) {
  return AudioTrack(
    artist: map['artist'] as String? ?? '',
    title: map['title'] as String? ?? '',
    thumbnail: map['thumbnail'] as String? ?? '',
    length: map['length'] as int? ?? 0,
    position: map['position'] as int? ?? 0,
    queuePosition: map['queuePosition'] as int? ?? 0,
    videoID: map['streamUrl'] as String? ?? '',
    isStream: map['isStream'] as bool? ?? false,
  );
}

class AudioServiceException implements Exception {
  final String code;
  final String message;

  AudioServiceException(this.code, this.message);

  @override
  String toString() => 'AudioServiceException($code): $message';
}
