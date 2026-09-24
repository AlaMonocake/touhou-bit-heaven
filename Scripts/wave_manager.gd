extends Node

@export var stage_data: StageData

var timer := 0.0
var current_index := 0

func _process(delta):
	if stage_data == null:
		return

	timer += delta

	while current_index < stage_data.waves.size():
		var wave = stage_data.waves[current_index]

		if timer >= wave.time:
			spawn_enemy(wave)
			current_index += 1
		else:
			break

func spawn_enemy(wave: WaveData):
	if wave.enemy_scene == null:
		return

	for i in range(wave.count):
		var enemy = wave.enemy_scene.instantiate()
		enemy.global_position = wave.position + Vector2(i * wave.spacing, 0)
		
		if enemy.is_in_group("boss"):
			var boss_bar = get_tree().current_scene.find_child("BossUI", true, false)
			var banner = boss_bar.get_node("SpellName")
			if banner:
				banner.connect_boss(enemy)
			var popup = boss_bar.get_node("SpellPortrait")
			if popup:
				enemy.spell_popup_requested.connect(popup.play)
			var spell_timer = boss_bar.get_node("SpellTimer")
			if spell_timer:
				spell_timer.connect_boss(enemy)
			if boss_bar:
				boss_bar.connect_boss(enemy)
			var phase_stars = boss_bar.get_node("PhaseStars")
			if phase_stars:
				phase_stars.connect_boss(enemy)

		var pattern_ctrl := enemy.get_node_or_null("PatternController") as PatternController
		var move_ctrl := enemy.get_node_or_null("MovementController") as MovementController

		print("pattern ctrl:", pattern_ctrl)
		print("move ctrl:", move_ctrl)

		if pattern_ctrl and wave.pattern:
			pattern_ctrl.patterns = [wave.pattern.duplicate(true)]

		if move_ctrl and not wave.movements.is_empty():
			var duped: Array[MovementPattern] = []
			for m in wave.movements:
				duped.append(m.duplicate(true))
				move_ctrl.movements = duped

		get_parent().add_child(enemy)
