extends Area2D

@export var speed := 600.0
@export var damage := 1


#func _ready():
	#print("Bullet ready")
var velocity: Vector2
func _physics_process(delta):
	position += velocity * delta

	if position.y < 0:
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
