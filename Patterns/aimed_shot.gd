extends BulletPattern
class_name AimedPattern

@export var bullet_scene: PackedScene
@export var speed := 200
@export var cooldown := 0.5

var timer := 0.0

func start(enemy):
	#print("AimedPattern start called")
	timer = 0.0

func update(enemy, delta):
	timer += delta
	#print("AimedPattern updating | delta =", delta, "| timer =", timer, "| cooldown =", cooldown)

	if timer >= cooldown:
		#print("FIRING")
		fire(enemy)
		timer = 0.0

func fire(enemy):
	#print("fire() called")

	if bullet_scene == null:
		print("bullet_scene is NULL")
		return

	var player = enemy.get_tree().get_root().find_child("Player", true, false)
	if player == null:
		print("NO PLAYER FOUND")
		return

	var dir = (player.global_position - enemy.global_position).normalized()
	#print("Spawning bullet")
	BulletSpawner.spawn_bullet(bullet_scene, enemy, dir, speed)
