extends Label


func _ready():
	hide()


func connect_boss(boss):
	boss.spell_started.connect(show_timer)
	boss.spell_timer_updated.connect(update_timer)
	boss.spell_ended.connect(hide_timer)


func show_timer(time):
	show()
	update_timer(time)


func update_timer(time):
	text = "%.1f" % time


func hide_timer():
	hide()
