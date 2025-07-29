import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/AudioTrack.dart';
import '../services/AudioPlayerManager.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  AudioTrack? _currentTrack;
  bool _isPlaying = true;
  bool _isOverlayVisible = false;
  Timer? _progressTimer;
  int _currentPosition = 0;
  StreamSubscription? _trackChangeSubscription;
  final EventChannel _eventChannel = const EventChannel(
    'com.zenyfh.zenmusic/audio_events',
  );

  @override
  void initState() {
    super.initState();
    _loadCurrentTrack();
    _startProgressTimer();
    _setupTrackChangeListener();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _trackChangeSubscription?.cancel();
    super.dispose();
  }

  void _setupTrackChangeListener() {
    _trackChangeSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event == 'track_changed') {
          _loadCurrentTrack();
          setState(() {
            _currentPosition = 0;
          });
        }
      },
      onError: (error) {
        print('Error receiving track change events: $error');
      },
    );
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_isPlaying && _currentTrack != null) {
        try {
          final position = await AudioPlayerManager.getPosition();
          if (mounted) {
            setState(() {
              _currentPosition = position;
            });
          }
        } catch (e) {
          print('Error updating position: $e');
        }
      }
    });
  }

  Future<void> _loadCurrentTrack() async {
    try {
      final track = await AudioPlayerManager.getCurrentTrack();
      setState(() {
        _currentTrack = track;
      });
    } catch (e) {
      print('Error loading current track: $e');
    }
  }

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }

  void _playPause() async {
    try {
      if (_isPlaying) {
        await AudioPlayerManager.pause();
      } else {
        await AudioPlayerManager.resume();
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      print('Play/Pause error: $e');
    }
  }

  void _skipToPrevious() async {
    try {
      await AudioPlayerManager.previous();
      await _loadCurrentTrack();
    } catch (e) {
      print('Previous track error: $e');
    }
  }

  void _skipToNext() async {
    try {
      await AudioPlayerManager.next();
      await _loadCurrentTrack();
    } catch (e) {
      print('Next track error: $e');
    }
  }

  void _onSeek(double value) async {
    try {
      setState(() {
        _currentPosition = value.toInt();
      });

      await AudioPlayerManager.seek(value.toInt());

      final newPosition = await AudioPlayerManager.getPosition();
      if (mounted) {
        setState(() {
          _currentPosition = newPosition;
        });
      }
    } catch (e) {
      print('Seek error: $e');
      final currentPos = await AudioPlayerManager.getPosition();
      if (mounted) {
        setState(() {
          _currentPosition = currentPos;
        });
      }
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_currentTrack == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Now Playing')),
        body: const Center(child: Text('No track playing')),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _toggleOverlay,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    _currentTrack!.thumbnail,
                    height: MediaQuery.of(context).size.height * 0.35,
                    fit: BoxFit.cover,
                  ),
                  if (_isOverlayVisible)
                    FutureBuilder<String>(
                      future: AudioPlayerManager.getLyrics(),
                      builder: (context, snapshot) {
                        final lyrics = snapshot.data ?? 'Loading lyrics...';

                        return Container(
                          color: Colors.black54,
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    _currentTrack!.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Center(
                                  child: Text(
                                    _currentTrack!.artist,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    lyrics,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // track title and artist
            Text(
              _currentTrack!.title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              _currentTrack!.artist,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 32),

            // progress bar
            Row(
              children: [
                // current pos
                FutureBuilder<int>(
                  future: _currentTrack!.position,
                  builder: (context, snapshot) {
                    final position = snapshot.hasData ? snapshot.data! : 0;
                    return Text(_formatDuration(position));
                  },
                ),

                // slider
                Expanded(
                  child: Slider(
                    value: _currentPosition.toDouble().clamp(
                      0,
                      _currentTrack?.length.toDouble() ?? 1,
                    ),
                    min: 0,
                    max: _currentTrack?.length.toDouble() ?? 1,
                    onChanged: (value) {
                      setState(() {
                        _currentPosition = value.toInt();
                      });
                    },
                    // after user moved the position slider.
                    onChangeEnd: (value) async {
                      try {
                        await AudioPlayerManager.seek(value.toInt());
                        final newPosition =
                            await AudioPlayerManager.getPosition();
                        if (mounted) {
                          setState(() {
                            _currentPosition = newPosition;
                          });
                        }
                      } catch (e) {
                        print('Seek failed: $e');
                        // revert if seek fail.
                        final currentPos =
                            await AudioPlayerManager.getPosition();
                        if (mounted) {
                          setState(() {
                            _currentPosition = currentPos;
                          });
                        }
                      }
                    },
                  ),
                ),

                Text(_formatDuration(_currentTrack!.length)),
              ],
            ),
            const SizedBox(height: 32),

            // playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 48,
                  onPressed: _skipToPrevious,
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 64,
                  onPressed: _playPause,
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  iconSize: 48,
                  onPressed: _skipToNext,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
