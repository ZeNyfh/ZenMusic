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
  AudioTrack? _currentTrack;

  @override
  void initState() {
    super.initState();
    _refreshQueue();
  }

  void _refreshQueue() async {
    setState(() {
      _queueFuture = AudioPlayerManager.getQueue();
    });

    final current = await AudioPlayerManager.getCurrentTrack();
    setState(() {
      _currentTrack = current;
    });
  }

  void _removeFromQueue(int index) async {
    await AudioPlayerManager.removeFromQueue(index);
    _refreshQueue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          final double scale = 1.4;
          return ListView.builder(
            itemCount: queue.length,
            itemBuilder: (context, index) {
              final track = queue[index];
              final isCurrent = _currentTrack == track;

              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0 * scale),
                minVerticalPadding: 8 * scale,
                minLeadingWidth: 40 * scale,
                leading: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    track.thumbnail.isNotEmpty
                        ? SizedBox(
                            width: 40 * scale,
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
                            child: Icon(Icons.music_note, size: 20 * scale),
                          ),
                    if (isCurrent)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Icon(
                          Icons.equalizer,
                          size: 16 * scale,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
                title: Text(
                  track.title,
                  style: TextStyle(
                    fontSize: 14 * scale / 1.5,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  track.artist,
                  style: TextStyle(fontSize: 12 * scale / 1.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      track.durationFormatted,
                      style: TextStyle(fontSize: 12 * scale / 1.5),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async => _removeFromQueue(await track.queuePosition),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
