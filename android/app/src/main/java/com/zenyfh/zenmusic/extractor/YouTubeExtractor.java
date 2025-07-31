package com.zenyfh.zenmusic.extractor;

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

public class YouTubeExtractor {
    public List<AudioTrack> searchAudioTracks(String query) throws Exception {
        final int SEARCHLIMIT = 25;
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
                Log.i("Entry:", entry.toString());
                String artist = entry.getString("uploader");
                String title = entry.getString("title");
                int length = (int) Math.floor(entry.getDouble("duration"));
                String streamUrl = entry.getString("url").split(" ")[0];

                // get first thumbnail URL or use fallback
                String thumbnail = getMostSquareThumbnailUrl(entry);

                tracks.add(new AudioTrack(
                        artist,
                        title,
                        thumbnail,
                        length,
                        0, // initial pos
                        0,
                        streamUrl,
                        (length > 0 && length < 172800) // if you're playing a song that is 2 days long, what are you doing.
                ));
            } catch (Exception e) {
                // skip invalid
                e.printStackTrace();
            }
        }
        return tracks;
    }

    private String getMostSquareThumbnailUrl(JSONObject entry) {
        try {
            JSONArray thumbnails = entry.getJSONArray("thumbnails");
            if (thumbnails.length() > 0) {
                JSONObject best = null;
                double bestRatioDiff = Double.MAX_VALUE;
                for (int i = 0; i < thumbnails.length(); i++) {
                    JSONObject thumb = thumbnails.getJSONObject(i);
                    if (!thumb.has("width") || !thumb.has("height")) continue;
                    int width = thumb.getInt("width");
                    int height = thumb.getInt("height");
                    double ratioDiff = Math.abs((double) width / height - 1);
                    if (ratioDiff < bestRatioDiff) {
                        best = thumb;
                        bestRatioDiff = ratioDiff;
                    }
                }
                if (best != null && best.has("url")) {
                    return best.getString("url");
                }
            }
        } catch (JSONException ignored) {
        }
        return ""; // fallback
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
                json.optString("thumbnail", ""),
                json.optInt("duration", 0),
                0,
                0,
                json.optString("url", ""),
                false
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