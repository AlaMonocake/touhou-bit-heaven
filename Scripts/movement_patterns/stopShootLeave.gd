extends MovementPattern
class_name MoveStopAndGo

@export var speed := 200.0
@export var stop_time := 1.5
@export var move_time := 2.0

var timer := 0.0
var phase := 0

func start(enemy):
	super.start(enemy)
	timer = 0.0
	phase = 0

func update(enemy, delta):
	super.update(enemy, delta)

	timer += delta

	match phase:
		0: # moving
			enemy.global_position.y += speed * delta
			if timer >= move_time:
				timer = 0.0
				phase = 1

		1: # stopped
			if timer >= stop_time:
				timer = 0.0
				phase = 0
