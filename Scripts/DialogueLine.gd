extends Resource
class_name DialogueLine

enum Side { LEFT, RIGHT }

@export var speaker_name: String
@export var text: String

# Who is speaking
@export var side: DialogueLine.Side = DialogueLine.Side.LEFT

# Portrait for that line
@export var portrait: Texture2D

# Future-proof
@export var expression: String = "neutral"
