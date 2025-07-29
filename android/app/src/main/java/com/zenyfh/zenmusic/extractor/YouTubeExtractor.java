package com.zenyfh.zenmusic.extractor;

import android.net.Uri;
import com.yausername.youtubedl_android.YoutubeDL;
import com.yausername.youtubedl_android.YoutubeDLRequest;
import com.yausername.youtubedl_android.YoutubeDLResponse;
import com.zenyfh.zenmusic.audio.AudioTrack;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class YouTubeExtractor {
    public List<AudioTrack> searchAudioTracks(String query) throws Exception {
        final int SEARCHLIMIT = 50;
        if (!query.startsWith("http")) {
            query = String.format("ytsearch%s:%s", SEARCHLIMIT, query);
        }

        YoutubeDLRequest request = new YoutubeDLRequest(query);
        request.addOption("-q");
        request.addOption("--no-warnings");
        request.addOption("--flat-playlist");
        request.addOption("--skip-download");
        request.addOption("-J");

        YoutubeDLResponse response = YoutubeDL.getInstance().execute(request);
        JSONObject jsonObject = new JSONObject(response.getOut());
        return parseJsonToAudioTracks(jsonObject);
    }
    private List<AudioTrack> parseJsonToAudioTracks(JSONObject jsonObject) throws JSONException {
        List<AudioTrack> tracks = new ArrayList<>();
        JSONArray entries = jsonObject.getJSONArray("entries");

        for (int i = 0; i < entries.length(); i++) {
            try {
                JSONObject entry = entries.getJSONObject(i);
                String artist = entry.getString("uploader");
                String title = entry.getString("title");
                int length = (int) Math.round(entry.getDouble("duration"));
                String streamUrl = entry.getString("url");

                // get first thumbnail URL or use fallback
                Uri thumbnail = Uri.parse(getFirstThumbnailUrl(entry));

                tracks.add(new AudioTrack(
                        artist,
                        title,
                        thumbnail,
                        length,
                        0, // initial pos
                        streamUrl
                ));
            } catch (Exception e) {
                // skip invalid
                e.printStackTrace();
            }
        }
        return tracks;
    }

    private String getFirstThumbnailUrl(JSONObject entry) {
        try {
            JSONArray thumbnails = entry.getJSONArray("thumbnails");
            if (thumbnails.length() > 0) {
                return thumbnails.getJSONObject(0).getString("url");
            }
        } catch (JSONException ignored) {}
        return ""; // empty url fallback
    }
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