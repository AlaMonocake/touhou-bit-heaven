extends Node2D

@onready var canvas_modulate: CanvasModulate = $CanvasModulate

@onready var lightning_layers: Array[CanvasItem] = [
	$Lightning1,
	$Lightning2,
	$Lightning3,
	$Lightning4,
]

func _ready():
	randomize()

	for layer in lightning_layers:
		layer.visible = false
		_lightning_loop(layer)


func _lightning_loop(layer: CanvasItem) -> void:
	while true:
		# Wait a random amount of time
		await get_tree().create_timer(randf_range(0.5, 3.5)).timeout

		await _flash(layer)


func _flash(layer: CanvasItem) -> void:
	# First flash
	layer.visible = true
	_screen_flash()

	await get_tree().create_timer(0.04).timeout

	layer.visible = false

	# 50% chance of a second flash
	if randf() < 0.5:
		await get_tree().create_timer(0.03).timeout

		layer.visible = true
		_screen_flash()

		await get_tree().create_timer(0.03).timeout

		layer.visible = false
		
func _screen_flash() -> void:
	canvas_modulate.color = Color(1.5, 1.5, 1.5)

	var tween = create_tween()
	tween.tween_property(
		canvas_modulate,
		"color",
		Color.WHITE,
		0.15
	)
