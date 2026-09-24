extends Node
class_name PatternController

@export var patterns: Array[BulletPattern]:
	set(value):
		patterns = value
		if is_inside_tree():
			for p in patterns:
				if p:
					p.start(get_parent())

func _ready():
	for p in patterns:
		if p:
			p.start(get_parent())

func _process(delta):
	for p in patterns:
		if p:
			p.update(get_parent(), delta)
