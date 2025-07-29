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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller, // Added controller from working version
                  decoration: InputDecoration(
                    labelText: 'Search YouTube',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                  onSubmitted: (_) => _play(), // Added from working version
                ),
              ),
              const SizedBox(width: 2),
              // Search Button
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _isLoading ? null : () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _play();
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  shape: const CircleBorder(),
                  side: BorderSide.none,
                ),
                padding: const EdgeInsets.all(12),
              ),
            ],
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
