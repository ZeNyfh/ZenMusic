import 'package:flutter/material.dart';
import 'package:zenmusic/services/AudioPlayer.dart';
import 'package:zenmusic/services/NavService.dart';
import 'package:zenmusic/services/objects/AudioTrack.dart';

import 'objects/CustomNavBar.dart';

class NPPage extends StatelessWidget {
  const NPPage({super.key});

  @override
  Widget build(BuildContext context) {
    // variable pre-definitions that will be used here.
    /// Player vars
    AudioTrack? track = AudioPlayer.getCurrentTrack();
    double _duration = track == null ? -1.0 : track.duration;
    int _position = track == null ? -1 : track.position;
    String? _title = track == null ? "Unknown Title" : track.title;
    String? _artist = track == null ? "Unknown Artist" : track.artist;
    /// Image vars
    String? _thumbnail = track == null ? "" : track.thumbnail;
    bool _showLyrics = AudioPlayer().toggleLyrics();
    String _lyrics = "";

    void _getLyrics() {
      _lyrics = track == null ? "" : track.lyrics;
    }

    return Scaffold(
      backgroundColor: Color(0xffffffff),
      bottomNavigationBar: CustomNavBar(currentIndex: 1, context: context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: Color(0x1f000000),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: Color(0x4d9e9e9e), width: 1),
            ),
            child: Image( // todo: make this clickable, call _getLyrics()
              image: NetworkImage(_thumbnail),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  _title,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 18,
                    color: Color(0xff000000),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: Text(
                    _artist,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {},
                        color: Color(0xff212435),
                        iconSize: 24,
                      ),
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {},
                        color: Color(0xff212435),
                        iconSize: 30,
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {},
                        color: Color(0xff212435),
                        iconSize: 24,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () {},
                      color: Color(0xff212435),
                      iconSize: 18,
                    ),
                    Slider(
                      onChanged: (value) {},
                      value: 0,
                      min: 0,
                      max: _duration,
                      activeColor: Color(0xff3a57e8),
                      inactiveColor: Color(0xff9e9e9e),
                      divisions: _duration as int?,
                    ),
                    Text(
                      "$_position/$_duration",
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontStyle: FontStyle.normal,
                        fontSize: 12,
                        color: Color(0xff000000),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
