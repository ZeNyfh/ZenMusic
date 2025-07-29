package com.zenyfh.zenmusic.extractor;

import android.net.Uri;
import android.util.Log;
import com.yausername.youtubedl_android.YoutubeDL;
import com.yausername.youtubedl_android.YoutubeDLRequest;
import com.yausername.youtubedl_android.YoutubeDLResponse;
import com.zenyfh.zenmusic.audio.AudioTrack;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

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
        Log.i("THESE ARE THE ENTRIES: ", entries.toString());

        for (int i = 0; i < entries.length(); i++) {
            try {
                JSONObject entry = entries.getJSONObject(i);
                String artist = entry.getString("uploader");
                String title = entry.getString("title");
                int length = (int) Math.round(entry.getDouble("duration"));
                String streamUrl = entry.getString("url").split(" ")[0];

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
        return ""; // empty url fallbacj
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

        // mp4 with aac > mp4 with mp3 > other mp4 > other
        String mp4AacUrl = null;
        String mp4Mp3Url = null;
        String mp4Url = null;
        String fallbackUrl = null;

        for (int i = 0; i < formats.length(); i++) {
            JSONObject format = formats.optJSONObject(i);
            if (format == null) continue;

            String url = format.optString("url", "none");

            String acodec = format.optString("acodec", "none");
            String container = format.optString("ext", "");
            String vcodec = format.optString("vcodec", "none");

            if ("none".equals(acodec)) continue; // video only
            if (!"none".equals(vcodec)) continue; // only want audio

            boolean isMp4 = "mp4".equalsIgnoreCase(container);
            if (isMp4) {
                if (acodec.startsWith("mp4a") || acodec.contains("aac")) {
                    mp4AacUrl = url; // mp4 aac
                } else if (acodec.startsWith("mp3")) {
                    mp4Mp3Url = url; // mp4 mp3
                } else {
                    mp4Url = url; // mp4 other
                }
            } else {
                fallbackUrl = url; // not mp4
            }
        }
        // in order of preference
        if (mp4AacUrl != null) return mp4AacUrl;
        if (mp4Mp3Url != null) return mp4Mp3Url;
        if (mp4Url != null) return mp4Url;
        return fallbackUrl;
    }
}