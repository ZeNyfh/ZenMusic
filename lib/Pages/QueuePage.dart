import 'package:flutter/material.dart';

import '../models/AudioTrack.dart';
import '../services/AudioPlayerManager.dart';

class QueuePage extends StatefulWidget {
    const QueuePage({super.key});

    @override
    State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
    late Future<List<AudioTrack>> _queueFuture;

    @override
    void initState() {
        super.initState();
        _refreshQueue();
    }

    void _refreshQueue() {
        setState(() {
            _queueFuture = AudioPlayerManager.getQueue();
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Queue'),
                actions: [
                    IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshQueue),
                ],
            ),
            body: FutureBuilder<List<AudioTrack>>(
                future: _queueFuture,
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final queue = snapshot.data ?? [];
                    if (queue.isEmpty) {
                        return const Center(child: Text('Queue is empty'));
                    }

                    return ListView.builder(
                        itemCount: queue.length,
                        itemBuilder: (context, index) {
                            final track = queue[index];
                            return ListTile(
                                leading: track.thumbnail.isNotEmpty
                                    ? AspectRatio(
                                    aspectRatio: 1,
                                    child: Image.network(
                                        track.thumbnail,
                                        fit: BoxFit.cover,
                                    ),
                                )
                                    : const Icon(Icons.music_note),
                                title: Text(track.title),
                                subtitle: Text(track.artist),
                                trailing: Text(track.durationFormatted),
                            );
                        },
                    );
                },
            ),
        );
    }
}
