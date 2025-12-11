extends Node

# Autoload: AudioManager
# Manages sound effects and music.
# Since we don't have actual audio files yet, we'll setup the players and methods.

# Sound Event Enums
enum Sound {
	CLICK,
	HOVER,
	CARD_DRAW,
	CARD_PLACE,
	CARD_DISCARD,
	SYNERGY_FORMED,
	LEVEL_COMPLETE,
	GAME_OVER,
	CHAOS_WARNING
}

# Music Tracks
enum Music {
	MENU,
	CHAPTER_THEME,
	BOSS_THEME
}

var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _current_music: Music = -1

# Placeholder resources - In a real project, drag & drop your .wav files here in the Inspector
# or load them via code if you have them.
var sfx_streams: Dictionary = {}
var music_streams: Dictionary = {}

const MAX_SFX_CHANNELS = 8

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Create music player
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)
	
	# Create SFX pool
	for i in range(MAX_SFX_CHANNELS):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)
	
	# Setup default buses if they don't exist (handled by Godot project settings usually, 
	# but good to verify if we were doing runtime bus setup)

func play_sfx(sound_type: Sound, pitch_scale: float = 1.0) -> void:
	if not sfx_streams.has(sound_type):
		# print("AudioManager: No stream assigned for SFX ", Sound.keys()[sound_type])
		return
		
	var stream = sfx_streams[sound_type]
	var player = _get_available_sfx_player()
	
	if player:
		player.stream = stream
		player.pitch_scale = pitch_scale
		player.play()

func play_music(music_type: Music, fade_duration: float = 1.0) -> void:
	if _current_music == music_type and _music_player.playing:
		return
		
	if not music_streams.has(music_type):
		# print("AudioManager: No stream assigned for Music ", Music.keys()[music_type])
		return
		
	var new_stream = music_streams[music_type]
	
	if _music_player.playing:
		# Simple fade out/in logic could go here using Tweens
		var tween = create_tween()
		tween.tween_property(_music_player, "volume_db", -80.0, fade_duration / 2.0)
		await tween.finished
		_music_player.stop()
		_music_player.stream = new_stream
		_music_player.volume_db = 0.0 # Reset volume
		_music_player.play()
		# Fade in?
	else:
		_music_player.stream = new_stream
		_music_player.play()
		
	_current_music = music_type

func stop_music(fade_duration: float = 1.0) -> void:
	if _music_player.playing:
		var tween = create_tween()
		tween.tween_property(_music_player, "volume_db", -80.0, fade_duration)
		await tween.finished
		_music_player.stop()
		_music_player.volume_db = 0.0

func _get_available_sfx_player() -> AudioStreamPlayer:
	for p in _sfx_players:
		if not p.playing:
			return p
	
	# If all busy, use the oldest one (first in list is usually fine to interrupt, 
	# or we could implement a round-robin index)
	return _sfx_players[0]

# --- Helper for assigning resources (can be called from a manager or resource loader) ---
func register_sfx(sound_type: Sound, stream: AudioStream) -> void:
	sfx_streams[sound_type] = stream

func register_music(music_type: Music, stream: AudioStream) -> void:
	music_streams[music_type] = stream

