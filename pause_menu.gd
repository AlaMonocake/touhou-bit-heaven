extends CanvasLayer

signal resume_pressed
signal retry_pressed
signal quit_pressed

func _ready():
	$VBoxContainer/Resume.pressed.connect(_on_resume)
	$VBoxContainer/RetryLevel.pressed.connect(_on_retry)
	$VBoxContainer/ReturnToTitle.pressed.connect(_on_quit)

	$VBoxContainer/Resume.grab_focus()

func _on_resume():
	resume_pressed.emit()

func _on_retry():
	retry_pressed.emit()

func _on_quit():
	quit_pressed.emit()
