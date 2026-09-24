extends BulletPattern
class_name SpreadShot

@export var bullet_scene: PackedScene
@export var bullet_count: int = 5
@export var speed: float = 220.0
@export var spread_angle: float = 0.5
@export var cooldown: float = 0.7

var timer := 0.0
var player: Node2D = null

func start(enemy) -> void:
	timer = 0.0
	player = enemy.get_tree().get_root().find_child("Player", true, false)
	if player == null:
		print("NO PLAYER FOUND")
		return

func update(enemy, delta: float) -> void:
	timer += delta

	if player == null or not is_instance_valid(player):
		player = enemy.get_tree().get_root().find_child("Player", true, false)
	if player == null:
		print("NO PLAYER FOUND")
		return

	if timer >= cooldown:
		fire(enemy)
		timer = 0.0

func fire(enemy) -> void:
	if bullet_scene == null:
		print("SpreadShot: bullet_scene is null")
		return

	if player == null or not is_instance_valid(player):
		player = enemy.get_tree().get_root().find_child("Player", true, false)
	if player == null:
		print("NO PLAYER FOUND")
		return
		if player == null:
			print("SpreadShot: Player node not found")
			return

	var origin: Vector2 = enemy.global_position
	var base_angle := (player.global_position - origin).angle()
	var center_offset := (bullet_count - 1) / 2.0

	for i in range(bullet_count):
		var offset := spread_angle * (i - center_offset)
		var angle := base_angle + offset
		var dir := Vector2.RIGHT.rotated(angle)

		BulletSpawner.spawn_bullet(
			bullet_scene,
			enemy,
			dir,
			speed
		)


func finished() -> bool:
	return false
