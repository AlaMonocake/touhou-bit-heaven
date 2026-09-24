extends CanvasLayer

signal retry_pressed
signal quit_pressed

func _ready():
	$TextureRect/VBoxContainer/RetryButton.pressed.connect(_on_retry)
	$TextureRect/VBoxContainer/QuitButton.pressed.connect(_on_quit)

func _on_retry():
	retry_pressed.emit()

func _on_quit():
	quit_pressed.emit()
