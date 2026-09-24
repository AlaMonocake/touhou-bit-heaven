extends HBoxContainer

@export var max_hearts: int = 7
@export var starting_hearts: int = 3
@export var heart_full: Texture2D
@export var heart_empty: Texture2D

var current_hearts: int

func _ready():
	current_hearts = starting_hearts
	update_hearts()

func set_hearts(value: int):
	current_hearts = clamp(value, 0, max_hearts)
	update_hearts()

func update_hearts():
	for i in range(max_hearts):
		var heart = get_child(i)
		if i < current_hearts:
			heart.texture = heart_full
		else:
			heart.texture = heart_empty
