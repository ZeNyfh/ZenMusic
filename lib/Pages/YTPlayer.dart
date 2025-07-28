import 'package:flutter/material.dart';
import '../services/audioservice.dart';

class YouTubePlayer extends StatefulWidget {
  const YouTubePlayer({super.key});

  @override
  State<YouTubePlayer> createState() => _YouTubePlayerState();
}

class _YouTubePlayerState extends State<YouTubePlayer> {
  final _controller = TextEditingController();
  String _status = "Enter a song name";

  Future<void> _play() async {
    if (_controller.text.isEmpty) return;

    setState(() => _status = "Loading...");
    final title = await AudioPlayerService.play(_controller.text);
    setState(() => _status = title ?? "Playback failed");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Search YouTube',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _play,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _play,
            child: const Text('Play'),
          ),
          const SizedBox(height: 20),
          Text(_status, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
