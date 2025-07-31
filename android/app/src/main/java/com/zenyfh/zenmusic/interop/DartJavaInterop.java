package com.zenyfh.zenmusic.interop;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.util.HashMap;
import java.util.Map;

import static com.zenyfh.zenmusic.MainActivity.playerManager;
import static com.zenyfh.zenmusic.interop.Handlers.*;

public class DartJavaInterop {
    public static final String CHANNEL = "com.zenyfh.zenmusic/audio";
    public static final String EVENT_CHANNEL = "com.zenyfh.zenmusic/audio_events";


    /**
     * INFO: the comments here are to categorise what is happening in the method handler only, a function may take input or return internally.
     */
    static final Map<String, MethodHandler> methodHandlers = new HashMap<>() {{
        // functions that take input and give output
        put("search", (call, result) -> handleSearch(call.argument("query"), result));
        put("play", (call, result) -> handlePlay(call.argument("query"), result));

        // functions that take input
        put("removeFromQueue", (call, result) -> handleRemoveFromQueue(call.argument("query")));

        //functions that give output
        put("getQueue", (call, result) -> result.success(playerManager.player().getQueue()));
        put("getCurrentTrack", (call, result) -> result.success(playerManager.player().nowPlaying()));
        put("getPosition", (call, result) -> result.success(playerManager.player().getPosition()));

        // void functions
        put("npNext", ((call, result) -> playerManager.player().nextTrack()));
        put("npPrevious", ((call, result) -> playerManager.player().previousTrack()));
        put("pause", (call, result) -> playerManager.player().pause());
        put("resume", (call, result) -> playerManager.player().resume());
        put("seek", (call, result) -> handleSeek(call.arguments, result));
        put("getLyrics", ((call, result) -> handleGetLyrics(result)));
    }};

    public static void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        AutoConvertingResult wrappedResult = new AutoConvertingResult(result);
        MethodHandler handler = methodHandlers.get(call.method);
        if (handler != null) {
            handler.handle(call, wrappedResult);
        } else {
            wrappedResult.notImplemented();
        }
    }

    @FunctionalInterface
    interface MethodHandler {
        void handle(MethodCall call, MethodChannel.Result result);
    }
}
