extends Area2D
class_name EnemyBullet
enum MovementMode {
	STRAIGHT,
	ENCIRCLE_PLAYER,
	SWIRL_THEN_LAUNCH,
	DETOUR_RETURN
}

@export var speed: float = 200.0
@export var bullet_texture: Texture2D
@export var max_lifetime: float = 8.0

# Default movement
var velocity: Vector2 = Vector2.ZERO

# Shared mode switch
var movement_mode: int = MovementMode.STRAIGHT

# -------------------------
# ENCIRCLE_PLAYER variables
# -------------------------
var side: int = 1
var trigger_distance: float = 140.0
var rotate_speed: float = 1.8
var spread_speed_multiplier: float = 1.02
var tangent_strength: float = 1.4
var player_pathing: bool = false

# -------------------------
# SWIRL_THEN_LAUNCH variables
# -------------------------
var swirl_center: Vector2 = Vector2.ZERO
var swirl_base_position: Vector2 = Vector2.ZERO
var swirl_radius: float = 64.0
var swirl_turns: float = 1.0
var swirl_duration: float = 1.0
var swirl_rotation_side: int = 1
var launch_velocity: Vector2 = Vector2.ZERO

# -------------------------
# DETOUR_RETURN variables
# -------------------------
var detour_forward_duration: float = 0.4
var detour_return_duration: float = 2.0
var detour_turn_speed: float = 3.0
var detour_final_turn_speed: float = 2.0
var detour_forward_dir: Vector2 = Vector2.RIGHT
var detour_backward_dir: Vector2 = Vector2.LEFT
var detour_final_dir: Vector2 = Vector2.RIGHT
var detour_start_delay: float = 0.0

# Internal state
var player: Node2D = null
var curving: bool = false
var launched: bool = false
var mode_timer: float = 0.0
var lifetime: float = 0.0

func _ready() -> void:
	if movement_mode == MovementMode.ENCIRCLE_PLAYER:
		player = get_tree().get_root().find_child("Player", true, false)

func _process(delta: float) -> void:
	lifetime += delta
	if lifetime >= max_lifetime:
		queue_free()
		return

	match movement_mode:
		MovementMode.STRAIGHT:
			_update_straight(delta)

		MovementMode.ENCIRCLE_PLAYER:
			_update_encircle_player(delta)

		MovementMode.SWIRL_THEN_LAUNCH:
			_update_swirl_then_launch(delta)
		
		MovementMode.DETOUR_RETURN:
			_update_detour_return(delta)

func _update_straight(delta: float) -> void:
	position += velocity * delta

func _update_encircle_player(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_root().find_child("Player", true, false)

	if player_pathing and player != null:
		var to_player: Vector2 = player.global_position - global_position
		var dist: float = to_player.length()

		if not curving and dist <= trigger_distance:
			curving = true

		if curving:
			var away: Vector2 = (global_position - player.global_position).normalized()
			var tangent: Vector2 = away.rotated(side * PI * 0.5)
			var desired_dir: Vector2 = (away + tangent * tangent_strength).normalized()

			var current_dir: Vector2 = velocity.normalized()
			var new_dir: Vector2 = current_dir.slerp(desired_dir, rotate_speed * delta).normalized()

			var current_speed: float = velocity.length() * spread_speed_multiplier
			velocity = new_dir * current_speed

	position += velocity * delta

func _update_swirl_then_launch(delta: float) -> void:
	if not launched:
		mode_timer += delta

		var progress: float = clamp(mode_timer / swirl_duration, 0.0, 1.0)
		var angle: float = progress * TAU * swirl_turns * swirl_rotation_side
		var orbit_offset: Vector2 = Vector2.RIGHT.rotated(angle) * swirl_radius
		global_position = swirl_center + (swirl_base_position - swirl_center) + orbit_offset

		if progress >= 1.0:
			launched = true
			velocity = launch_velocity
	else:
		position += velocity * delta

func _on_body_entered(body) -> void:
	print("HIT:", body)

	if body.name == "Player":
		body.take_damage(1)
		queue_free()
	
func _on_area_entered(area) -> void:
	print("AREA HIT:", area)

	if area.name == "Player":
		area.take_damage(1)
		queue_free()
		
func _update_detour_return(delta: float) -> void:
	mode_timer += delta

	var current_speed: float = velocity.length()
	if current_speed <= 0.0:
		current_speed = speed

	if mode_timer < detour_start_delay:
		velocity = detour_forward_dir.normalized() * current_speed
		position += velocity * delta
		return

	var detour_time: float = mode_timer - detour_start_delay
	var desired_dir: Vector2

	if detour_time < detour_forward_duration:
		desired_dir = detour_forward_dir
		velocity = desired_dir.normalized() * current_speed
	elif detour_time < detour_forward_duration + detour_return_duration:
		var current_dir: Vector2 = velocity.normalized()
		desired_dir = detour_backward_dir.normalized()
		var new_dir: Vector2 = current_dir.slerp(desired_dir, detour_turn_speed * delta).normalized()
		velocity = new_dir * current_speed
	else:
		var current_dir: Vector2 = velocity.normalized()
		desired_dir = detour_final_dir.normalized()
		var new_dir: Vector2 = current_dir.slerp(desired_dir, detour_final_turn_speed * delta).normalized()
		velocity = new_dir * current_speed

	position += velocity * delta
