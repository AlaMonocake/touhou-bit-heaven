extends CanvasLayer

@onready var name_label = $Panel/NameLabel
@onready var text_label = $Panel/TextLabel
@onready var left_portrait = $Panel/PortraitLeft
@onready var right_portrait = $Panel/PortraitRight

var dialogue: DialogueData
var index = 0
var active = false

var skip_mode := false
var skip_speed := 0.03  # seconds between lines when holding Ctrl
var skip_timer := 0.0

func _process(delta):
	skip_mode = Input.is_action_pressed("skip_dialogue")

	if skip_mode:
		skip_timer += delta
		if skip_timer >= skip_speed:
			next_line()
			skip_timer = 0.0
	else:
		skip_timer = 0.0

func start(dialogue_data: DialogueData):
	dialogue = dialogue_data
	index = 0
	active = true
	eventBus.combat_enabled = false
	show()
	_show_line()

func _input(event):
	if not active:
		return
	if event.is_action_pressed("advance_dialogue"):
		_next_line()
	
	if event.is_action_pressed("ui_accept"):
		_next_line()
		

func next_line():
	index += 1

	if dialogue == null:
		return

	if index >= dialogue.lines.size():
		end_dialogue()
		return

	_show_line()
	
func start_dialogue():
	index = 0
	_show_line()
	
func end_dialogue():
	#print("Dialogue finished")
	visible = false  # or queue_free()
	eventBus.combat_enabled = true
	GameState.phase = GameState.Phase.GAMEPLAY

func _show_line():
	if dialogue == null:
		print("No dialogue!")
		return

	if index >= dialogue.lines.size():
		end_dialogue()
		return

	var line = dialogue.lines[index]

	text_label.text = line.text
	name_label.text = line.speaker_name

	if line.side == DialogueLine.Side.LEFT:
		left_portrait.modulate = Color(1,1,1,1)
		right_portrait.modulate = Color(1,1,1,0.7)
	else:
		right_portrait.modulate = Color(1,1,1,1)
		left_portrait.modulate = Color(1,1,1,0.7)

	# Assign portrait based on side
	if line.side == DialogueLine.Side.LEFT:
		left_portrait.texture = line.portrait
		left_portrait.visible = true

		# Optional: dim the other side
		right_portrait.modulate.a = 0.7
	else:
		right_portrait.texture = line.portrait
		right_portrait.visible = true

		left_portrait.modulate.a = 0.7

func _next_line():
	index += 1
	_show_line()

func _end_dialogue():
	active = false
	hide()
	
	# signal to game to start boss fight
	get_tree().call_group("game_controller", "start_boss_fight")
