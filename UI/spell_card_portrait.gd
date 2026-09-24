extends Control

@onready var portrait = $TextureRect


func play(texture: Texture2D):
	portrait.texture = texture

	modulate.a = 1.0
	position.y += 50

	show()

	var tween = create_tween()

	tween.parallel().tween_property(self, "position:y", position.y - 50, 2.0)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 2.0)

	await tween.finished

	hide()
