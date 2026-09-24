extends BulletPattern
class_name BasicSpellPattern

@export var fire_rate := 0.5

var timer := 0.0


func start(enemy):
	timer = 0.0


func update(enemy, delta):
	timer += delta

	if timer >= fire_rate:
		timer = 0.0

		var bullet = preload("res://Bullets/skullenemybullet.tscn").instantiate()

		bullet.global_position = enemy.global_position
		bullet.velocity = Vector2.DOWN * 200

		enemy.get_parent().add_child(bullet)
