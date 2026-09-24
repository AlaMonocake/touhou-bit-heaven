extends Control

@onready var portrait = $BombPortrait


func _ready():
	hide()


func connect_player(player):
	player.bomb_started_ui.connect(show_bomb)
	player.bomb_ended_ui.connect(end_bomb)


func show_bomb(texture, bomb_name):
	portrait.texture = texture

	position.y = 500
	modulate.a = 1.0

	show()

	var tween = create_tween()
	tween.parallel().tween_property(self, "position:y", 450, 1.0)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.8)


func end_bomb():
	var tween = create_tween()

	tween.tween_property(self, "modulate:a", 0.0, 0.5)

	await tween.finished

	hide()
