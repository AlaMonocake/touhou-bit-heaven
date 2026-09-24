extends Control

@onready var power_bar = $PowerBar
@onready var phase_label = $PhaseLabel

var player

func _ready():
	player = get_tree().root.find_child("Player", true, false)

	if player == null:
		push_warning("PowerUI: Player not found")
		return

	player.power_changed.connect(_on_power_changed)
	player.power_phase_changed.connect(_on_phase_changed)

	# initialize UI
	_on_power_changed(player.power)
	_on_phase_changed(player.current_phase)


func _on_power_changed(value: int):
	power_bar.value = value


func _on_phase_changed(phase: int):
	if phase == 3:
		phase_label.text = "MAX"
	else:
		phase_label.text = "POWER: " + str(phase)
