import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../models/AudioTrack.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  late AudioPlayer _player;
  List<AudioTrack> queue = [];
  int queuePosition = -1; // -1 indicates no current track
  PlayerState _playerState = PlayerState.stopped;
  AudioTrack? currentTrack;

  // Events
  final StreamController<AudioTrack> _trackChangedController = StreamController.broadcast();
  final StreamController<List<AudioTrack>> _queueUpdatedController = StreamController.broadcast();
  final StreamController<PlayerState> _playerStateController = StreamController.broadcast();
  final StreamController<int> _positionController = StreamController.broadcast();

  AudioService._internal() {
    _player = AudioPlayer();
    _init();
  }

  void _init() {
    _player.onPlayerStateChanged.listen((state) {
      _playerState = state;
      _playerStateController.add(state);
    });

    _player.onPositionChanged.listen((position) {
      _positionController.add(position.inSeconds);
    });

    _player.onPlayerComplete.listen((event) {
      next();
    });
  }

  Future<void> playTrack(AudioTrack track) async {
    // Replace current queue with new track
    queue = [track];
    queuePosition = 0;
    currentTrack = track;
    await _play(track);
    _queueUpdatedController.add(queue);
    _trackChangedController.add(track);
  }

  Future<void> _play(AudioTrack track) async {
    await _player.play(UrlSource(track.videoID));
    _playerState = PlayerState.playing;
  }

  Future<void> addToQueue(AudioTrack track) {
    queue.add(track);

    // If nothing is playing, start playing this track
    if (queuePosition == -1) {
      queuePosition = 0;
      currentTrack = track;
      return _play(track);
    }

    _queueUpdatedController.add(queue);
    return Future.value();
  }

  Future<void> pause() async {
    await _player.pause();
    _playerState = PlayerState.paused;
    _playerStateController.add(_playerState);
  }

  Future<void> resume() async {
    await _player.resume();
    _playerState = PlayerState.playing;
    _playerStateController.add(_playerState);
  }

  Future<void> seek(int position) async {
    await _player.seek(Duration(seconds: position));
  }

  Future<void> next() async {
    if (queue.isEmpty) return;
    queuePosition = (queuePosition + 1) % queue.length;
    currentTrack = queue[queuePosition];
    await _play(currentTrack!);
    _trackChangedController.add(currentTrack!);
  }

  Future<void> previous() async {
    if (queue.isEmpty) return;
    queuePosition = (queuePosition - 1 + queue.length) % queue.length;
    currentTrack = queue[queuePosition];
    await _play(currentTrack!);
    _trackChangedController.add(currentTrack!);
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= queue.length) return;

    queue.removeAt(index);
    if (queuePosition >= index && queuePosition > 0) {
      queuePosition--;
    }

    _queueUpdatedController.add(queue);
  }

  // Getters
  bool get isPlaying => _playerState == PlayerState.playing;

  PlayerState get playerState => _playerState;

  Stream<AudioTrack> get trackChanged => _trackChangedController.stream;

  Stream<List<AudioTrack>> get queueUpdated => _queueUpdatedController.stream;

  Stream<PlayerState> get playerStateChanged => _playerStateController.stream;

  Stream<int> get positionChanged => _positionController.stream;

  Future<Duration?> get currentPosition => _player.getCurrentPosition();

  Future<void> dispose() async {
    await _player.dispose();
    _trackChangedController.close();
    _queueUpdatedController.close();
    _playerStateController.close();
    _positionController.close();
  }
}
