import 'package:zenmusic/services/objects/AudioTrack.dart';

class AudioPlayer {
  /// audio controls ///
  // go back a track
  static void prev() {
  }

  // go forward a track
  static void next() {
  }

  // default is true, assume playing, for pause button
  static void togglePlayback() {
  }

  // seeks to a position in the track.
  static void seek(int pos) {
  }

  /// playback stuff ///
  // plays a given URL, use in tandem with search.
  static void playURL(String query) {
    if (!query.startsWith("http")) {
      query = search(query);
    }
  }

  /// use [query] to eventually retrieve a URL to use with [playURL]
  /// current this has the same code as zenvibe, search and play the first thing it gets.
  // TODO: actually replace this with a search system instead of a
  static String search(String query) {
    // returns a URL
    return "";
  }

  /// returns the current track, nullable as the current track may be nothing.
  // TODO: figure out how you're getting the current track bruh
  static AudioTrack? getCurrentTrack() {
    return null;
  }

  bool _lyricsShow = false;
  bool toggleLyrics() {
    _lyricsShow = !_lyricsShow;
    return _lyricsShow;
  }
}