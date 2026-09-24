extends MovementPattern
class_name MoveSine

@export var speed := 150.0
@export var amplitude := 100.0
@export var frequency := 2.0

var time := 0.0
var start_x := 0.0

func start(enemy):
	super.start(enemy)
	start_x = enemy.global_position.x
	time = 0.0

func update(enemy, delta):
	super.update(enemy, delta)

	time += delta

	var y = enemy.global_position.y + speed * delta
	var x = start_x + sin(time * frequency) * amplitude

	enemy.global_position = Vector2(x, y)
