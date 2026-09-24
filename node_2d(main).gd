# main.gd
extends Control   # or Node2D, whatever your root is

@onready var subviewport_container: SubViewportContainer = $SubViewportContainer
@onready var subviewport: SubViewport = $SubViewportContainer/SubViewport
@onready var stage: Node2D = $SubViewportContainer/SubViewport/Stage1
@onready var player: CharacterBody2D = $SubViewportContainer/SubViewport/Player
@onready var hearts_ui = $"CanvasLayer/HeartsUI"
@onready var bombs_ui = $"CanvasLayer/BombsUI"
@onready var score_label := $"CanvasLayer/ScoreLabel"
@onready var bgm_notifier = $"CanvasLayer/BGM"

@export var game_over_scene: PackedScene
@export var pause_menu_scene: PackedScene
var pause_menu_instance
var paused := false
var game_over_instance

func _ready() -> void:
	var field_size: Vector2i = stage.playfield_size
	stage.player = player
	player.score_changed.connect(_on_score_changed)
	player.health_changed.connect(hearts_ui.set_hearts)
	player.bombs_changed.connect(bombs_ui.set_bombs)
	bombs_ui.set_bombs(player.bombs)
	player.died.connect(_on_player_died)
	player.bomb_used.connect(_on_bomb_used)
	eventBus.enemy_died.connect(_on_enemy_died)
	
	bgm_notifier.show_bgm("Stage 1 Theme!")
	
	$CanvasLayer/PlayerSpellUI/BombPortrait.connect_player(player)
	$CanvasLayer/PlayerSpellUI/BombName.connect_player(player)
	#Resize SubViewport to match the stage resolution
	#subviewport.size = stage.playfield_size

	# Center SubViewportContainer in the UI
	#center_playfield(field_size)

	# IMPORTANT: pass the playfield size (local SubViewport coords) to player
	# This expects `player` to be a child of the SubViewport (so player's local position is inside 0..field_size)
	#player.set_playfield_size(Vector2(field_size))
	
	

func _input(event):
	if event.is_action_pressed("ui_cancel"): # ESC by default
		toggle_pause()
		
func toggle_pause():
	if paused:
		unpause_game()
	else:
		pause_game()

func pause_game():
	if pause_menu_instance:
		return

	paused = true
	get_tree().paused = true
	GameState.phase = GameState.Phase.PAUSED

	pause_menu_instance = pause_menu_scene.instantiate()
	add_child(pause_menu_instance)

	pause_menu_instance.resume_pressed.connect(unpause_game)
	pause_menu_instance.retry_pressed.connect(_on_retry_pressed)
	pause_menu_instance.quit_pressed.connect(_on_quit_pressed)

func unpause_game():
	paused = false
	get_tree().paused = false
	GameState.phase = GameState.Phase.GAMEPLAY

	if pause_menu_instance:
		pause_menu_instance.queue_free()
		pause_menu_instance = null

#func center_playfield(field_size: Vector2i) -> void:
	#var ui_size := get_viewport_rect().size
	#subviewport_container.position = (ui_size - Vector2(field_size)) / 2

func _on_player_died():
	stage.shutdown()
	show_game_over()
	
func show_game_over():
	if game_over_instance:
		return

	game_over_instance = game_over_scene.instantiate()
	add_child(game_over_instance)
	game_over_instance.retry_pressed.connect(_on_retry_pressed)
	game_over_instance.quit_pressed.connect(_on_quit_pressed)

func _on_retry_pressed():
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()

func _on_bomb_used():
	stage.start_bomb_background(3.0)
	stage.clear_screen_for_bomb()

func _on_score_changed(new_score):
	score_label.text = "SCORE: %08d" % new_score
	
func _on_enemy_died(score_value):
	print("Enemy died globally:", score_value)
	player.add_score(score_value)
