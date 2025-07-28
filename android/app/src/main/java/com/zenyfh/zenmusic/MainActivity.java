package com.zenyfh.zenmusic;

import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;

import com.yausername.youtubedl_android.YoutubeDL;
import com.yausername.youtubedl_android.YoutubeDLRequest;
import com.yausername.youtubedl_android.YoutubeDLException;
import com.yausername.youtubedl_android.YoutubeDLResponse;

import com.zenyfh.zenmusic.audio.AudioTrack;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.zenyfh.zenmusic/audio";
    private ExoPlayer player;
    public static BlockingQueue<AudioTrack> queue = new LinkedBlockingQueue<>();

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        try {
            YoutubeDL.getInstance().init(getApplication());
        } catch (YoutubeDLException e) {
            e.printStackTrace();
        }

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(this::handleMethodCall);
    }

    private void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "play":
                String query = call.argument("query");
                playAudio(query, result);
                break;
            case "getQueue":
                getQueue(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void getQueue(MethodChannel.Result result) {
        try {
            List<Map<String, Object>> trackList = new ArrayList<>();
            for (AudioTrack track : queue) {
                Map<String, Object> trackMap = new HashMap<>();
                trackMap.put("artist", track.getArtist());
                trackMap.put("title", track.getTitle());
                trackMap.put("thumbnail", track.getThumbnail().toString());
                trackMap.put("length", track.getLength());
                trackMap.put("position", track.getPosition());
                trackMap.put("streamUrl", track.getStreamUrl());
                trackList.add(trackMap);
            }
            result.success(trackList);
        } catch (Exception e) {
            result.error("UNAVAILABLE", "Queue data not available.", null);
        }
    }

    private void playAudio(String url, MethodChannel.Result result) {
        new Thread(() -> {
            try {
                AudioTrack track = extractAudioTrack(url);

                if (track == null || track.getStreamUrl() == null) {
                    runOnUiThread(() -> result.error("NO_AUDIO", "No audio stream found", null));
                    return;
                }

                runOnUiThread(() -> {
                    queue(track); // ✅ Use queue() instead of playTrack()
                    result.success(track.getTitle());
                });

            } catch (Exception e) {
                runOnUiThread(() -> result.error("YT_PLAY_ERROR", e.getMessage(), null));
            }
        }).start();
    }


    private AudioTrack extractAudioTrack(String url) throws Exception {
        if (!(url.startsWith("http://") || url.startsWith("https://"))) {
            url = "ytsearch:" + url;
        }

        YoutubeDLRequest request = new YoutubeDLRequest(url);
        request.addOption("--no-playlist");
        request.addOption("-f", "bestaudio");
        request.addOption("-j");

        YoutubeDLResponse response = YoutubeDL.getInstance().execute(request);
        String output = response.getOut();
        JSONObject json = new JSONObject(output);

        String audioUrl = getAudioStreamUrl(json);
        if (audioUrl == null) return null;

        String title = json.optString("title", "Unknown Title");
        String uploader = json.optString("uploader", "Unknown Artist");
        String thumbnailUrl = json.optString("thumbnail", "");
        Uri thumbnail = Uri.parse(thumbnailUrl);
        int duration = json.optInt("duration", 0);

        return new AudioTrack(uploader, title, thumbnail, duration, 0, audioUrl);
    }

    private String getAudioStreamUrl(JSONObject json) {
        JSONArray formats = json.optJSONArray("formats");
        if (formats == null) return null;

        for (int i = 0; i < formats.length(); i++) {
            JSONObject fmt = formats.optJSONObject(i);
            if (fmt == null) continue;

            String acodec = fmt.optString("acodec", "none");
            if (!"none".equals(acodec)) {
                return fmt.optString("url", null);
            }
        }
        return null;
    }

    private boolean playTrack(AudioTrack track) {
        if (track == null) return false;

        if (player != null) player.release();

        player = new ExoPlayer.Builder(this).build();

        MediaItem mediaItem = MediaItem.fromUri(track.getStreamUrl());
        player.setMediaItem(mediaItem);

        player.addListener(new Player.Listener() {
            @Override
            public void onPlaybackStateChanged(int state) {
                if (state == Player.STATE_READY) {
                    onTrackStart(track);
                } else if (state == Player.STATE_ENDED) {
                    onTrackEnd(track);
                    nextTrack(); // auto-play next
                }
            }
        });

        player.prepare();
        player.play();

        return true;
    }

    public void queue(AudioTrack track) {
        queue.offer(track);

        if (!isPlaying()) {
            nextTrack();
        }
    }

    public void nextTrack() {
        if (isPlaying()) return; // already playing something

        AudioTrack next = queue.poll();
        if (next != null) {
            playTrack(next);
        }
    }

    public boolean isPlaying() {
        return player != null && player.getPlaybackState() == Player.STATE_READY && player.isPlaying();
    }

    protected void onTrackStart(AudioTrack track) {
        System.out.println("Track started: " + track.getTitle());
    }

    protected void onTrackEnd(AudioTrack track) {
        System.out.println("Track ended: " + track.getTitle());
        nextTrack();
    }


}
