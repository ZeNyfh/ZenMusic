import 'package:flutter/material.dart';

import '../services/AudioPlayerManager.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AudioPlayerManager.queue.isEmpty
          ? const Center(child: Text('Queue is empty'))
          : ListView.builder(
              itemCount: AudioPlayerManager.queue.length,
              itemBuilder: (context, index) {
                final track = AudioPlayerManager.queue[index];
                final isCurrent = AudioPlayerManager.currentTrack == track;
                final scale = 1.4;
                final duration = track.length > 0 ? track.durationFormatted : 'Live';

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
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.music_note,
                                    size: 20 * scale,
                                  ),
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
                    track.artist.isNotEmpty ? track.artist : 'Unknown artist',
                    style: TextStyle(fontSize: 12 * scale / 1.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        duration,
                        style: TextStyle(fontSize: 12 * scale / 1.5),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          try {
                            await AudioPlayerManager.removeFromQueue(index);
                            setState(() {});
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: isCurrent
                      ? null
                      : () async {
                          try {
                            await AudioPlayerManager.play(track.videoID);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Playback error: ${e.toString()}')),
                            );
                          }
                        },
                );
              },
            ),
    );
  }
}
