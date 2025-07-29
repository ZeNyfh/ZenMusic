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

// Define this at the top of your widget (or file)
                    final double scale = 1.4; // Adjust this value (0.7 = smaller, 1.0 = normal, 1.2 = larger)

                    return ListView.builder(
                        itemCount: queue.length,
                        itemBuilder: (context, index) {
                            final track = queue[index];
                            return ListTile(
                                dense: true, // Makes ListTile more compact
                                visualDensity: VisualDensity.compact, // Further reduces padding
                                contentPadding: EdgeInsets.symmetric(horizontal: 8.0 * scale), // Scales padding
                                minVerticalPadding: 8 * scale, // Reduces space between title & subtitle
                                minLeadingWidth: 40 * scale, // Adjusts leading widget width
                                leading: track.thumbnail.isNotEmpty
                                    ? SizedBox(
                                    width: 40 * scale, // Scales thumbnail size
                                    height: 40 * scale,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                            track.thumbnail,
                                            fit: BoxFit.cover,
                                        ),
                                    ),
                                )
                                    : SizedBox(
                                    width: 40 * scale,
                                    height: 40 * scale,
                                    child: Icon(Icons.music_note, size: 20 * scale), // Scales icon
                                ),
                                title: Text(
                                    track.title,
                                    style: TextStyle(fontSize: 14 * scale/1.5), // Scales text
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                    track.artist,
                                    style: TextStyle(fontSize: 12 * scale/1.5), // Scales text
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                    track.durationFormatted,
                                    style: TextStyle(fontSize: 12 * scale/1.5), // Scales text
                                ),
                            );
                        },
                    );
                },
            ),
        );
    }
}
