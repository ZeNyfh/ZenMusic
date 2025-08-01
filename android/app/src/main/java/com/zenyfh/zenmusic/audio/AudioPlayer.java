package com.zenyfh.zenmusic.audio;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.ExoPlayer.Builder;

import java.util.LinkedList;

import static com.zenyfh.zenmusic.audio.AudioEventHandler.getTrackEventListener;

public class AudioPlayer {
    private final ExoPlayer exoPlayer;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private final LinkedList<AudioTrack> queue = new LinkedList<>();
    private AudioTrack currentAudioTrack;
    private int queuePosition;

    public AudioPlayer(Context context) {
        this.exoPlayer = new Builder(context).build();
    }

    public ExoPlayer getExoPlayer() {
        return exoPlayer;
    }

    public boolean isPlaying() {
        return exoPlayer.getPlaybackState() == Player.STATE_READY && exoPlayer.isPlaying();
    }

    public int getPosition() {
        return (int) (exoPlayer.getContentPosition() / 1000);
    }

    public void seek(long positionSeconds) {
        mainHandler.post(() -> {
            exoPlayer.seekTo(positionSeconds * 1000);
        });
    }

    public long getDuration() {
        return exoPlayer.getDuration() / 1000;
    }

    public void resume() {
        exoPlayer.play();
    }

    public void pause() {
        exoPlayer.pause();
    }

    public int getQueuePosition() {
        return this.queuePosition;
    }

    public void previousTrack() {
        decrementQueuePosition();
        changeTrack();
    }

    public void nextTrack() {
        incrementQueuePosition();
        changeTrack();
    }

    private void changeTrack() {
        mainHandler.post(() -> {
            exoPlayer.stop();
            exoPlayer.clearMediaItems();
            exoPlayer.setMediaItem(MediaItem.fromUri(nowPlaying().getStreamUrl()));
            exoPlayer.prepare();
            exoPlayer.play();
            setNowPlaying(getQueue().get(queuePosition));
            getTrackEventListener().onTrackStart(currentAudioTrack);
        });
    }

    private void incrementQueuePosition() {
        this.queuePosition++;
        if (this.queuePosition >= this.queue.size()) {
            this.queuePosition = 0;
        }
        if (this.queue.isEmpty()) {
            return;
        }
        setNowPlaying(this.queue.get(this.queuePosition));
    }

    private void decrementQueuePosition() {
        this.queuePosition--;
        if (this.queuePosition < 0) {
            this.queuePosition = this.queue.size() - 1;
        }
        if (this.queue.isEmpty()) {
            return;
        }
        setNowPlaying(this.queue.get(this.queuePosition));
    }

    public void queue(AudioTrack track) {
        if (track == null) throw new NullPointerException("track is null");

        mainHandler.post(() -> {
            boolean wasEmpty = queue.isEmpty();
            queue.add(track);
            track.setQueuePosition(queue.size());

            if (wasEmpty) {
                this.queuePosition = 0;
                setNowPlaying(track);
                changeTrack();
            }
        });
    }

    public LinkedList<AudioTrack> getQueue() {
        return this.queue;
    }

    public void setNowPlaying(AudioTrack currentAudioTrack) {
        this.currentAudioTrack = currentAudioTrack;
    }

    public AudioTrack nowPlaying() {
        return this.currentAudioTrack;
    }

    public void release() {
        exoPlayer.release();
    }
}
