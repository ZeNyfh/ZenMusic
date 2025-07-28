package com.zenyfh.zenmusic;

import android.os.Bundle;
import androidx.annotation.NonNull;
import com.yausername.youtubedl_android.YoutubeDL;
import com.yausername.youtubedl_android.YoutubeDLException;
import com.zenyfh.zenmusic.audio.AudioTrack;
import com.zenyfh.zenmusic.extractor.YouTubeExtractor;
import com.zenyfh.zenmusic.player.PlayerManager;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.zenyfh.zenmusic/audio";
    private PlayerManager playerManager;
    private YouTubeExtractor youTubeExtractor;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initializeDependencies();
    }

    private void initializeDependencies() {
        try {
            // Initialize YouTubeDL
            YoutubeDL.getInstance().init(getApplication());

            // Initialize services
            playerManager = new PlayerManager(this);
            youTubeExtractor = new YouTubeExtractor();

            // Set up event listeners
            playerManager.setTrackEventListener(new PlayerManager.TrackEventListener() {
                @Override
                public void onTrackStart(AudioTrack track) {
                    System.out.println("Track started: " + track.getTitle());
                }

                @Override
                public void onTrackEnd(AudioTrack track) {
                    System.out.println("Track ended: " + track.getTitle());
                    playerManager.playNextTrack();
                }
            });
        } catch (YoutubeDLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(this::handleMethodCall);
    }

    private void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "play":
                handlePlayRequest(call.argument("query"), result);
                break;
            case "getQueue":
                handleGetQueueRequest(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void handlePlayRequest(String query, MethodChannel.Result result) {
        new Thread(() -> {
            try {
                AudioTrack track = youTubeExtractor.extractAudioTrack(query);
                runOnUiThread(() -> {
                    if (track != null) {
                        playerManager.queueTrack(track);
                        result.success(track.getTitle());
                    } else {
                        result.error("NO_AUDIO", "No audio stream found", null);
                    }
                });
            } catch (Exception e) {
                runOnUiThread(() ->
                        result.error("EXTRACTION_ERROR", e.getMessage(), null));
            }
        }).start();
    }

    private void handleGetQueueRequest(MethodChannel.Result result) {
        try {
            List<AudioTrack> queue = playerManager.getQueue();
            result.success(convertQueueToMap(queue));
        } catch (Exception e) {
            result.error("QUEUE_ERROR", e.getMessage(), null);
        }
    }

    private List<Map<String, Object>> convertQueueToMap(List<AudioTrack> queue) {
        List<Map<String, Object>> result = new ArrayList<>();
        for (AudioTrack track : queue) {
            Map<String, Object> map = new HashMap<>();
            map.put("artist", track.getArtist());
            map.put("title", track.getTitle());
            map.put("thumbnail", track.getThumbnail().toString());
            map.put("length", track.getLength());
            map.put("position", track.getPosition());
            map.put("streamUrl", track.getStreamUrl());
            result.add(map);
        }
        return result;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (playerManager != null) {
            playerManager.release();
        }
    }
}