package com.zenyfh.zenmusic.extractor;

import android.net.Uri;
import com.yausername.youtubedl_android.YoutubeDL;
import com.yausername.youtubedl_android.YoutubeDLRequest;
import com.yausername.youtubedl_android.YoutubeDLResponse;
import com.zenyfh.zenmusic.audio.AudioTrack;
import org.json.JSONArray;
import org.json.JSONObject;

public class YouTubeExtractor {
    public AudioTrack extractAudioTrack(String url) throws Exception {
        if (!url.startsWith("http")) {
            url = "ytsearch:" + url;
        }

        YoutubeDLRequest request = new YoutubeDLRequest(url);
        request.addOption("--no-playlist");
        request.addOption("-f", "bestaudio");
        request.addOption("-j");

        YoutubeDLResponse response = YoutubeDL.getInstance().execute(request);
        JSONObject json = new JSONObject(response.getOut());

        String audioUrl = findBestAudioStream(json);
        if (audioUrl == null) return null;

        return new AudioTrack(
                json.optString("uploader", "Unknown Artist"),
                json.optString("title", "Unknown Title"),
                Uri.parse(json.optString("thumbnail", "")),
                json.optInt("duration", 0),
                0,
                audioUrl
        );
    }

    private String findBestAudioStream(JSONObject json) {
        JSONArray formats = json.optJSONArray("formats");
        if (formats == null) return null;

        for (int i = 0; i < formats.length(); i++) {
            JSONObject format = formats.optJSONObject(i);
            if (format == null) continue;

            if (!"none".equals(format.optString("acodec", "none"))) {
                return format.optString("url", null);
            }
        }
        return null;
    }
}