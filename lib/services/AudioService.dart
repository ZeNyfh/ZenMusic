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

  bool loopQueue = true;

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
    queue = [track];
    queuePosition = 0;
    currentTrack = track;
    await _play(track);
    _queueUpdatedController.add(List.unmodifiable(queue));
    _trackChangedController.add(track);
  }

  Future<void> _play(AudioTrack track) async {
    await _player.play(UrlSource(track.videoID));
    _playerState = PlayerState.playing;
    _playerStateController.add(_playerState);
  }

  Future<void> addToQueue(AudioTrack track) async {
    queue.add(track);
    _queueUpdatedController.add(List.unmodifiable(queue));

    // if nothing is playing, start playing this track
    if (queuePosition == -1) {
      queuePosition = 0;
      currentTrack = track;
      await _play(track);
      _trackChangedController.add(track);
    }
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

    if (queuePosition == -1) {
      queuePosition = 0;
    } else {
      queuePosition = queuePosition + 1;
      if (queuePosition >= queue.length) {
        if (loopQueue) {
          queuePosition = 0;
        } else {
          // stop at end
          queuePosition = -1;
          currentTrack = null;
          await _player.stop();
          _trackChangedController.addStream(Stream.empty());
          _queueUpdatedController.add(List.unmodifiable(queue));
          return;
        }
      }
    }

    currentTrack = queue[queuePosition];
    await _play(currentTrack!);
    _trackChangedController.add(currentTrack!);
  }

  Future<void> previous() async {
    if (queue.isEmpty) return;

    if (queuePosition == -1) {
      // nothing was playing, start last
      queuePosition = queue.length - 1;
    } else {
      queuePosition = queuePosition - 1;
      if (queuePosition < 0) {
        if (loopQueue) {
          queuePosition = queue.length - 1;
        } else {
          queuePosition = -1;
          currentTrack = null;
          await _player.stop();
          _trackChangedController.addStream(Stream.empty());
          _queueUpdatedController.add(List.unmodifiable(queue));
          return;
        }
      }
    }

    currentTrack = queue[queuePosition];
    await _play(currentTrack!);
    _trackChangedController.add(currentTrack!);
  }

  Future<void> removeFromQueue(int index) async {
    if (index < 0 || index >= queue.length) return;

    final wasPlayingIndex = index == queuePosition;

    queue.removeAt(index);

    if (queue.isEmpty) {
      // nothing left
      queuePosition = -1;
      currentTrack = null;
      await _player.stop();
      _queueUpdatedController.add(List.unmodifiable(queue));
      _trackChangedController.addStream(Stream.empty());
      return;
    }

    if (queuePosition > index) {
      queuePosition--;
    } else if (wasPlayingIndex) {
      if (queuePosition >= queue.length) {
        queuePosition = queue.length - 1;
      }
      currentTrack = queue[queuePosition];
      await _play(currentTrack!);
      _trackChangedController.add(currentTrack!);
    }

    if (queuePosition >= queue.length) {
      queuePosition = queue.length - 1;
    }
    if (queue.isEmpty) queuePosition = -1;

    _queueUpdatedController.add(List.unmodifiable(queue));
  }

  bool get isPlaying => _playerState == PlayerState.playing;
  PlayerState get playerState => _playerState;
  Stream<AudioTrack> get trackChanged => _trackChangedController.stream;
  Stream<List<AudioTrack>> get queueUpdated => _queueUpdatedController.stream;
  Stream<PlayerState> get playerStateChanged => _playerStateController.stream;
  Stream<int> get positionChanged => _positionController.stream;
  Future<Duration?> get currentPosition => _player.getCurrentPosition();
  int get currentIndex => queuePosition;
  int indexOfTrack(AudioTrack track) => queue.indexOf(track);

  Future<void> dispose() async {
    await _player.dispose();
    _trackChangedController.close();
    _queueUpdatedController.close();
    _playerStateController.close();
    _positionController.close();
  }
}
