extends Label

func _ready():
	hide()

func connect_player(player):
	player.bomb_started_ui.connect(show_bomb_name)
	player.bomb_ended_ui.connect(end_bomb_name)

func show_bomb_name(texture, bomb_name):
	text = bomb_name

	position.y = 650
	modulate.a = 0.0

	show()

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(self, "position:y", 600, 1.0)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.8)

func end_bomb_name():
	var tween = create_tween()

	tween.tween_property(self, "modulate:a", 0.0, 0.5)

	await tween.finished

	hide()
