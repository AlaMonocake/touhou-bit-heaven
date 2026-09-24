class_name Enemy
extends CharacterBody2D

@export var max_hp: int = 3
@export var move_direction:  Vector2
@export var speed: float = 150.0
@export var score_value: int = 100
@export var explosion_scene: PackedScene
@onready var pattern_controller: PatternController = $PatternController
@onready var movement_controller: MovementController = $MovementController

var hp: int
var point_item_scene = preload("res://point_item.tscn")
var power_item = preload("res://power_item.tscn")
var current_pattern: BulletPattern
var score_popup_scene = preload("res://UI/scorePopUp.tscn")

func _ready():
	hp = max_hp
	if pattern_controller.patterns.size() > 0:
		pattern_controller.patterns[0].start(self)
	
func _physics_process(delta):

	move_and_slide()
	
func _process(delta):
	if eventBus.combat_enabled and current_pattern:
		current_pattern.update(self, delta)
	
	if position.x < -100 or position.x > 2000 or position.y > 2000:
		queue_free()

func take_damage(amount: int):
	hp -= amount
	modulate = Color(1.0, 0.866, 0.859, 1.0)
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1,1,1)

	if hp <= 0:
		die()

func die():
	print("ENEMY DIED")
	SoundManager.play_sfx("enemy_death")
	eventBus.enemy_died.emit(score_value)
	#popup
	var popup = score_popup_scene.instantiate()
	get_parent().add_child(popup)
	popup.global_position = global_position
	popup.setup(score_value)
	# drop items
	for i in range(3): # adjust amount
		var item = point_item_scene.instantiate()
		get_parent().add_child(item)
		item.global_position = global_position
		
		# small spread
		item.velocity = Vector2(
			randf_range(-50, 50),
			randf_range(-150, -50)
		)
		#power items
		for ii in range(3): # adjust amount
			var pu = power_item.instantiate()
			get_parent().add_child(pu)
			pu.global_position = global_position
		
			pu.velocity = Vector2(
				randf_range(-50, 50),
				randf_range(-150, -50)
		)
	#death effect
	if explosion_scene:
		var e = explosion_scene.instantiate()
		get_parent().add_child(e)
		e.global_position = global_position
		e.rotation = randf() * TAU
		e.scale = Vector2.ONE * randf_range(0.8, 1.2)
	queue_free()

func setup(pattern: BulletPattern, movement: MovementPattern) -> void:
	if pattern_controller and pattern:
		pattern_controller.patterns = [pattern.duplicate(true)]

	if movement_controller and movement:
		movement_controller.movement = movement.duplicate(true)
