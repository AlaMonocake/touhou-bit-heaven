class_name MidBoss
extends CharacterBody2D

@export var max_hp: int = 50
@export var speed: float = 80
@export var bullet_scene: PackedScene
@export var bomb_pickup_scene: PackedScene

var hp: int
var phase: int = 1
var dance_direction := 1
var drift_target_y := 250.0

#@onready var shoot_timer := $ShootTimer

signal hp_changed(value)
signal boss_died

func _ready():
	hp = max_hp
	hp_changed.emit(hp)
	position = Vector2(600, 0)
	#shoot_timer.timeout.connect(_shoot_circle)
	#shoot_timer.wait_time = 1.5
	#shoot_timer.start()

func _physics_process(delta):
	#print("Phase:", phase)
	
	if phase == 1:
		if position.y < drift_target_y:
			velocity = Vector2(0, 40)
		else:
			velocity = Vector2.ZERO
	elif phase == 2:
		velocity.x = 120 * dance_direction
		velocity.y = sin(Time.get_ticks_msec() / 400.0) * 40
		
		if position.x < 100:
			dance_direction = 1
		elif position.x > 550:
			dance_direction = -1
	
	move_and_slide()

#func _shoot_circle():
	#if bullet_scene == null:
		#return
	#
	#var bullet_count = 16
	#
	#for i in bullet_count:
		#var bullet = bullet_scene.instantiate()
		#get_parent().add_child(bullet)
		#bullet.global_position = global_position
		#
		#var angle = i * (TAU / bullet_count)
		#bullet.direction = Vector2.RIGHT.rotated(angle)

func take_damage(amount: int):
	hp -= amount
	hp_changed.emit(hp)  # Emit signal when HP changes
	print("Boss HP:", hp)
	
	if hp <= max_hp / 2 and phase == 1:
		start_phase_two()
	
	if hp <= 0:
		drop_bomb()
		die()

func start_phase_two():
	phase = 2
	#shoot_timer.wait_time = 0.6

func die():
	SoundManager.play_sfx("boss_death")
	#shoot_timer.stop()
	boss_died.emit()
	queue_free()
	
func drop_bomb() -> void:
	var item = bomb_pickup_scene.instantiate()
	item.global_position = global_position
	get_parent().add_child(item)
