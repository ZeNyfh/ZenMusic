import 'dart:ffi';

import 'package:zenmusic/services/AudioPlayerManager.dart';

class AudioTrack {
  final String _artist;
  final String _title;
  final String _thumbnail;
  final int _length;
  late int _position;
  final int _queuePosition;
  final String _streamUrl;
  final bool _isStream;

  AudioTrack({
    required String artist,
    required String title,
    required String thumbnail,
    required int length,
    required int position,
    required int queuePosition,
    required String streamUrl,
    required bool isStream,
  }) : _artist = artist,
       _title = title,
       _thumbnail = thumbnail,
       _length = length,
       _position = position,
       _queuePosition = queuePosition,
       _streamUrl = streamUrl,
       _isStream = isStream;

  String get artist => _artist;
  String get title => _title;
  String get thumbnail => _thumbnail;
  int get length => _length;
  int get queuePosition => _queuePosition;
  String get streamUrl => _streamUrl;
  bool get isStream => _isStream;

  Future<int> get position async {
    var pos = AudioPlayerManager.getPosition();
    _position = await pos;
    return pos;
  }

  factory AudioTrack.fromMap(Map<dynamic, dynamic> map) {
    return AudioTrack(
      artist: map['artist'] ?? 'Unknown Artist',
      title: map['title'] ?? 'Unknown Title',
      thumbnail: map['thumbnail'] ?? '',
      length: map['length'] ?? 0,
      position: map['position'] ?? 0,
      queuePosition: map['queuePosition'] ?? 0,
      streamUrl: map['streamUrl'] ?? '',
      isStream: map['isStream'] ?? false,
    );
  }

  String get durationFormatted {
    final minutes = (length / 60).floor();
    final seconds = length % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
