extends Node2D

@export var bullet_scene: PackedScene
@export var speed := 150
@onready var timer: Timer = $Timer
@onready var viewport = get_tree().current_scene.get_node("SubViewportContainer/SubViewport")
@onready var player = viewport.get_node("Player")

func _process(delta):
	print(player)
		
	rotation += 4.0 * delta
	
func _ready():
	print(get_tree().current_scene.get_tree_string())
	#the shorter the timer (currently at 0.3s), the more spiral-like, else shots seem random and wrong
	timer.start()
	#IMPORTANT! The line that tells the timer "call this function whenever time runs out" (in this case every second)
	timer.timeout.connect(_on_timeout)

func _on_timeout():
	shoot_spiral(rotation)
	#the second call reverses direction and makes a second spiral
	shoot_spiral(-rotation)

func shoot_spiral(theangle):
	var dir_to_player = (player.global_position - global_position).normalized()
	var base_angle = dir_to_player.angle()
	var angle = base_angle + theangle
	var dir = Vector2(cos(angle), sin(angle))
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.velocity = dir * speed

	get_tree().current_scene.add_child(bullet)

#var dir_to_player = (player.global_position - global_position).normalized() THIS TARGETS THE PLAYER. IMPORTANT!
#gives back a directional vector like Vector2(0.7, 0.7). but we need an angle .angle() converts vector to angle
#for example Vector2(1, 0) → angle = 0 (right)
