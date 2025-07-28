package com.zenyfh.zenmusic.player;

import android.content.Context;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import com.zenyfh.zenmusic.audio.AudioTrack;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

public class PlayerManager {
    private final BlockingQueue<AudioTrack> queue = new LinkedBlockingQueue<>();
    private ExoPlayer player;
    private TrackEventListener eventListener;

    public PlayerManager(Context context) {
        initializePlayer(context);
    }

    private void initializePlayer(Context context) {
        player = new ExoPlayer.Builder(context).build();
        player.addListener(new Player.Listener() {
            @Override
            public void onPlaybackStateChanged(int state) {
                if (state == Player.STATE_ENDED) {
                    playNextTrack();
                }
            }
        });
    }

    public void playTrack(AudioTrack track) {
        if (track == null) return;

        player.stop();
        player.clearMediaItems();
        player.setMediaItem(MediaItem.fromUri(track.getStreamUrl()));
        player.prepare();
        player.play();

        if (eventListener != null) {
            eventListener.onTrackStart(track);
        }
    }

    public void queueTrack(AudioTrack track) {
        if (track == null) return;
        queue.offer(track);

        if (!isPlaying()) {
            playNextTrack();
        }
    }

    public void playNextTrack() {
        if (isPlaying()) return;

        AudioTrack next = queue.poll();
        if (next != null) {
            playTrack(next);
        }
    }

    public boolean isPlaying() {
        return player != null &&
                player.getPlaybackState() == Player.STATE_READY &&
                player.isPlaying();
    }

    public List<AudioTrack> getQueue() {
        return new ArrayList<>(queue);
    }

    public void setTrackEventListener(TrackEventListener listener) {
        this.eventListener = listener;
    }

    public void release() {
        if (player != null) {
            player.release();
            player = null;
        }
    }

    public interface TrackEventListener {
        void onTrackStart(AudioTrack track);

        void onTrackEnd(AudioTrack track);
    }
}