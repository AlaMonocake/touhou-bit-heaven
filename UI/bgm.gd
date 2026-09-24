extends Control

@onready var label: Label = $HBoxContainer/Label

func show_bgm(song_name: String):
	label.text = "BGM: " + song_name
	
	# Start off-screen (to the right)
	var start_pos = position + Vector2(300, 0)
	var end_pos = position
	
	position = start_pos
	modulate.a = 1.0
	
	var tween = create_tween()

	# Slide in
	tween.tween_property(self, "position", end_pos, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Wait
	tween.tween_interval(2.0)

	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
