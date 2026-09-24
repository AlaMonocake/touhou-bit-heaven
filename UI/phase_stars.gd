extends HBoxContainer


func connect_boss(boss):
	update_stars(boss)

	boss.phase_started.connect(func(_hp): update_stars(boss))
	boss.boss_died.connect(hide)


func update_stars(boss):
	var remaining = boss.phases.size() - boss.current_phase_index - 1

	for i in range(get_child_count()):
		get_child(i).visible = i < remaining
