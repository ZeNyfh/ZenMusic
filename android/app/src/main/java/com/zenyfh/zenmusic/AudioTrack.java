package com.zenyfh.zenmusic;

import org.jetbrains.annotations.NotNull;

import java.util.HashMap;
import java.util.Map;

public class AudioTrack {
    private final String artist;
    private final String title;
    private final String thumbnail;
    private final int length;   // seconds
    private final String streamUrl;
    private final int position;       // seconds
    private final boolean isStream;
    private final Map<String, Object> mapObject;
    private final int queuePosition;

    public AudioTrack(String artist, String title, String thumbnail, int length, int position, int queuePosition, String streamUrl, boolean isStream) {
        this.artist = artist;
        this.title = title;
        this.thumbnail = thumbnail;
        this.length = length;
        this.position = position;
        this.queuePosition = queuePosition;
        this.streamUrl = streamUrl;
        this.isStream = isStream;
        this.mapObject = createMapObject();
    }

    private Map<String, Object> createMapObject() {
        Map<String, Object> mapObject = new HashMap<>();
        mapObject.put("artist", artist);
        mapObject.put("title", title);
        mapObject.put("thumbnail", thumbnail);
        mapObject.put("length", length);
        mapObject.put("position", position);
        mapObject.put("queuePosition", queuePosition);
        mapObject.put("streamUrl", streamUrl);
        mapObject.put("isStream", isStream);
        return mapObject;
    }

    public Map<String, Object> getMapObject() {
        return mapObject;
    }

    @NotNull
    @Override
    public String toString() {
        return String.format("AudioTrack(%s - %s)", artist, title);
    }
}
