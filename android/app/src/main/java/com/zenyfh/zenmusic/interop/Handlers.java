package com.zenyfh.zenmusic.interop;

import android.os.Handler;
import android.os.Looper;
import com.zenyfh.zenmusic.AudioTrack;
import com.zenyfh.zenmusic.extractor.LRCLIBManager;
import io.flutter.plugin.common.MethodChannel;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static com.zenyfh.zenmusic.MainActivity.youTubeExtractor;

public class Handlers {
    private static final Handler mainHandler = new Handler(Looper.getMainLooper());
    private static final ExecutorService executor = Executors.newSingleThreadExecutor();

    public static void handleGetLyrics(Object queryData, MethodChannel.Result result) {
        executor.execute(() -> {
            try {
                String[] queryList = (String[]) queryData;
                String title = queryList[0];
                String artist = queryList[1];
                boolean isStream = Boolean.parseBoolean(queryList[2]);
                String streamUrl = queryList[3];

                String lyrics = LRCLIBManager.getLyrics(new String[]{title, artist, String.valueOf(isStream), streamUrl});
                mainHandler.post(() -> result.success(lyrics));
            } catch (Exception e) {
                mainHandler.post(() -> result.error("LYRICS_ERROR", e.getMessage(), null));
            }
        });
    }

    public static void handleExtractAudioTrack(String url, MethodChannel.Result result) {
        executor.execute(() -> {
            try {
                AudioTrack track = youTubeExtractor.extractAudioTrack(url);
                if (track == null) {
                    result.error("NO_AUDIO", "No audio stream found", null);
                    return;
                }
                mainHandler.post(() -> result.success(track.getMapObject()));
            } catch (Exception e) {
                result.error("EXTRACTION_ERROR", e.getMessage(), null);
            }
        });
    }

    public static void handleSearch(String query, MethodChannel.Result result) {
        executor.execute(() -> {
            try {
                result.success(youTubeExtractor.searchAudioTracks(query));
            } catch (Exception e) {
                result.error("SEARCH_ERROR", e.getMessage(), null);
            }
        });
    }
}