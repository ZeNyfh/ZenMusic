package com.zenyfh.zenmusic.player;

import android.content.Context;
import androidx.media3.common.Player;
import com.zenyfh.zenmusic.audio.AudioPlayer;


public class PlayerManager {
    private AudioPlayer audioPlayer;
    public PlayerManager(Context context) {
        initializePlayer(context);
    }

    public AudioPlayer player() {
        return audioPlayer;
    }

    private void initializePlayer(Context context) {
        audioPlayer = new AudioPlayer(context);
        audioPlayer.getExoPlayer().addListener(new Player.Listener() {
            @Override
            public void onPlaybackStateChanged(int state) {
                if (state == Player.STATE_ENDED) {
                    player().nextTrack();
                }
            }
        });
    }

    public void release() {
        if (audioPlayer != null) {
            audioPlayer.release();
            audioPlayer = null;
        }
    }
}