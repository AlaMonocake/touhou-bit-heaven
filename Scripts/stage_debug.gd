extends Node2D

@export var playfield_size := Vector2(1280, 1600) # your real stage size
#enemies
#@export var bird_scene: PackedScene
#@export var spawn_interval := 2.0
#@export var boss_scene: PackedScene
#
@export var intro_dialogue: DialogueData
@onready var dialogue_box = $DialogueBox
@onready var song_name = "Stage 1 theme!"
@onready var dialogue_timer := Timer.new()
@onready var playfield_rect := Rect2(global_position, playfield_size)

# Optional clouds
@onready var clouds := $Clouds

var player
func _ready() -> void:
	SoundManager.play_music("stage1")
	
	add_child(dialogue_timer)
	dialogue_timer.wait_time = 1
	dialogue_timer.one_shot = true
	dialogue_timer.start()
	
	#await get_tree().create_timer(1).timeout
	#start_encounter()

	#if background.texture:
		#background.centered = false
		#background.position = Vector2.ZERO
#
		#playfield_size = Vector2i(
			#background.texture.get_width(),
			#background.texture.get_height()
		#)
	#else:
		#push_error("Background has no texture!")

	# Optional cloud movement (only if you added Clouds)
	#if clouds:
		#clouds.scroll_scale = Vector2(0.1, 0.1)
		#
		
#func spawn_boss():
	#var boss = boss_scene.instantiate()
	#add_child(boss)


#func shutdown():
	#if has_node("WaveManager"):
		#$WaveManager.stop()

func start_bomb_background(duration: float):
	print("STAGE: bomb background called")
	clouds.activate_bomb_bg(duration)
	
func clear_screen_for_bomb():
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		bullet.queue_free()

	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.has_method("die"):
			enemy.die()
		else:
			enemy.queue_free()
	
#boss dialogue
#func start_encounter():
	#dialogue_box.start(intro_dialogue)
