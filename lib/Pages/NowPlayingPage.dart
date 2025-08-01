import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/AudioTrack.dart';
import '../services/AudioPlayerManager.dart';
import 'SearchPage.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  AudioTrack? _currentTrack; // Make nullable
  bool _isPlaying = true;
  bool _isOverlayVisible = false;
  bool _isSearchOverlayVisible = false;
  String? _searchQuery;
  Timer? _progressTimer;
  int _currentPosition = 0;
  StreamSubscription? _trackChangeSubscription;
  final EventChannel _eventChannel = const EventChannel(
    'com.zenyfh.zenmusic/audio_events',
  );

  Widget _buildSearchOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7), // dimmed background
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(maxHeight: 650, maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // search results
                Expanded(child: SearchPage(initialQuery: _searchQuery)),
                const SizedBox(height: 12),

                // close button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      backgroundColor: Colors.grey[100],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearchOverlayVisible = false;
                        _searchQuery = null;
                      });
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
      if (_isPlaying) {
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
      if (mounted) {
        setState(() {
          _currentTrack = track;
          if (track != null) {
            _currentPosition = track.position;
          }
        });
      }
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
    // Handle loading state
    if (_currentTrack == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Loading track...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    final track = _currentTrack!;

    // show message if no track is playing
    if (_currentTrack == null) {
      return Scaffold(
        body: Center(child: Text('No track playing')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _toggleOverlay,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          track.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                        ),
                        if (_isOverlayVisible)
                          Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.all(20.0),
                            child: FutureBuilder<String>(
                              future: AudioPlayerManager.getLyrics(),
                              builder: (context, snapshot) {
                                final lyrics = snapshot.data ?? 'Loading lyrics...';

                                return SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _currentTrack!.title,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _currentTrack!.artist, // Safe
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        lyrics,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
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
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isSearchOverlayVisible = true;
                        _searchQuery = _currentTrack!.artist; // Safe
                      });
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        _currentTrack!.artist,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // progress bar
                Row(
                  children: [
                    // current pos
                    Text(_formatDuration(_currentPosition)),
                    // slider
                    Expanded(
                      child: Slider(
                        value: _currentPosition.toDouble().clamp(
                          0,
                          _currentTrack!.length.toDouble(),
                        ),
                        min: 0,
                        max: _currentTrack!.length.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            _currentPosition = value.toInt();
                          });
                        },
                        onChangeEnd: (value) async {
                          try {
                            await AudioPlayerManager.seek(value.toInt());
                            final newPosition = await AudioPlayerManager.getPosition();
                            if (mounted) {
                              setState(() {
                                _currentPosition = newPosition;
                              });
                            }
                          } catch (e) {
                            print('Seek failed: $e');
                            final currentPos = await AudioPlayerManager.getPosition();
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
          if (_isSearchOverlayVisible) _buildSearchOverlay(),
        ],
      ),
    );
  }
}
