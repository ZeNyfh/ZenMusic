import 'package:flutter/material.dart';

import '../services/AudioPlayerManager.dart';

class YouTubePlayer extends StatefulWidget {
  const YouTubePlayer({super.key});

  @override
  State<YouTubePlayer> createState() => _YouTubePlayerState();
}

class _YouTubePlayerState extends State<YouTubePlayer> {
  final _controller = TextEditingController();
  String _status = "Enter a song name";
  bool _isLoading = false;

  Future<void> _play() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _status = "Loading...";
    });

    try {
      final title = await AudioPlayerManager.play(_controller.text);
      setState(() => _status = title ?? "Added to queue");
    } catch (e) {
      setState(() => _status = "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
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
                onPressed: _isLoading ? null : _play,
              ),
            ),
            onSubmitted: (_) => _play(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : () {
              FocusManager.instance.primaryFocus?.unfocus(); // hide keyboard when play is clicked.
              _play();
            },
            child: const Text('Play'),
          ),
          const SizedBox(height: 20),
          Text(
            _status,
            style: TextStyle(
              fontSize: 18,
              color: _status.startsWith("Error") ? Colors.red : Colors.black,
            ),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
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
