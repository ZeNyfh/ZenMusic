package com.zenyfh.zenmusic;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import com.yausername.youtubedl_android.YoutubeDL;
import com.yausername.youtubedl_android.YoutubeDLException;
import com.zenyfh.zenmusic.audio.AudioEventHandler;
import com.zenyfh.zenmusic.audio.AudioTrack;
import com.zenyfh.zenmusic.extractor.LRCLIBManager;
import com.zenyfh.zenmusic.extractor.YouTubeExtractor;
import com.zenyfh.zenmusic.player.PlayerManager;
import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static com.zenyfh.zenmusic.audio.AudioEventHandler.setTrackEventListener;
import static com.zenyfh.zenmusic.extractor.LRCLIBManager.getLyrics;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.zenyfh.zenmusic/audio";
    private static final String EVENT_CHANNEL = "com.zenyfh.zenmusic/audio_events";
    private PlayerManager playerManager;
    private YouTubeExtractor youTubeExtractor;
    private EventChannel.EventSink eventSink;
    private final ExecutorService executor = Executors.newSingleThreadExecutor();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        init();
    }

    private void init() {
        try {
            executor.execute(() -> {
                try {
                    YoutubeDL.getInstance().updateYoutubeDL(this, YoutubeDL.UpdateChannel._NIGHTLY);
                } catch (YoutubeDLException e) {
                    throw new RuntimeException(e);
                }
            });
            YoutubeDL.getInstance().init(getApplication());
            playerManager = new PlayerManager(this);
            youTubeExtractor = new YouTubeExtractor();
            setTrackEventListener(new AudioEventHandler.TrackEventListener() {
                @Override
                public void onTrackStart(AudioTrack track) {
                    System.out.println("Track started: " + track.getTitle());
                    if (eventSink != null) {
                        eventSink.success("track_changed");
                    }
                }

                @Override
                public void onTrackEnd(AudioTrack track) {
                    System.out.println("Track ended: " + track.getTitle());
                    playerManager.player().nextTrack();
                }
            });
        } catch (YoutubeDLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // command channel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(this::handleMethodCall);

        // event channel
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL)
                .setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        eventSink = null;
                    }
                });
    }

    private void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "search":
                handleSearchRequest(call.argument("query"), result);
                break;
            case "play":
                handlePlayRequest(call.argument("query"), result);
                break;
            case "getQueue":
                handleGetQueueRequest(result);
                break;
            case "getCurrentTrack":
                result.success(convertAudioTrackToMap(playerManager.player().nowPlaying()));
                break;
            case "removeFromQueue":
                int index = call.argument("query");
                if (playerManager.player().nowPlaying().getQueuePosition() == index) {
                    playerManager.player().nextTrack();
                }
                playerManager.player().getQueue().remove(index);
                for (int i = index; i < playerManager.player().getQueue().size(); i++) {
                    playerManager.player().getQueue().get(i).setQueuePosition(playerManager.player().getQueue().get(i).getQueuePosition()-1);
                }
            case "npNext":
                playerManager.player().nextTrack();
                break;
            case "npPrevious":
                playerManager.player().previousTrack();
                break;
            case "pause":
                playerManager.player().pause();
                result.success(true);
                break;
            case "resume":
                playerManager.player().resume();
                result.success(true);
                break;
            case "getLyrics":
                executor.execute(() -> {
                    String lyrics = LRCLIBManager.getLyrics(playerManager.player().nowPlaying());
                    mainHandler.post(() -> result.success(lyrics));
                });
                break;
            case "seek":
                handleSeek(call.arguments, result);
                break;
            case "getPosition":
                result.success(playerManager.player().getPosition());
                break;
            default:
                result.notImplemented();
                break;
        }
    }


    private void handleSeek(Object position, MethodChannel.Result result) {
        try {
            if (position == null) {
                result.error("INVALID_SEEK", "Position cannot be null", null);
                return;
            }

            int seekPosition;
            if (position instanceof Double) {
                seekPosition = ((Double) position).intValue();
            } else if (position instanceof Integer) {
                seekPosition = (Integer) position;
            } else {
                result.error("INVALID_SEEK", "Position must be a number", null);
                return;
            }

            playerManager.player().seek(seekPosition);
            result.success(true);
        } catch (Exception e) {
            result.error("SEEK_ERROR", e.getMessage(), null);
        }
    }
    private void handleSearchRequest(String query, MethodChannel.Result result) {
        new Thread(() -> {
            try {
                List<AudioTrack> searchResults = youTubeExtractor.searchAudioTracks(query);
                runOnUiThread(() -> result.success(convertAudioTrackListToMap(searchResults)));
            } catch (Exception e) {
                runOnUiThread(() ->
                        result.error("SEARCH_ERROR", e.getMessage(), null));
            }
        }).start();
    }

    private void handlePlayRequest(String query, MethodChannel.Result result) {
        new Thread(() -> {
            try {
                AudioTrack track = youTubeExtractor.extractAudioTrack(query);
                runOnUiThread(() -> {
                    if (track != null) {
                        playerManager.player().queue(track);
                        result.success(track.getTitle());
                    } else {
                        result.error("NO_AUDIO", "No audio stream found", null);
                    }
                });
            } catch (Exception ignored) {}
        }).start();
    }

    private void handleGetQueueRequest(MethodChannel.Result result) {
        try {
            List<AudioTrack> queue = playerManager.player().getQueue();
            result.success(convertAudioTrackListToMap(queue));
        } catch (Exception e) {
            result.error("QUEUE_ERROR", e.getMessage(), null);
        }
    }

    private List<Map<String, Object>> convertAudioTrackListToMap(List<AudioTrack> tracks) {
        List<Map<String, Object>> result = new ArrayList<>();
        for (AudioTrack track : tracks) {
            result.add(convertAudioTrackToMap(track));
        }
        return result;
    }

    private Map<String, Object> convertAudioTrackToMap(AudioTrack track) {
        if (track == null) return null;

        Map<String, Object> map = new HashMap<>();
        map.put("artist", track.getArtist());
        map.put("title", track.getTitle());
        map.put("thumbnail", track.getThumbnail().toString());
        map.put("length", track.getLength());
        map.put("position", track.getPosition());
        map.put("streamUrl", track.getStreamUrl());
        return map;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (playerManager != null) {
            playerManager.release();
        }
    }
}