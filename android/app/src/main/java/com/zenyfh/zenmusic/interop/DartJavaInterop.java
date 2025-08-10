package com.zenyfh.zenmusic.interop;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.util.HashMap;
import java.util.Map;

import static com.zenyfh.zenmusic.interop.Handlers.*;

public class DartJavaInterop {
    static final Map<String, MethodHandler> methodHandlers = new HashMap<>() {{
        put("search", (call, result) -> handleSearch(call.argument("query"), result));
        put("extractAudioTrack", (call, result) -> handleExtractAudioTrack(call.argument("videoId"), result));
        put("getLyrics", ((call, result) -> handleGetLyrics(call.argument("query"), result)));
    }};

    // dart runs this.
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
