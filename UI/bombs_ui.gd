extends HBoxContainer

@export var max_bombs: int = 8
@export var bomb_full: Texture2D
@export var bomb_empty: Texture2D

func set_bombs(value: int):
	for i in range(max_bombs):
		var icon = get_child(i)
		if i < value:
			get_child(i).texture = bomb_full
		else:
			get_child(i).texture = bomb_empty
