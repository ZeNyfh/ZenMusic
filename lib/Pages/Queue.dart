import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Track {
  final String artist;
  final String title;
  final String thumbnail;
  final int length;
  final int position;
  final String streamUrl;

  Track({
    required this.artist,
    required this.title,
    required this.thumbnail,
    required this.length,
    required this.position,
    required this.streamUrl,
  });

  factory Track.fromMap(Map<dynamic, dynamic> map) {
    return Track(
      artist: map['artist'] ?? '',
      title: map['title'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      length: map['length'] ?? 0,
      position: map['position'] ?? 0,
      streamUrl: map['streamUrl'] ?? '',
    );
  }
}

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  static const platform = MethodChannel('com.zenyfh.zenmusic/audio');
  List<Track> _queue = [];
  bool _loading = true;

  Future<void> _loadQueue() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getQueue');
      setState(() {
        _queue = result.map((trackMap) => Track.fromMap(trackMap)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _queue = [];
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Queue')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _queue.length,
        itemBuilder: (context, index) {
          final track = _queue[index];
          return ListTile(
            leading: Image.network(track.thumbnail),
            title: Text(track.title),
            subtitle: Text(track.artist),
            trailing: Text(formatDuration(track.length)),
          );
        },
      ),
    );
  }
}

String formatDuration(int ms) {
  final seconds = (ms / 1000).round();
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
}
