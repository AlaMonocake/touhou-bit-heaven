extends BulletPattern
class_name RotatingRingPattern

@export var bullet_scene: PackedScene
@export var bullet_count: int = 16
@export var speed: float = 180.0
@export var rotation_speed: float = 1.5   # radians per second
@export var cooldown: float = 0.2

var timer: float = 0.0
var rotation: float = 0.0

func start(enemy):
	timer = 0.0
	rotation = 0.0

func update(enemy, delta):
	timer += delta
	rotation += rotation_speed * delta

	if timer >= cooldown:
		fire(enemy)
		timer = 0.0

func fire(enemy):
	for i in range(bullet_count):
		var angle = rotation + i * TAU / bullet_count
		var dir = Vector2.RIGHT.rotated(angle)

		BulletSpawner.spawn_bullet(
			bullet_scene,
			enemy,
			dir,
			speed
		)

func finished() -> bool:
	return false
