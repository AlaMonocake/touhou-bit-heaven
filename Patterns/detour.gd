extends BulletPattern
class_name SnakeDetourShot

@export var bullet_scene: PackedScene

@export var line_count: int = 3
@export var bullets_per_line: int = 6
@export var line_spread_angle: float = 0.18
@export var line_spacing: float = 22.0

@export var speed: float = 180.0
@export var cooldown: float = 1.2
@export var aim_at_player: bool = true

# Snake timing
@export var detour_stagger: float = 0.12

# Detour timing
@export var detour_forward_duration: float = 0.35
@export var detour_return_duration: float = 2.2

# Turning
@export var detour_turn_speed: float = 2.2
@export var detour_final_turn_speed: float = 1.8
@export var detour_side_angle: float = 1.1

var timer: float = 0.0
var player: Node2D = null

func start(enemy) -> void:
	timer = 0.0
	player = enemy.get_tree().get_root().find_child("Player", true, false)

func update(enemy, delta: float) -> void:
	timer += delta

	if player == null or not is_instance_valid(player):
		player = enemy.get_tree().get_root().find_child("Player", true, false)

	if timer >= cooldown:
		fire(enemy)
		timer = 0.0

func fire(enemy) -> void:
	if bullet_scene == null:
		print("SnakeDetourShot: bullet_scene is null")
		return

	var origin: Vector2 = enemy.global_position
	var base_dir: Vector2 = Vector2.DOWN

	if aim_at_player and player != null and is_instance_valid(player):
		base_dir = (player.global_position - origin).normalized()

	if line_count <= 1:
		_fire_line(enemy, origin, base_dir, 1)
		return

	var line_center: float = (line_count - 1) / 2.0

	for line_index in range(line_count):
		var line_offset: float = line_index - line_center
		var line_angle: float = line_spread_angle * line_offset
		var line_dir: Vector2 = base_dir.rotated(line_angle)

		var side: int = -1
		if line_offset > 0.0:
			side = 1

		_fire_line(enemy, origin, line_dir, side)

func _fire_line(enemy, origin: Vector2, line_dir: Vector2, side: int) -> void:
	for i in range(bullets_per_line):
		var spawn_pos: Vector2 = origin - line_dir * (i * line_spacing)
		var delay: float = i * detour_stagger
		_spawn_detour_bullet(enemy, spawn_pos, line_dir, side, delay)

func _spawn_detour_bullet(enemy, spawn_pos: Vector2, initial_dir: Vector2, side: int, delay: float) -> void:
	var bullet = BulletSpawner.spawn_bullet(
		bullet_scene,
		enemy,
		initial_dir,
		speed,
		spawn_pos
	)

	if bullet == null:
		return

	bullet.movement_mode = bullet.MovementMode.DETOUR_RETURN

	bullet.detour_start_delay = delay
	bullet.detour_forward_duration = detour_forward_duration
	bullet.detour_return_duration = detour_return_duration
	bullet.detour_turn_speed = detour_turn_speed
	bullet.detour_final_turn_speed = detour_final_turn_speed

	bullet.detour_forward_dir = initial_dir.normalized()
	bullet.detour_backward_dir = initial_dir.rotated(detour_side_angle * side).normalized()
	bullet.detour_final_dir = initial_dir.normalized()

func finished() -> bool:
	return false
