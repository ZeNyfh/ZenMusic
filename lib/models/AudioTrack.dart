class AudioTrack {
  final String artist;
  final String title;
  final String thumbnail;
  final int length;
  final int position;
  final String streamUrl;

  AudioTrack({
    required this.artist,
    required this.title,
    required this.thumbnail,
    required this.length,
    required this.position,
    required this.streamUrl,
  });

  factory AudioTrack.fromMap(Map<dynamic, dynamic> map) {
    return AudioTrack(
      artist: map['artist'] ?? 'Unknown Artist',
      title: map['title'] ?? 'Unknown Title',
      thumbnail: map['thumbnail'] ?? '',
      length: map['length'] ?? 0,
      position: map['position'] ?? 0,
      streamUrl: map['streamUrl'] ?? '',
    );
  }

  String get durationFormatted {
    final minutes = (length / 60).floor();
    final seconds = length % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
