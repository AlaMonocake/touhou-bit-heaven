extends Resource
class_name WaveData

@export var count: int = 5 #how many enemies
@export var spacing: float = 50 #spacing between them
@export var time: float = 0.0 #when they spawn
@export var enemy_scene: PackedScene #what type of enemies
@export var position: Vector2 #where they spawn
@export var pattern: BulletPattern #the BulletPattern
@export var movements: Array[MovementPattern]
