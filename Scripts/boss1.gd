extends Enemy

@export var phases: Array[BossPhase]

var current_phase_index := 0
var current_phase: BossPhase

func _ready():
	start_phase(0)

func _process(delta):
	if current_phase:
		current_phase.update(self, delta)

func start_phase(index: int):
	if index >= phases.size():
		die()
		return

	current_phase_index = index
	current_phase = phases[index].duplicate(true)
	current_phase.start(self)

func next_phase():
	start_phase(current_phase_index + 1)

func take_damage(amount):
	if current_phase:
		current_phase.take_damage(self,amount)
