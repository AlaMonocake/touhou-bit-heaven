#@export var life_pickup_scene: PackedScene
#@export var bomb_pickup_scene: PackedScene
#
#func drop_life() -> void:
	#var item = life_pickup_scene.instantiate()
	#item.global_position = global_position
	#get_parent().add_child(item)
#
#func drop_bomb() -> void:
	#var item = bomb_pickup_scene.instantiate()
	#item.global_position = global_position
	#get_parent().add_child(item)
	#
	#on death: SoundManager.play_sfx("boss_death")
