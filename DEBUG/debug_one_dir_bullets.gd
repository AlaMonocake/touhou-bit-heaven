extends Node2D

var velocity = Vector2.ZERO  # starts with no movement

func _ready():
	velocity = Vector2(0, 2000)
	
func _process(delta):
	position += velocity * delta

#Vector2(500, 0) 500 = X left-right speed. 0 = Y up-down speed . bigger = faster.
#X (cos) = LEFT-RIGHT
#Y (sin) = UP-DOWN
#- MEANS OPPOSITE
#SO -200 X IS LEFT, BECAUSE IT'S THE OPPOSITE OF RIGHT
#TAU = full circle, so half circle = TAU/2 etc
