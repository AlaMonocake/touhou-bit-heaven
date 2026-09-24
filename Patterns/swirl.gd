extends BulletPattern
class_name SwirlLineShot

@export var bullet_scene: PackedScene

@export var bullet_count: int = 8
@export var line_width: float = 180.0
@export var launch_speed: float = 220.0
@export var cooldown: float = 1.2

@export var swirl_radius: float = 64.0
@export var swirl_turns: float = 1.0
@export var swirl_duration: float = 1.0
@export var launch_angle_offset: float = 0.0

# If true, line points toward player. If false, defaults downward.
@export var aim_at_player: bool = true

# If true, bullets alternate swirl directions across the line.
@export var alternate_rotation_sides: bool = true

var timer := 0.0
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
		print("SwirlLineShot: bullet_scene is null")
		return

	var origin: Vector2 = enemy.global_position
	var base_dir: Vector2 = Vector2.DOWN

	if aim_at_player and player != null and is_instance_valid(player):
		base_dir = (player.global_position - origin).normalized()

	var perp: Vector2 = base_dir.orthogonal().normalized()

	if bullet_count <= 1:
		_spawn_swirl_bullet(enemy, origin, base_dir, 1)
		return

	for i in range(bullet_count):
		var t: float = float(i) / float(bullet_count - 1)
		var offset: float = lerp(-line_width * 0.5, line_width * 0.5, t)
		var spawn_pos: Vector2 = origin + perp * offset

		var side: int = 1
		if alternate_rotation_sides:
			side = -1 if i % 2 == 0 else 1

		_spawn_swirl_bullet(enemy, spawn_pos, base_dir, side)

func _spawn_swirl_bullet(enemy, spawn_pos: Vector2, base_dir: Vector2, side: int) -> void:
	var bullet = bullet_scene.instantiate()
	if bullet == null:
		print("SwirlLineShot: failed to instantiate bullet")
		return

	enemy.get_parent().add_child(bullet)
	bullet.global_position = spawn_pos

	bullet.movement_mode = bullet.MovementMode.SWIRL_THEN_LAUNCH
	bullet.swirl_base_position = spawn_pos
	bullet.swirl_center = enemy.global_position
	bullet.swirl_radius = swirl_radius
	bullet.swirl_turns = swirl_turns
	bullet.swirl_duration = swirl_duration
	bullet.swirl_rotation_side = side
	bullet.launch_velocity = base_dir.rotated(launch_angle_offset) * launch_speed

func finished() -> bool:
	return false
