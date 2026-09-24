class_name PickupItem
extends Area2D

enum PickupType {
	LIFE,
	BOMB
}

@export var pickup_type: PickupType = PickupType.LIFE
@export var icon: Texture2D
@export var fall_speed: float = 180.0

@onready var sprite: Sprite2D = $Sprite2D
var collected := false

func _ready() -> void:
	if sprite:
		sprite.texture = icon

	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position.y += fall_speed * delta

func _on_area_entered(area: Area2D) -> void:
	print("AREA ENTERED:", area.name)

	if collected:
		return

	var player := area.get_parent()
	if player and player.has_method("collect_pickup"):
		collected = true
		player.collect_pickup(pickup_type)
		queue_free()
