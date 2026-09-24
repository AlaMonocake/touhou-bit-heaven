extends BulletPattern
class_name EncircleShot

@export var primary_bullet_scene: PackedScene
@export var secondary_bullet_scene: PackedScene

@export var primary_bullet_count: int = 5
@export var primary_speed: float = 170.0
@export var arc_width: float = 180.0

@export var secondary_bullet_count: int = 2
@export var secondary_speed: float = 260.0
@export var secondary_spread: float = 0.16

@export var cooldown: float = 1.0

# Primary bullet behavior tuning
@export var trigger_distance: float = 140.0
@export var rotate_speed: float = 1.8
@export var spread_speed_multiplier: float = 1.02
@export var tangent_strength: float = 1.4

var timer := 0.0
var player: Node2D = null

func start(enemy) -> void:
	timer = 0.0
	player = enemy.get_tree().get_root().find_child("Player", true, false)
	if player == null:
		print("EncircleShot: NO PLAYER FOUND")

func update(enemy, delta: float) -> void:
	timer += delta

	if player == null or not is_instance_valid(player):
		player = enemy.get_tree().get_root().find_child("Player", true, false)

	if player == null:
		return

	if timer >= cooldown:
		fire(enemy)
		timer = 0.0

func fire(enemy) -> void:
	if player == null or not is_instance_valid(player):
		player = enemy.get_tree().get_root().find_child("Player", true, false)
	if player == null:
		print("EncircleShot: NO PLAYER FOUND")
		return

	var origin: Vector2 = enemy.global_position
	var to_player: Vector2 = (player.global_position - origin).normalized()
	var perp: Vector2 = to_player.orthogonal().normalized()

	# Primary bullets: pass around the player, then curve away
	if primary_bullet_scene != null:
		if primary_bullet_count <= 1:
			var single_target: Vector2 = player.global_position
			var single_dir: Vector2 = (single_target - origin).normalized()
			_spawn_primary(enemy, single_dir, 1)
		else:
			for i in range(primary_bullet_count):
				var t: float = float(i) / float(primary_bullet_count - 1)
				var offset: float = lerp(-arc_width * 0.5, arc_width * 0.5, t)
				var target: Vector2 = player.global_position + perp * offset
				var dir: Vector2 = (target - origin).normalized()

				var side: int = -1
				if offset > 0.0:
					side = 1

				_spawn_primary(enemy, dir, side)

	# Secondary bullets: straight at the player with adjustable count
	if secondary_bullet_scene != null:
		if secondary_bullet_count <= 1:
			var bullet = BulletSpawner.spawn_bullet(
				secondary_bullet_scene,
				enemy,
				to_player,
				secondary_speed
			)
			if bullet != null:
				bullet.movement_mode = bullet.MovementMode.STRAIGHT
		else:
			var center_offset: float = (secondary_bullet_count - 1) / 2.0

			for i in range(secondary_bullet_count):
				var offset: float = secondary_spread * (i - center_offset)
				var shot_dir: Vector2 = to_player.rotated(offset)

				var bullet = BulletSpawner.spawn_bullet(
					secondary_bullet_scene,
					enemy,
					shot_dir,
					secondary_speed
				)
				if bullet != null:
					bullet.movement_mode = bullet.MovementMode.STRAIGHT

func _spawn_primary(enemy, direction: Vector2, side: int) -> void:
	var bullet = BulletSpawner.spawn_bullet(
		primary_bullet_scene,
		enemy,
		direction,
		primary_speed
	)

	if bullet == null:
		return

	bullet.movement_mode = bullet.MovementMode.ENCIRCLE_PLAYER
	bullet.player_pathing = true
	bullet.side = side
	bullet.trigger_distance = trigger_distance
	bullet.rotate_speed = rotate_speed
	bullet.spread_speed_multiplier = spread_speed_multiplier
	bullet.tangent_strength = tangent_strength

func finished() -> bool:
	return false
