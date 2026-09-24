extends Node2D

@export var speed := 80.0
@export var bomb_speed := 1000.0

@export var normal_texture: Texture2D
@export var bomb_texture: Texture2D

@onready var sprite1 := $Sprite1
@onready var sprite2 := $Sprite2

var tex_height
var original_speed
var using_bomb_bg := false

func _ready():
	original_speed = speed
	if normal_texture:
		sprite1.texture = normal_texture
		sprite2.texture = normal_texture

	tex_height = sprite1.texture.get_height()

func _process(delta):
	sprite1.position.y += speed * delta
	sprite2.position.y += speed * delta

	if sprite1.position.y >= tex_height:
		sprite1.position.y = sprite2.position.y - tex_height

	if sprite2.position.y >= tex_height:
		sprite2.position.y = sprite1.position.y - tex_height
		
func activate_bomb_bg(duration: float):
	if using_bomb_bg:
		return

	using_bomb_bg = true

	speed = bomb_speed

	if bomb_texture:
		sprite1.texture = bomb_texture
		sprite2.texture = bomb_texture

		tex_height = bomb_texture.get_height()

	await get_tree().create_timer(duration).timeout

	deactivate_bomb_bg()
	
func deactivate_bomb_bg():
	using_bomb_bg = false

	speed = original_speed

	if normal_texture:
		sprite1.texture = normal_texture
		sprite2.texture = normal_texture

		tex_height = normal_texture.get_height()
