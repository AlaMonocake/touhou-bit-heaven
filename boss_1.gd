extends CharacterBody2D

@export var phases: Array[BossPhase]
@export var life_pickup_scene: PackedScene
#@export var aimed_pattern: BulletPattern
@export var score_value: int = 100000

#for ai movement
@export var max_sway_distance := 40.0 #increase for wider dodges
@export var sway_move_speed := 8.0
#clamp
@export var arena_left_x := 29.0
@export var arena_right_x := 630.0

@onready var player = get_tree().get_root().find_child("Player", true, false)

var current_phase_index := 0
var hp := 0
var current_pattern: BulletPattern = null
#for ai 2 movement
var pressure_time := 0.0
var current_sway_x := 0.0
var target_sway_x := 0.0
var sway_timer := 0.0

#layered movement vars
var scripted_position: Vector2
var sway_offset: Vector2 = Vector2.ZERO

var spell_timer := 0.0
var spell_active := false
var transitioning := false

signal hp_changed(value)
signal phase_started(max_hp)
signal boss_died
signal spell_started(time)
signal spell_timer_updated(time)
signal spell_popup_requested(texture)
signal spell_started_full(spell_name)
signal spell_ended

func _ready():
	await get_tree().create_timer(0.2).timeout
	await wait_if_combat_disabled()

	if eventBus.combat_enabled:
		start_phase(0)
		#initialize scripted position
		scripted_position = global_position

func wait_if_combat_disabled():
	while not eventBus.combat_enabled:
		await get_tree().process_frame
		
func start_phase(index: int):
	if index >= phases.size():
		drop_life()
		die()
		return

	current_phase_index = index

	var phase = phases[current_phase_index]
	#print("PHASE STARTED:", phase.phase_name)
	#print("Is Spell:", phase.is_spellcard)
	hp = phase.max_hp

	phase_started.emit(hp)
	hp_changed.emit(hp)

	if phase.is_spellcard:
		begin_spell_transition(phase)
	else:
		if phase.bullet_pattern:
			if phase.is_spellcard:
				begin_spell_transition(phase)
			else:
				current_pattern = phase.bullet_pattern

				if current_pattern:
					current_pattern = current_pattern.duplicate(true)
					current_pattern.start(self)

func _process(delta):
	if GameState.phase == GameState.Phase.GAMEPLAY:
		if current_pattern:
			current_pattern.update(self, delta)

		if spell_active:
			spell_timer -= delta
			spell_timer_updated.emit(spell_timer)

			if spell_timer <= 0:
				end_spell_timeout()

	if GameState.phase != GameState.Phase.GAMEPLAY:
		return

	if current_pattern:
		current_pattern.update(self, delta)
	if spell_active:
		spell_timer -= delta
		spell_timer_updated.emit(spell_timer)

		if spell_timer <= 0:
			end_spell_timeout()
	# Track player pressure under boss
	if player and abs(player.global_position.x - global_position.x) < 60:
		pressure_time += delta
	else:
		pressure_time = max(pressure_time - delta * 2.0, 0.0)
	#the following line prevents the boss from being stuck on spawn x axis
	if not transitioning:  # <-- add this guard
		scripted_position = global_position - sway_offset
	# If pressured long enough, choose dodge direction AWAY from player
	if pressure_time >= 2.0 and abs(current_sway_x - target_sway_x) < 5:
		if player.global_position.x < global_position.x:
			target_sway_x = max_sway_distance   # move right
		else:
			target_sway_x = -max_sway_distance  # move left

		pressure_time = 0.0

	# Smooth toward dodge target
	current_sway_x = lerp(current_sway_x, target_sway_x, sway_move_speed * delta)

	sway_offset.x = current_sway_x

	# Apply layered position
	global_position = scripted_position + sway_offset

	# Clamp boss inside arena
	global_position.x = clamp(global_position.x, arena_left_x, arena_right_x)
	
	#alternative clamp code, try if current sucks:
	#var final_pos = scripted_position + sway_offset
	#final_pos.x = clamp(final_pos.x, arena_left_x, arena_right_x)
#
	#global_position = final_pos


#func shoot_pattern_towards_player():
	#if aimed_pattern == null:
		#print("No pattern assigned")
		#return
#
	#var pattern_instance = aimed_pattern.duplicate(true)
	#pattern_instance.start(self)
#
	## optional: run it once manually
	#pattern_instance.update(self, 0)
		#

func take_damage(amount: int):
	hp -= amount
	hp_changed.emit(hp)

	print("Boss HP:", hp)

	if hp <= 0:
		if spell_active:
			end_spell_capture()
		else:
			start_phase(current_phase_index + 1)
	#if hp <= 0:
#
		#die()
		#

func die():
	SoundManager.play_sfx("boss_death")
	boss_died.emit()
	queue_free()
	

func drop_life() -> void:
	var item = life_pickup_scene.instantiate()
	item.global_position = global_position
	get_parent().add_child(item)

func start_spellcard(phase: BossPhase):
	print("SPELLCARD START:", phase.phase_name)
	if phase.spell_portrait:
		spell_popup_requested.emit(
			phase.spell_portrait
		)
	# placeholder sound
	#SoundManager.play_sfx("spell_start")
	spell_timer = phase.spell_time_limit
	spell_active = true
	spell_started_full.emit(phase.spell_name)
	spell_started.emit(spell_timer)
	
func begin_spell_transition(phase: BossPhase):
	$MovementController.set_process(false)
	transitioning = true
	
	var old_sway = sway_offset
	sway_offset = Vector2.ZERO

	while scripted_position.distance_to(phase.spell_position) > 5:
		scripted_position = scripted_position.move_toward(
			phase.spell_position,
			200 * get_process_delta_time()
		)
		await get_tree().process_frame
	transitioning = false
	sway_offset = old_sway

	start_spellcard(phase)

	current_pattern = phase.bullet_pattern

	if current_pattern:
		current_pattern = current_pattern.duplicate(true)
		current_pattern.start(self)
			
func wait_until_at_position(target: Vector2):
	while global_position.distance_to(target) > 5:
		await get_tree().process_frame

func end_spell_timeout():
	spell_active = false
	print("Spell timed out!")
	spell_ended.emit()
	clear_spell_bullets()

	start_phase(current_phase_index + 1)

func end_spell_capture():
	spell_active = false
	print("Spell captured!")
	spell_ended.emit()
	clear_spell_bullets()

	start_phase(current_phase_index + 1)

func clear_spell_bullets():
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		bullet.queue_free()
