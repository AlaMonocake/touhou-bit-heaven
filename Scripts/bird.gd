extends Enemy

@export var bullet_scene: PackedScene
@export var shoot_interval := 1.2
@export var movement_type: int

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	speed = 100.0
	anim.play("fly") 
	velocity = Vector2(0, speed)
	

func _physics_process(delta):
	velocity = move_direction.normalized() * speed
	super._physics_process(delta)

	# Delete if off screen
	if position.y > 1700:
		queue_free()
