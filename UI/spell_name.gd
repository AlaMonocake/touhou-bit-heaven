extends Label

func _ready():
	hide()

func connect_boss(boss):
	boss.spell_started_full.connect(show_spell)
	boss.spell_ended.connect(hide_spell)

func show_spell(name_text):
	text = name_text

	position.y = 300
	modulate.a = 0.0

	show()

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(self, "position:y", -11, 1.0)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.8)

func hide_spell():
	hide()
