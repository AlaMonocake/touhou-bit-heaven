extends CharacterBody2D

@export var max_hp: int = 3
@export var move_direction:  Vector2
@export var speed: float = 150.0
@export var bullet_scene: PackedScene
#@export var aimed_pattern: BulletPattern
@onready var shoot_timer := $ShootTimer

var hp: int

func _ready():
	hp = max_hp
	shoot_timer.timeout.connect(_shoot)
	shoot_timer.wait_time = 1.5
	shoot_timer.start()
func _physics_process(delta):

	move_and_slide()
	
func _shoot():
	var velocity = Vector2.ZERO  # starts with no movement


func _process(delta):
	position += velocity * delta
func take_damage(amount: int):
	hp -= amount
	modulate = Color(1.0, 0.866, 0.859, 1.0)
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1,1,1)

	if hp <= 0:
		die()

func die():
	print("ENEMY DIED")
	queue_free()
