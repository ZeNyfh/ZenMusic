package com.zenyfh.zenmusic.extractor;

import android.annotation.SuppressLint;
import com.zenyfh.zenmusic.audio.AudioTrack;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class LRCLIBManager {
    private static final String[] titleFilters = {
            // yt
            "Official Video", "Music Video", "Lyric Video", "Visualizer", "Audio", "Official Audio", "Album Audio",
            "Live", "Live Performance", "HD", "HQ", "4K", "360°", "VR",
            // spotify
            "Official Spotify", "Spotify Singles", "Spotify Session", "Recorded at Spotify Studios",
            "Spotify Exclusive", "Podcast", "Episode", "B-Side", "Session",
            // flags
            "Explicit", "Clean", "Unedited", "Remastered", "Remaster", "Deluxe", "Extended", "Bonus Track", "Cover",
            "Acoustic", "Instrumental", "Radio Edit", "Reissue", "Anniversary Edition",
            // tags
            "VEVO", "YouTube", "YT", "Streaming", "Stream",
            // decorators
            "With Lyrics", "Lyrics", "ft.", "feat.", "featuring", "vs.", "x", "Official", "Original", "Version",
            "Edit", "Mix", "Mashup",
            // release
            "Album Version", "Single Version", "EP Version",
            // misc
            "||", "▶", "❌", "●", "...", "---", "•••", "FREE DOWNLOAD", "OUT NOW", "NEW"
    };
    private static final String[] rawTitleFilters = {
            // yt
            "OFFICIAL LYRIC VIDEO", "Music Video", "Lyric Video", "Official Audio", "Album Audio", "Live Performance",
            "HD", "HQ", "4K", "360°", "VR",
            // spotify
            "Official Spotify", "Spotify Singles", "Spotify Session", "Recorded at Spotify Studios",
            "Spotify Exclusive",
            // flags
            "Explicit", "Unedited", "Remastered", "Remaster", "Extended", "Bonus Track", "Acoustic", "Instrumental",
            "Radio Edit", "Reissue", "Anniversary Edition",
            // tags
            "VEVO", "YouTube", "YT", "Streaming", "Stream",
            // decorators
            "With Lyrics", "Lyrics", "ft.", "feat.", "featuring", "vs.", "x", "Official", "Original", "Version",
            "Edit", "Mix", "Mashup",
            // release
            "Album Version", "Single Version", "EP Version",
            // misc
            "||", "▶", "❌", "●", "...", "---", "•••", "FREE DOWNLOAD", "OUT NOW", "NEW"
    };
    private static final Map<String, String> equivalentChars = new HashMap<>() {{
        put("—", "-");
        put("–", "-");
        put("‐", "-");
        put("⁃", "-");
        put("⸺", "-");
        put("…", "...");
        put("･", ".");
        put("•", ".");
        put("․", ".");
        put("⋅", ".");
        put("∙", ".");
    }};

    public static String getLyrics(AudioTrack track) {
        if (Objects.equals(track.getTitle(), "") || track.getTitle().equalsIgnoreCase("unknown title")) {
            return "Could not get lyrics.";
        }
        String url = createURL(track);
        if (url.isEmpty()) {
            return "Could not get lyrics.";
        }

        try {
            URL requestURL = URI.create(url).toURL();
            HttpURLConnection connection = (HttpURLConnection) requestURL.openConnection();
            connection.setRequestMethod("GET");

            StringBuilder responseBuilder = new StringBuilder();
            BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null) {
                responseBuilder.append(line);
            }
            String response = responseBuilder.toString();
            if (response.equals("[]")) {
                return "Could not get lyrics.";
            }

            String lyrics = parseLyrics(response);
            if (lyrics == null || lyrics.equalsIgnoreCase("null")) {
                return "Could not get lyrics.";
            }
            return lyrics;
        } catch (Exception e) {
            e.printStackTrace();
            return "Could not get lyrics.";
        }
    }

    @SuppressLint("NewApi") // added in api 1, deprecated in api 15, undeprecated in api 33
    private static String createURL(AudioTrack track) {
        StringBuilder urlBuilder = new StringBuilder();
        urlBuilder.append("https://lrclib.net/api/search?q=");

        String title = track.getTitle();
        if (track.isStream()) {
            title = RadioDataFetcher.getStreamSongNow(track.getStreamUrl())[0];
        }

        title = filterMetadata(title);

        String artist = track.getArtist();
        if (track.isStream()) {
            artist = "";
        }
        urlBuilder.append(URLEncoder.encode(artist + " " + title, StandardCharsets.UTF_8).trim());
        return urlBuilder.toString();
    }

    private static String parseLyrics(String rawJson) throws JSONException {
        JSONArray parsedJson;
        try {
            parsedJson = new JSONArray(rawJson);
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }

        JSONObject trackDetailsBrowser = null;
        try {

            trackDetailsBrowser = parsedJson.getJSONObject(1);
        } catch (Exception ignored) {
            System.err.println("No lyrics were found for this track.");
        }
        if (trackDetailsBrowser == null) {
            return "";
        }
        return trackDetailsBrowser.get("plainLyrics").toString();
    }

    public static String filterMetadata(String track) {
        Pattern bracketContent = Pattern.compile("(?i)[(\\[{<«【《『„](.*)[)\\]}>»】》』“]");
        Matcher matcher = bracketContent.matcher(track);

        for (Map.Entry<String, String> entry : equivalentChars.entrySet()) {
            track = track.replace(entry.getKey(), entry.getValue());
        }

        if (matcher.find()) {
            String bracketContentString = matcher.group(1).toLowerCase();
            for (String filter : titleFilters) {
                if (bracketContentString.contains(filter.toLowerCase())) {
                    track = matcher.replaceAll("");
                }
            }
        }

        for (String filter : rawTitleFilters) {
            if (track.toLowerCase().contains(filter.toLowerCase())) {
                track = track.replace(filter, "");
            }
        }

        return track.trim();
    }
}