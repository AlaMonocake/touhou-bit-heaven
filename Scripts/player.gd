# player.gd
class_name Player
extends CharacterBody2D

@export var speed: float = 300.0
@export var focus_speed := 150.0
@export var bomb_duration: float = 3.2
@export var bomb_portrait: Texture2D
@export var bomb_name: String = "Wacky Sign 「Placeholder Bomb」"
@export var bullet_scene: PackedScene
@export var mc_homing_bullet: PackedScene
@export var max_hp: int = 8
@export var invuln_time: float = 3.5
@export var max_bombs: int = 8
@export var starting_bombs: int = 2
@export var poc_y := 150 #point of collection area
@export var playfield_bottom := 765
@export var min_point_value := 100
@export var max_point_value := 1000

var hp: int
var is_focused := false
var is_invulnerable: bool = false

var power: int = 0
const MAX_POWER := 3 #1000 later


var bombs: int = 2
signal bombs_changed(new_amount)

signal bomb_started_ui(texture, bomb_name)
signal bomb_ended_ui

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var shoot_timer: Timer = $ShootTimer
@onready var spawn_point: Marker2D = $BulletSpawn
@onready var hitbox_indicator = $Hitbox/Sprite2D

#playfield_size is in SubViewport-local coordinates (Vector2)
var playfield_size: Vector2 = Vector2.ZERO
var invulnerable: bool = false

func initialize():
	bombs = starting_bombs
	bombs_changed.emit(bombs)

func _ready() -> void:
	print("Player parent:", get_parent())
	hp = 3
	bombs = starting_bombs
	bombs_changed.emit(bombs)
	# Shooting timer
	if shoot_timer:
		shoot_timer.wait_time = 0.07
		shoot_timer.one_shot = false
		shoot_timer.stop()
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)
		
func _process(delta):
	check_poc()
	
func set_playfield_size(size: Vector2) -> void:
	# Called from Main after subviewport/scene setup
	playfield_size = size

func _physics_process(delta: float) -> void:
	is_focused = Input.is_action_pressed("focus")
	var current_speed = focus_speed if is_focused else speed
	# MOVEMENT
	if GameState.phase != GameState.Phase.GAMEPLAY:
		return
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_vector * current_speed
	move_and_slide()
	hitbox_indicator.visible = is_focused

	# Clamp (hardcoded numbers)
	position.x = clamp(position.x, 4.0, 650.0)
	position.y = clamp(position.y, 10, 780.0)

	# ANIMATION (uses ui_* animations)
	_update_animation(input_vector)

	# SHOOTING - hold shoot to fire
	if eventBus.combat_enabled and Input.is_action_pressed("shoot"):
		if shoot_timer.is_stopped():
			shoot_timer.start()
	else:
		shoot_timer.stop()

	# BOMB
	if Input.is_action_just_pressed("bomb") and bombs > 0:
		bombs -= 1
		bombs_changed.emit(bombs)
		_start_bomb()

func _on_shoot_timer_timeout() -> void:
	_shoot()

func _shoot() -> void:
	if bullet_scene == null:
		push_warning("player: bullet_scene not assigned")
		return

	var parent_node = get_parent()
	if parent_node == null:
		parent_node = get_tree().current_scene

	var base_pos = spawn_point.global_position
	var damage = get_damage()

	# === PHASE LOGIC ===
	var bullet = bullet_scene.instantiate()
	bullet.damage = damage
	bullet.global_position = base_pos
	bullet.velocity = Vector2.UP * 600
	parent_node.add_child(bullet)

# --- Phase 1+: add spread shot ---
	if current_phase >= 1:
		var count = 2 if current_phase == 1 else 4
		var spread_angle = deg_to_rad(30)
		for i in range(count):
				var t = 0.0
				if count > 1:
					t = float(i) / (count - 1)
					var angle = lerp(-spread_angle / 2, spread_angle / 2, t)
					var dir = Vector2.UP.rotated(angle)
					var spread_bullet = bullet_scene.instantiate()  # renamed
					spread_bullet.global_position = base_pos
					spread_bullet.velocity = dir * 600
					parent_node.add_child(spread_bullet)

# --- Phase 3: add homing bullets ---
	if current_phase == 3 and mc_homing_bullet != null:
		for i in range(2):
			var h_bullet = mc_homing_bullet.instantiate()
			h_bullet.global_position = base_pos + Vector2((i * 20) - 10, 0)
			h_bullet.damage = int(damage * 0.5)
			h_bullet.modulate.a = 0.5
			h_bullet.scale = Vector2(0.8, 0.8)
			parent_node.add_child(h_bullet)

func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		anim.play("ui_idle")
		return
	if abs(dir.x) > abs(dir.y):
		anim.play("ui_right" if dir.x > 0 else "ui_left")
	else:
		anim.play("ui_down" if dir.y > 0 else "ui_up")

func _start_bomb() -> void:
	bomb_used.emit()
	bomb_started_ui.emit(bomb_portrait, bomb_name)
	invulnerable = true
	modulate = Color(1,1,1,0.5)
	await get_tree().create_timer(bomb_duration).timeout
	modulate = Color(1,1,1,1)
	bomb_ended_ui.emit()
	invulnerable = false
	
func check_poc():
	if global_position.y < poc_y:
		for item in get_tree().get_nodes_in_group("point_item"):
			item.auto_collect = true
			item.target = self

func take_damage(amount: int):
	if invulnerable:
		return
		
	hp -= amount
	health_changed.emit(hp)
	start_invincibility()
	bomb_up(2)
	remove_score(800)

	if hp <= 0:
		die()
		return

	
func die():
	SoundManager.play_sfx("player_death")
	died.emit()
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		take_damage(1)

	if body.is_in_group("enemy_bullet"):
		take_damage(1)
		
	if body.is_in_group("boss"):
		take_damage(1)
		
func start_invincibility():
	invulnerable = true

	# Blinking effect
	var blink_tween = create_tween()
	blink_tween.set_loops() # infinite for now
	blink_tween.tween_property(self, "modulate:a", 0.2, 0.1)
	blink_tween.tween_property(self, "modulate:a", 1.0, 0.1)

	await get_tree().create_timer(invuln_time).timeout

	blink_tween.kill()
	modulate = Color(1, 1, 1, 1)
	invulnerable = false

signal health_changed(new_hp)
signal died
signal bomb_used
signal score_changed(new_score)
signal power_changed(new_power)
signal power_phase_changed(new_phase)

func add_power(amount: int):
	power = clamp(power + amount, 0, MAX_POWER)
	emit_signal("power_changed", power)
	
	var new_phase = get_power_phase()
	if new_phase != current_phase:
		current_phase = new_phase
		emit_signal("power_phase_changed", current_phase)

var current_phase := 0

func get_power_phase() -> int:
	if power >= 6: #800
		return 3
	elif power >= 5: #500
		return 2
	elif power >= 2: #200
		return 1
	return 0
func get_damage() -> int:
	match current_phase:
		0: return 1
		1: return 2
		2: return 3
		3: return 4
	return 1

var score: int = 0
func add_score(amount: int):
	score += amount
	score = max(score, 0)
	score_changed.emit(score)
	
func remove_score(amount: int):
	score -= amount
	score = max(score, 0) #prevents score from going below 0
	score_changed.emit(score)
	
func hp_up(amount: int):
	hp += amount
	health_changed.emit(hp)
	

func bomb_up(amount: int):
	bombs += amount
	bombs_changed.emit(bombs)
	
	
func collect_pickup(pickup_type: int) -> void:
	match pickup_type:
		PickupItem.PickupType.LIFE:
			hp_up(1)
			print("Life up! Lives: ", hp)
		PickupItem.PickupType.BOMB:
			bomb_up(1)
			print("Bomb up! Bombs: ", bombs)
			
func get_point_value() -> int:
	var y = global_position.y
	
	# above POC → max value
	if y <= poc_y:
		return max_point_value
	
	# normalize between bottom and POC
	var t = inverse_lerp(playfield_bottom, poc_y, y)
	t = clamp(t, 0.0, 1.0)
	
	return int(lerp(min_point_value, max_point_value, t))
