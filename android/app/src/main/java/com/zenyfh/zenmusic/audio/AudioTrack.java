package com.zenyfh.zenmusic.audio;

import android.net.Uri;
import org.jetbrains.annotations.NotNull;

public class AudioTrack {
    private final String artist;
    private final String title;
    private final Uri thumbnail;
    private final int length;   // seconds
    private int queuePosition;
    private final String streamUrl;
    private final int position;       // seconds
    private final boolean isStream;

    public AudioTrack(String artist, String title, Uri thumbnail, int length, int position, int queuePosition, String streamUrl, boolean isStream) {
        this.artist = artist;
        this.title = title;
        this.thumbnail = thumbnail;
        this.length = length;
        this.position = position;
        this.queuePosition = queuePosition;
        this.streamUrl = streamUrl;
        this.isStream = isStream;
    }

    public void setQueuePosition(int i) {
        this.queuePosition = i;
    }
    public int queuePosition() {
        return queuePosition;
    }
    public boolean isStream() {
        return isStream;
    }

    public String getArtist() {
        return artist;
    }

    public String getTitle() {
        return title;
    }

    public Uri getThumbnail() {
        return thumbnail;
    }

    public int getLength() {
        return length;
    }

    public int getPosition() {
        return position;
    }

    public int getQueuePosition() {
        return queuePosition;
    }
    public String getStreamUrl() {
        return streamUrl;
    }

    @NotNull
    @Override
    public String toString() {
        return String.format("AudioTrack(%s - %s)", artist, title);
    }
}
