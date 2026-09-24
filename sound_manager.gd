extends Node

# --- SOUND PLAYERS ---
var sfx_player: AudioStreamPlayer
var ui_player: AudioStreamPlayer
var music_player: AudioStreamPlayer

# --- SOUND LIBRARY ---
var sounds := {}

func _ready():
	# Create players
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)

	ui_player = AudioStreamPlayer.new()
	add_child(ui_player)
	
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	# Load sounds (assign your files here)
	sounds = {
		"player_death": preload("res://SFX/deathsound.wav"),
		"enemy_death": preload("res://SFX/shoot.wav"),
		"boss_death": preload("res://SFX/shootBoss.wav"),
		#"shoot": preload("res://sounds/shoot.wav"),
		"menu_move": preload("res://SFX/select.wav"),
		
		# --- MUSIC ---
	"stage1": preload("res://OST/stage1music.wav"),
	"boss": preload("res://OST/boss1.wav"),
	"menu": preload("res://OST/start_screen.wav")
	}

func play_sfx(name: String):
	if not sounds.has(name):
		print("Sound not found:", name)
		return

	var player = AudioStreamPlayer.new()
	player.stream = sounds[name]
	add_child(player)
	player.play()

	player.finished.connect(func():
		player.queue_free()
	)


func play_ui(name: String):
	if not sounds.has(name):
		print("UI sound not found:", name)
		return

	ui_player.stream = sounds[name]
	ui_player.play()

func play_music(name: String, loop: bool = true):
	if not sounds.has(name):
		print("Music not found:", name)
		return

	if music_player.stream == sounds[name]:
		return # already playing

	music_player.stream = sounds[name]
	music_player.play()

	
func stop_music():
	music_player.stop()
