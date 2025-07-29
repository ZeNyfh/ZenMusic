import 'package:flutter/services.dart';

import '../models/AudioTrack.dart';

class AudioPlayerManager {
    static const _channel = MethodChannel('com.zenyfh.zenmusic/audio');

    static Future<List<AudioTrack>> search(String query) async {
        try {
            final List<dynamic> result =
            await _channel.invokeMethod('search', {'query': query});
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
}

class AudioServiceException implements Exception {
    final String code;
    final String message;

    AudioServiceException(this.code, this.message);

    @override
    String toString() => 'AudioServiceException($code): $message';
}
