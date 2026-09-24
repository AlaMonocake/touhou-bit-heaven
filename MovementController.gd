extends Node
class_name MovementController

@export var movements: Array[MovementPattern] = []
@export var loop: bool = false

var current_index: int = 0
var current_movement: MovementPattern = null


func _ready():
	#print("MovementController _ready fired, movements count: ", movements.size())
	if movements.size() > 0:
		start_movement(0)


func _process(delta):
	if current_movement == null:
		return
	current_movement.update(get_parent(), delta)
	#print("elapsed: ", current_movement.elapsed, " / duration: ", current_movement.duration, " | finished: ", current_movement.finished())
	if current_movement.finished():
		print("switching from index ", current_index, " to ", current_index + 1)
		next_movement()


func start_movement(index: int):
	if index < 0 or index >= movements.size():
		return
	current_index = index
	current_movement = movements[current_index].duplicate()
	#print("started movement ", index, " | instance id: ", current_movement.get_instance_id())
	if current_movement:
		current_movement.start(get_parent())

func next_movement():
	var next_index = current_index + 1

	if next_index >= movements.size():
		if loop:
			next_index = 0
		else:
			current_movement = null
			return

	start_movement(next_index)
