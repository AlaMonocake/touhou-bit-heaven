extends Control

@export var playfield_width: float = 650.0
@export var left_bound: float = 0.0
@export var right_bound: float = 650.0
@export var playfield_offset_x: float = 0.0

var boss: Node2D = null


func _process(delta):
	boss = get_tree().get_first_node_in_group("boss")
	if boss == null or not is_instance_valid(boss):
		visible = false
		return

	visible = true

	# normalize boss X position (0 → 1)
	var t = inverse_lerp(left_bound, right_bound, boss.global_position.x)

	# apply to UI position
	var screen_x = lerp(0.0, playfield_width, t)

	position.x = screen_x + playfield_offset_x
