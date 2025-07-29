package com.zenyfh.zenmusic.player;

import android.content.Context;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import com.zenyfh.zenmusic.audio.AudioTrack;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class PlayerManager {
    private final LinkedList<AudioTrack> queue = new LinkedList<>();
    private ExoPlayer player;
    private TrackEventListener eventListener;
    private AudioTrack currentTrack;
    private int queuePosition = 0;
    private long startTime;
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
        queue.add(track);

        if (!isPlaying()) {
            playNextTrack();
        }
    }

    public void playNextTrack() {
        if (isPlaying()) return;
        playNextTrackForcefully();
    }

    public void playNextTrackForcefully() {
        if (queuePosition <= queue.size()) {
            AudioTrack next = queue.get(queuePosition);
            if (next != null) {
                currentTrack = next;
                playTrack(next);
                queuePosition++;
            }
        }
    }

    public void playPreviousTrackForcefully() {
        // TODO: see issues #1 and #2, for now duplicate playnextforce functionality.
        AudioTrack next = queue.poll();
        if (next != null) {
            currentTrack = next;
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

    public AudioTrack getCurrentTrack() {
        return currentTrack;
    }

    public void pause() {
        player.pause();
    }

    public void resume() {
        player.play();
    }

    public void seek(int time) {
        player.seekTo(time* 1000L);
    }

    public int getPosition() {
        return (int) (player.getContentPosition()/1000);
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