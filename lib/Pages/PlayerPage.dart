import 'package:flutter/material.dart';

import '../models/AudioTrack.dart';
import '../services/AudioPlayerManager.dart';

class YouTubePlayer extends StatefulWidget {
    const YouTubePlayer({super.key});

    @override
    State<YouTubePlayer> createState() => _YouTubePlayerState();
}

class _YouTubePlayerState extends State<YouTubePlayer> {
    final _controller = TextEditingController();
    bool _isLoading = false;
    bool _isAddingToQueue = false;
    List<AudioTrack> _searchResults = [];
    String? _error;

    Future<void> _handleSubmit() async {
        final text = _controller.text.trim();
        if (text.isEmpty) return;

        // Clear previous errors
        setState(() => _error = null);

        if (_isUrl(text)) {
            // Direct URL play
            setState(() => _isAddingToQueue = true);
            try {
                await AudioPlayerManager.play(text);
            } catch (e) {
                setState(() => _error = 'Playback error: $e');
            } finally {
                setState(() => _isAddingToQueue = false);
            }
        } else {
            // Perform search
            setState(() => _isLoading = true);
            try {
                final results = await AudioPlayerManager.search(text);
                setState(() => _searchResults = results);
            } catch (e) {
                setState(() => _error = 'Search error: $e');
            } finally {
                setState(() => _isLoading = false);
            }
        }
    }

    bool _isUrl(String text) {
        return text.startsWith('http://') || text.startsWith('https://');
    }

    Future<void> _playTrack(AudioTrack track) async {
        setState(() => _isAddingToQueue = true);
        try {
            await AudioPlayerManager.play(track.streamUrl);
        } catch (e) {
            setState(() => _error = 'Playback error: $e');
        } finally {
            setState(() => _isAddingToQueue = false);
        }
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                children: [
                    // Search bar
                    Row(
                        children: [
                            Expanded(
                                child: TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(
                                        labelText: 'Search YouTube',
                                        border: const OutlineInputBorder(),
                                        contentPadding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal: 16,
                                        ),
                                    ),
                                    onSubmitted: (_) => _handleSubmit(),
                                ),
                            ),
                            const SizedBox(width: 2),
                            IconButton(
                                icon: const Icon(Icons.search),
                                onPressed:
                                (_isLoading || _isAddingToQueue) ? null : _handleSubmit,
                                // ... button styling ...
                            ),
                        ],
                    ),

                    const SizedBox(height: 20),

                    // status indicators
                    if (_isLoading) const CircularProgressIndicator(),
                    if (_error != null)
                        Text(
                            _error!,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),

                    // search results
                    Expanded(
                        child: _searchResults.isEmpty
                                ? Center(
                            child: Text(
                                _isLoading ? '' : _controller.text.isEmpty ? 'Enter a search term' : 'No results found',
                            ),
                        )
                                : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                                final track = _searchResults[index];
                                return ListTile(
                                    leading: track.thumbnail != null ? Image.network(track.thumbnail!) : null,
                                    title: Text(track.title),
                                    subtitle: Text(track.artist ?? 'Unknown artist'),
                                    onTap: _isAddingToQueue ? null : () => _playTrack(track),
                                );
                            },
                        ),
                    ),
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
