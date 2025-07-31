package com.zenyfh.zenmusic.interop;

import com.zenyfh.zenmusic.audio.AudioTrack;
import io.flutter.plugin.common.MethodChannel;
import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class AutoConvertingResult implements MethodChannel.Result {
    private final MethodChannel.Result originalResult;

    public AutoConvertingResult(MethodChannel.Result originalResult) {
        this.originalResult = originalResult;
    }

    @Override
    public void success(Object result) {
        if (result instanceof AudioTrack) {
            originalResult.success(((AudioTrack) result).getMapObject());
        } else if (result instanceof List) {
            originalResult.success(convertTrackList((List<?>) result));
        } else {
            originalResult.success(result);
        }
    }

    private List<Map<String, Object>> convertTrackList(List<?> list) {
        List<Map<String, Object>> converted = new ArrayList<>();
        for (Object item : list) {
            if (item instanceof AudioTrack) {
                converted.add(((AudioTrack) item).getMapObject());
            }
        }
        return converted;
    }

    @Override
    public void error(@NotNull String errorCode, String errorMessage, Object errorDetails) {
        originalResult.error(errorCode, errorMessage, errorDetails);
    }

    @Override
    public void notImplemented() {
        originalResult.notImplemented();
    }
}
