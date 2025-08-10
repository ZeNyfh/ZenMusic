import 'dart:async';

import 'package:flutter/material.dart';

import '../services/AudioPlayerManager.dart';
import 'SearchPage.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  bool _isOverlayVisible = false;
  bool _isSearchOverlayVisible = false;
  String? _searchQuery;
  int _currentPosition = 0;
  bool _isSeeking = false;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _trackChangeSubscription;

  Future<void> _getCurrentPosition() async {
    try {
      final position = await AudioPlayerManager.currentPosition;
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    } catch (e) {
      print('Error getting position: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPosition = 0;

    _getCurrentPosition();

    _positionSubscription = AudioPlayerManager.positionChanged.listen((position) {
      if (!_isSeeking) {
        setState(() => _currentPosition = position);
      }
    });

    _trackChangeSubscription = AudioPlayerManager.trackChanged.listen((_) {
      setState(() => _currentPosition = 0);
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _trackChangeSubscription?.cancel();
    super.dispose();
  }

  Widget _buildSearchOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
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

  void _toggleOverlay() {
    setState(() => _isOverlayVisible = !_isOverlayVisible);
  }

  void _playPause() {
    if (AudioPlayerManager.isPlaying) {
      AudioPlayerManager.pause();
    } else {
      AudioPlayerManager.resume();
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (AudioPlayerManager.currentTrack == null) {
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

    final track = AudioPlayerManager.currentTrack!;
    final maxDuration = track.length > 0 ? track.length : 1;
    final displayPosition = _currentPosition.clamp(0, maxDuration);

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
                              future: AudioPlayerManager.getLyrics([track.title, track.artist, track.isStream ? "True" : "False", track.videoID]),
                              // {title, artist, isStream, streamURL}
                              builder: (context, snapshot) {
                                final lyrics = snapshot.data ?? 'Loading lyrics...';

                                return SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        track.title,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        track.artist,
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
                  track!.title,
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
                        _searchQuery = track.artist;
                      });
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        track.artist,
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
                    Text(_formatDuration(displayPosition)),
                    Expanded(
                      child: Slider(
                        value: displayPosition.toDouble(),
                        min: 0,
                        max: maxDuration.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            _currentPosition = value.toInt();
                            _isSeeking = true;
                          });
                        },
                        onChangeEnd: (value) {
                          AudioPlayerManager.seek(value.toInt());
                          _isSeeking = false;
                        },
                      ),
                    ),
                    Text(_formatDuration(maxDuration)),
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
                      onPressed: AudioPlayerManager.previous,
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      icon: Icon(AudioPlayerManager.isPlaying ? Icons.pause : Icons.play_arrow),
                      iconSize: 64,
                      onPressed: _playPause,
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 48,
                      onPressed: AudioPlayerManager.next,
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
