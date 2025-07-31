package com.zenyfh.zenmusic;

import android.os.Bundle;
import androidx.annotation.NonNull;
import com.yausername.youtubedl_android.YoutubeDL;
import com.yausername.youtubedl_android.YoutubeDLException;
import com.zenyfh.zenmusic.audio.AudioEventHandler;
import com.zenyfh.zenmusic.audio.AudioTrack;
import com.zenyfh.zenmusic.extractor.YouTubeExtractor;
import com.zenyfh.zenmusic.interop.DartJavaInterop;
import com.zenyfh.zenmusic.player.PlayerManager;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static com.zenyfh.zenmusic.audio.AudioEventHandler.setTrackEventListener;
import static com.zenyfh.zenmusic.interop.DartJavaInterop.EVENT_CHANNEL;

public class MainActivity extends FlutterActivity {
    public static final YouTubeExtractor youTubeExtractor = new YouTubeExtractor();
    public static PlayerManager playerManager;
    private final ExecutorService executor = Executors.newSingleThreadExecutor();
    private EventChannel.EventSink eventSink;

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
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "com.zenyfh.zenmusic/audio").setMethodCallHandler(DartJavaInterop::handleMethodCall);
        // event channel
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL).setStreamHandler(new EventChannel.StreamHandler() {
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

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (playerManager != null) {
            playerManager.release();
        }
    }
}