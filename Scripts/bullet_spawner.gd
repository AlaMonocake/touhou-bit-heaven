extends Node

func spawn_bullet(scene: PackedScene, enemy: Node2D, direction: Vector2, speed: float, spawn_position: Vector2 = Vector2.INF):
	if scene == null:
		print("spawn_bullet: scene is null")
		return null

	var bullet = scene.instantiate()
	enemy.get_parent().add_child(bullet)

	if spawn_position == Vector2.INF:
		bullet.global_position = enemy.global_position
	else:
		bullet.global_position = spawn_position

	var dir: Vector2 = direction.normalized()
	bullet.speed = speed
	bullet.velocity = dir * speed

	return bullet
