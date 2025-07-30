import 'package:flutter/services.dart';

import '../models/AudioTrack.dart';

class AudioPlayerManager {
  static const _channel = MethodChannel('com.zenyfh.zenmusic/audio');

  static Future<String> getLyrics() async {
    try {
      return await _channel.invokeMethod("getLyrics");
    } on Exception {
      return "could Not get lyrics";
    }
  }

  static Future<List<AudioTrack>> search(String query) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('search', {
        'query': query,
      });
      return result.map((e) => AudioTrack.fromMap(e)).toList();
    } on PlatformException catch (e) {
      throw AudioServiceException(e.code, e.message ?? 'Search failed');
    }
  }

  static Future<String?> play(String query) async {
    try {
      return await _channel.invokeMethod('play', {'query': query});
    } on PlatformException catch (e) {
      throw AudioServiceException(e.code, e.message ?? 'Unknown error');
    }
  }

  static Future<List<AudioTrack>> getQueue() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getQueue');
      return result.map((e) => AudioTrack.fromMap(e)).toList();
    } on PlatformException catch (e) {
      throw AudioServiceException(e.code, e.message ?? 'Queue load failed');
    }
  }

  static Future<AudioTrack?> getCurrentTrack() async {
    try {
      final result = await _channel.invokeMethod('getCurrentTrack');
      return result != null ? AudioTrack.fromMap(result) : null;
    } on PlatformException {
      return null;
    }
  }

  static Future<void> removeFromQueue(int index) async {
    try {
      print("Index: $index");
      await _channel.invokeMethod("removeFromQueue", {'query': index});
    } on Exception {
      throw Exception('No track to remove.');
    }
  }

  static Future<void> pause() async {
    try {
      await _channel.invokeMethod('pause');
    } on Exception {
      throw Exception('No track to pause.');
    }
  }

  static Future<void> resume() async {
    try {
      await _channel.invokeMethod('resume');
    } on Exception {
      throw Exception('No track to resume.');
    }
  }

  static Future<void> seek(int position) async {
    try {
      await _channel.invokeMethod('seek', position);
    } catch (e) {
      print('Error seeking: $e');
      throw e;
    }
  }

  static Future<void> next() async {
    try {
      await _channel.invokeMethod("npNext");
    } on Exception {
      throw Exception("No track found.");
    }
  }

  static Future<void> previous() async {
    try {
      await _channel.invokeMethod("npPrevious");
    } on Exception {
      throw Exception(
        "No track found or something crazy happened with the queue position.",
      );
    }
  }

  static Future<int> getPosition() async {
    try {
      return await _channel.invokeMethod("getPosition");
    } on Exception {
      return -1;
    }
  }
}

class AudioServiceException implements Exception {
  final String code;
  final String message;

  AudioServiceException(this.code, this.message);

  @override
  String toString() => 'AudioServiceException($code): $message';
}
