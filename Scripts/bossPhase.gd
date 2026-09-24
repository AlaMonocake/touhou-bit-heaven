extends Resource
class_name BossPhase

@export var phase_name: String = "IDKMAN"
@export var max_hp: int = 1000
@export var bullet_pattern: BulletPattern
@export var is_spellcard: bool = false
@export var spell_portrait: Texture2D
@export var spell_name: String = ""
@export var spell_time_limit: float = 30.0
@export var spell_bonus: int = 50000

@export var spell_position: Vector2 = Vector2(325, 120)
