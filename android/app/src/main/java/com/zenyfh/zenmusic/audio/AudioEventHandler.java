package com.zenyfh.zenmusic.audio;

public class AudioEventHandler {
    private static TrackEventListener eventListener;


    public static TrackEventListener getTrackEventListener() {
        return eventListener;
    }

    public static void setTrackEventListener(TrackEventListener listener) {
        eventListener = listener;
    }

    public interface TrackEventListener {
        void onTrackStart(AudioTrack track);

        void onTrackEnd(AudioTrack track);
    }
}
