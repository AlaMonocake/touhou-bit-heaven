extends Node2D

@export var bullet_scene: PackedScene
@export var bullet_count := 8
@export var speed := 200
@onready var timer: Timer = $Timer

func _process(delta):
	#optional, makes the circle rotate
	rotation += 0.7 * delta

func _ready():
	timer.start()
	#IMPORTANT! The line that tells the timer "call this function whenever time runs out" (in this case every second)
	timer.timeout.connect(_on_timeout)
	
func _on_timeout():
	shoot_circle()
	
func shoot_circle():
	for i in range(bullet_count):
		var angle = i * (TAU / bullet_count) + rotation
		#without + rotation, the rotation isn't actually applied
		var dir = Vector2(cos(angle), sin(angle))
		
		var bullet = bullet_scene.instantiate()
		bullet.position = position
		bullet.velocity = dir * speed
		
		add_child(bullet)
#Each bullet (i):
#gets a different angle
#that angle becomes a direction
#that direction becomes velocity
