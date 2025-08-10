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

  Future<void> _handleSubmit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _error = null;
      _isLoading = true;
      _searchResults = [];
    });

    try {
      if (_isUrl(text)) {
        await AudioPlayerManager.play(text);
      } else {
        final results = await AudioPlayerManager.search(text);
        setState(() => _searchResults = results);
      }
    } catch (e) {
      setState(() => _error = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isUrl(String text) {
    return text.startsWith('http://') || text.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      hintText: 'Search or enter URL',
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
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        _isLoading
                            ? 'Searching...'
                            : _controller.text.isEmpty
                            ? 'Enter a search term or URL'
                            : 'No results found',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final track = _searchResults[index];
                        final scale = 1.4;
                        final duration = track.length > 0 ? track.durationFormatted : 'Live';

                        return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                          minVerticalPadding: 8 * scale,
                          minLeadingWidth: 40 * scale,
                          leading: track.thumbnail.isNotEmpty
                              ? SizedBox(
                                  width: 40 * scale / 1.2,
                                  height: 40 * scale / 1.2,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      track.thumbnail,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.music_note,
                                        size: 20 * scale / 1.2,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  width: 40 * scale,
                                  height: 40 * scale,
                                  child: Icon(
                                    Icons.music_note,
                                    size: 20 * scale,
                                  ),
                                ),
                          title: Text(
                            track.title,
                            style: TextStyle(fontSize: 14 * scale / 1.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            track.artist.isNotEmpty ? track.artist : 'Unknown artist',
                            style: TextStyle(fontSize: 12 * scale / 1.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            duration,
                            style: TextStyle(fontSize: 12 * scale / 1.5),
                          ),
                          onTap: _isLoading
                              ? null
                              : () async {
                                  try {
                                    await AudioPlayerManager.play(track.videoID);
                                  } catch (e) {
                                    setState(() => _error = 'Playback error: ${e.toString()}');
                                  }
                                },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _controller.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleSubmit());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
