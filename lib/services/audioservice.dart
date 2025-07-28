import 'package:flutter/services.dart';

class AudioPlayerService {
  static const _channel = MethodChannel('com.zenyfh.zenmusic/audio');

  static Future<String?> play(String query) async {
    try {
      return await _channel.invokeMethod('play', {'query': query});
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
      return null;
    }
  }
}