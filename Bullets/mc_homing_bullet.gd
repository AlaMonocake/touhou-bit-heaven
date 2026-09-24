extends Node2D

@export var speed: float = 300.0
@export var turn_speed: float = 5.0 # how fast it curves
var damage: int = 1

var velocity: Vector2 = Vector2.UP * 300
var target: Node2D = null

func _ready():
	# --- faint "option bullet" look ---
	modulate.a = 0.5
	scale = Vector2(0.8, 0.8)

	find_target()

func _process(delta):
	# --- target tracking ---
	if target and is_instance_valid(target):
		var desired_dir = (target.global_position - global_position).normalized()
		var current_dir = velocity.normalized()

		# smooth turning (VERY important for good feel)
		var new_dir = current_dir.lerp(desired_dir, turn_speed * delta).normalized()
		velocity = new_dir * speed
	else:
		find_target()

	# --- movement ---
	position += velocity * delta


func find_target():
	var enemies = get_tree().get_nodes_in_group("enemies")

	if enemies.size() == 0:
		target = null
		return

	# --- find closest enemy (better than [0]) ---
	var closest = enemies[0]
	var closest_dist = global_position.distance_squared_to(closest.global_position)

	for e in enemies:
		var d = global_position.distance_squared_to(e.global_position)
		if d < closest_dist:
			closest = e
			closest_dist = d

	target = closest

# --- simple hit handling ---
func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	if body.is_in_group("boss"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
