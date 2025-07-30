import 'package:flutter/material.dart';

import '../models/AudioTrack.dart';
import '../services/AudioPlayerManager.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  List<AudioTrack> _searchResults = [];
  String? _error;

  final List<AudioTrack> _playQueue = [];
  bool _isProcessingQueue = false;

  Future<void> _handleSubmit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // clear previous errors
    setState(() => _error = null);

    if (_isUrl(text)) {
      // direct URL play
      setState(() => _isLoading = true);
      try {
        await AudioPlayerManager.play(text);
      } catch (e) {
        setState(() => _error = 'Playback error: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      // search
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

  void _enqueueTrack(AudioTrack track) {
    _playQueue.add(track);
    _processQueue();
  }

  void _processQueue() async {
    if (_isProcessingQueue) return;

    _isProcessingQueue = true;

    while (_playQueue.isNotEmpty) {
      final currentTrack = _playQueue.removeAt(0);
      try {
        await AudioPlayerManager.play(currentTrack.streamUrl);
      } catch (e) {
        setState(() => _error = 'Playback error: $e');
      }
    }

    _isProcessingQueue = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // search bar
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
                  onPressed: _isLoading ? null : _handleSubmit,
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
                  const scale = 1.4;

                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 0),
                    minVerticalPadding: 8 * scale,
                    minLeadingWidth: 40 * scale,
                    leading: track.thumbnail != "" && track.thumbnail.isNotEmpty ? SizedBox(
                      width: 40 * scale/1.2,
                      height: 40 * scale/1.2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          track.thumbnail,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ) : SizedBox(
                      width: 40 * scale,
                      height: 40 * scale,
                      child: Icon(Icons.music_note, size: 20 * scale),
                    ),
                    title: Text(
                      track.title,
                      style: TextStyle(fontSize: 14 * scale / 1.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      track.artist ?? 'Unknown artist',
                      style: TextStyle(fontSize: 12 * scale / 1.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      track.durationFormatted,
                      style: TextStyle(fontSize: 12 * scale / 1.5),
                    ),
                    onTap: _isLoading ? null : () => _enqueueTrack(track),
                  );
                },
              ),
            )

          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialQuery != null &&
        widget.initialQuery!.trim().isNotEmpty) {
      _controller.text = widget.initialQuery!;
      _handleSubmit();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
