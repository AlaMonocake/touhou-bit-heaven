extends MovementPattern
class_name MoveStraight

@export var velocity: Vector2 = Vector2(0, 200)

func start(enemy):
	super.start(enemy)

func update(enemy, delta):
	super.update(enemy, delta)
	enemy.global_position += velocity * delta
