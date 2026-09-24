extends BulletPattern
class_name DanmakuRainFan

@export var bullet_scene: PackedScene
@export var bullet_count: int = 8
@export var speed: float = 180.0
@export var spread_angle: float = 0.8
@export var rotation_speed: float = 1.5
@export var cooldown: float = 0.2
@export var start_angle: float = PI / 2

var timer := 0.0
var current_angle := 0.0

func start(enemy) -> void:
	timer = 0.0
	current_angle = start_angle

func update(enemy, delta: float) -> void:
	timer += delta
	current_angle += rotation_speed * delta

	if timer >= cooldown:
		fire(enemy)
		timer = 0.0

func fire(enemy) -> void:
	if bullet_scene == null:
		print("DanmakuRainFan: bullet_scene is null")
		return

	if bullet_count <= 1:
		var single_dir := Vector2.RIGHT.rotated(current_angle)
		BulletSpawner.spawn_bullet(bullet_scene, enemy, single_dir, speed)
		return

	var center_offset := (bullet_count - 1) / 2.0

	for i in range(bullet_count):
		var offset := spread_angle * (i - center_offset) / center_offset
		var angle := current_angle + offset
		var dir := Vector2.RIGHT.rotated(angle)

		BulletSpawner.spawn_bullet(
			bullet_scene,
			enemy,
			dir,
			speed
		)

func finished() -> bool:
	return false
