extends MovementPattern
class_name MoveToPoint

@export var target: Vector2
@export var speed := 200.0

func start(enemy):
	super.start(enemy)

func update(enemy, delta):
	super.update(enemy, delta)

	var dir = target - enemy.global_position
	var dist = dir.length()

	if dist < 5:
		enemy.global_position = target
		return

	var move = dir.normalized() * speed * delta

	# prevent overshooting
	if move.length() > dist:
		enemy.global_position = target
	else:
		enemy.global_position += move
