extends BulletPattern
class_name RadialBurst

@export var bullet_scene: PackedScene
@export var bullet_count: int = 12
@export var speed: float = 200.0
@export var cooldown: float = 1.0

var timer: float = 0.0

func start(enemy):
	timer = 0.0

func update(enemy, delta):
	timer += delta

	if timer >= cooldown:
		fire(enemy)
		timer = 0.0

func fire(enemy):
	for i in range(bullet_count):
		var angle = i * TAU / bullet_count
		var dir = Vector2.RIGHT.rotated(angle)

		BulletSpawner.spawn_bullet(
			bullet_scene,
			enemy,
			dir,
			speed
		)

func finished() -> bool:
	return false
