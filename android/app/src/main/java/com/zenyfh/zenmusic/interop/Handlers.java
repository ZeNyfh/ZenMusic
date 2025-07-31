package com.zenyfh.zenmusic.interop;

import android.os.Handler;
import android.os.Looper;
import com.zenyfh.zenmusic.audio.AudioTrack;
import com.zenyfh.zenmusic.extractor.LRCLIBManager;
import io.flutter.plugin.common.MethodChannel;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static com.zenyfh.zenmusic.MainActivity.playerManager;
import static com.zenyfh.zenmusic.MainActivity.youTubeExtractor;

public class Handlers {
    private static final Handler mainHandler = new Handler(Looper.getMainLooper());
    private static final ExecutorService executor = Executors.newSingleThreadExecutor();

    public static void handleSeek(Object position, MethodChannel.Result result) {
        try {
            if (position == null) {
                result.error("INVALID_SEEK", "Position cannot be null", null);
                return;
            }

            // TODO: ensure positions use the same types.
            int seekPosition = playerManager.player().getPosition(); // use position in case the new seek position is something wild
            if (position instanceof Double) seekPosition = ((Double) position).intValue(); // if Double input (java)
            else if (position instanceof Integer) seekPosition = (Integer) position; // if Integer input (dart)

            playerManager.player().seek(seekPosition);
            result.success(true);
        } catch (Exception e) {
            result.error("SEEK_ERROR", e.getMessage(), null);
        }
    }

    public static void handleRemoveFromQueue(String query) {
        int index = Integer.parseInt(query);
        if (playerManager.player().nowPlaying().getQueuePosition() == index) {
            playerManager.player().nextTrack();
        }
        playerManager.player().getQueue().remove(index);
        for (int i = index; i < playerManager.player().getQueue().size(); i++) {
            AudioTrack track = playerManager.player().getQueue().get(i);
            track.setQueuePosition(track.getQueuePosition() - 1);
        }
    }

    public static void handleGetLyrics(MethodChannel.Result result) {
        executor.execute(() -> {
            String lyrics = LRCLIBManager.getLyrics(playerManager.player().nowPlaying());
            mainHandler.post(() -> result.success(lyrics));
        });
    }

    public static void handlePlay(String query, MethodChannel.Result result) {
        new Thread(() -> {
            try {
                AudioTrack track = youTubeExtractor.extractAudioTrack(query);
                if (track == null) {
                    result.error("NO_AUDIO", "No audio stream found", null);
                    return;
                }

                mainHandler.post(() -> {
                    try {
                        playerManager.player().queue(track);
                        result.success(track.getTitle());
                    } catch (Exception e) {
                        result.error("PLAY_ERROR", e.getMessage(), null);
                    }
                });
            } catch (Exception e) {
                result.error("EXTRACTION_ERROR", e.getMessage(), null);
            }
        }).start();
    }

    public static void handleSearch(String query, MethodChannel.Result result) {
        new Thread(() -> {
            try {
                result.success(youTubeExtractor.searchAudioTracks(query));
            } catch (Exception e) {
                result.error("SEARCH_ERROR", e.getMessage(), null);
            }
        }).start();
    }

}
