class AudioTrack {
  final String artist;
  final String title;
  final String thumbnail;
  final double duration;
  final int position;
  final String videoID;
  final bool isStream;

  AudioTrack({
    required this.artist,
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.position,
    required this.videoID,
    required this.isStream,
  });

  String get lyrics => "Unknown Lyrics"; // TODO: implement lyrics.
}