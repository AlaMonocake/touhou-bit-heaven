extends Resource
class_name MovementPattern

@export var duration: float = 1.0

var elapsed: float = 0.0

func start(enemy: Node2D) -> void:
	elapsed = 0.0


func update(enemy: Node2D, delta: float) -> void:
	elapsed += delta


func finished() -> bool:
	return elapsed >= duration
