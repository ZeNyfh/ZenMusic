class AudioTrack {
  final String artist;
  final String title;
  final String thumbnail;
  final int length;
  final int position;
  final int queuePosition;
  final String videoID;
  final bool isStream;

  AudioTrack({
    required this.artist,
    required this.title,
    required this.thumbnail,
    required this.length,
    required this.position,
    required this.queuePosition,
    required this.videoID,
    required this.isStream,
  });

  String get durationFormatted {
    final minutes = (length / 60).floor();
    final seconds = length % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
