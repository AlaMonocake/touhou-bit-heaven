extends Area2D

@export var value: int = 100
@export var fall_gravity: float = 100.0
@export var max_fall_speed: float = 300.0

var velocity := Vector2(0, 120)
var target: Node2D = null
var auto_collect := false

func _ready():
	add_to_group("point_item")
	area_entered.connect(_on_collected)
	velocity = Vector2(
	randf_range(-40, 40),
	randf_range(-200, -120)
)

func _process(delta):
	if auto_collect and target:
		var dir = (target.global_position - global_position).normalized()
		velocity = dir * 400
	else:
		velocity.y += fall_gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)

		velocity.x = lerp(velocity.x, 0.0, 2.0 * delta)

	global_position += velocity * delta

func _on_collected(area):
	if area.name == "Hitbox":
		collect(area)

func collect(player):
	var final_value = player.get_parent().get_point_value()
	eventBus.enemy_died.emit(final_value) # reuse your score system
	
	# spawn popup (reuse your system)
	var popup = preload("res://UI/scorePopUp.tscn").instantiate()
	get_parent().add_child(popup)
	popup.global_position = global_position
	popup.setup(final_value)

	queue_free()
