package com.zenyfh.zenmusic.lavaplayer;

import com.sedmelluq.discord.lavaplayer.player.AudioPlayer;
import com.sedmelluq.discord.lavaplayer.player.AudioPlayerManager;
import com.sedmelluq.discord.lavaplayer.player.DefaultAudioPlayerManager;
import dev.lavalink.youtube.YoutubeAudioSourceManager;

public class PlayerManager {
	private static AudioPlayerManager audioPlayerManager;
	private static YoutubeAudioSourceManager youtubeAudioSourceManager;

	public static void init() {
		AudioPlayerManager audioPlayerManager = new DefaultAudioPlayerManager();
		YoutubeAudioSourceManager youtubeAudioSourceManager = new YoutubeAudioSourceManager();

		audioPlayerManager.registerSourceManager(youtubeAudioSourceManager);
	}

	public static AudioPlayerManager getAudioPlayerManager() {
		return audioPlayerManager;
	}
}
