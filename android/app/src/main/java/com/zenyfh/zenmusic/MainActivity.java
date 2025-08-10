package com.zenyfh.zenmusic;

import android.os.Bundle;
import androidx.annotation.NonNull;
import com.yausername.youtubedl_android.YoutubeDL;
import com.yausername.youtubedl_android.YoutubeDLException;
import com.zenyfh.zenmusic.extractor.MediaExtractor;
import com.zenyfh.zenmusic.interop.DartJavaInterop;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;


public class MainActivity extends FlutterActivity {
    public static final MediaExtractor youTubeExtractor = new MediaExtractor();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        init();
    }

    private void init() {
        ExecutorService executor = Executors.newSingleThreadExecutor();
        executor.execute(() -> {
            try {
                YoutubeDL.getInstance().updateYoutubeDL(this, YoutubeDL.UpdateChannel._NIGHTLY);
            } catch (YoutubeDLException e) {
                throw new RuntimeException(e);
            }
        });
        try {
            YoutubeDL.getInstance().init(getApplication());
        } catch (YoutubeDLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "com.zenyfh.zenmusic/audio").setMethodCallHandler(DartJavaInterop::handleMethodCall);
    }
}