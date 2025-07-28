package com.zenyfh.zenmusic.audio;

import android.net.Uri;

public class AudioTrack {
    public String artist;
    public String name;
    public Uri thumbnail;
    public int length; // in seconds
    public String streamUrl; // required for playback

    public AudioTrack(String artist, String name, Uri thumbnail, int length, String streamUrl) {
        this.artist = artist;
        this.name = name;
        this.thumbnail = thumbnail;
        this.length = length;
        this.streamUrl = streamUrl;
    }
}
