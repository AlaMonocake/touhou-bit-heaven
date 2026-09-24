extends Node2D

@onready var label: Label = $Label

var velocity := Vector2(0, -60) # upward
var lifetime := 0.8
var timer := 0.0

func setup(value: int):
	label.text = "+" + str(value)

func _process(delta):
	timer += delta
	
	# move up
	position += velocity * delta
	
	# fade out
	modulate.a = 1.0 - (timer / lifetime)
	
	if timer >= lifetime:
		queue_free()
