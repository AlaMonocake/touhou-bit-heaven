extends TextureProgressBar

func _ready():
	hide()


func connect_boss(boss):
	show()

	max_value = boss.hp
	value = boss.hp

	boss.hp_changed.connect(update_hp)
	boss.phase_started.connect(update_phase)
	boss.boss_died.connect(hide)


func update_hp(new_value):
	value = new_value


func update_phase(new_max):
	max_value = new_max
	value = new_max
