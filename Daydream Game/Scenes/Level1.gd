extends Node2D

@onready var door = $Door
@onready var boss_spawn_point: Marker2D = $BossSpawnPoint
@export var boss_scene: PackedScene   # assign big_mouth.tscn

var enemies: Array = []
var boss_spawned: bool = false

func _ready():
	enemies = get_tree().get_nodes_in_group("enemies")
	print("Level started with", enemies.size(), "enemies.")

func _process(delta):
	if enemies.size() > 0:
		enemies = enemies.filter(
			func(e):
				return is_instance_valid(e) and not e.dead
		)

	# All small enemies gone → spawn boss
	if enemies.size() == 0 and not boss_spawned:
		_spawn_boss()

	# Door only opens once boss is dead
	if boss_spawned and enemies.size() == 0 and not door.is_open:
		door.open_door()

func _spawn_boss():
	if not boss_scene or not boss_spawn_point:
		push_warning("Boss scene or spawn point not set!")
		return

	boss_spawned = true
	var boss = boss_scene.instantiate()
	boss.global_position = boss_spawn_point.global_position
	add_child(boss)

	# Add boss back into enemies array
	if boss.is_in_group("enemies"):
		enemies.append(boss)

	print("Boss spawned at", boss.global_position)

	# Trigger cinematic intro
	var cam = get_viewport().get_camera_2d()
	if cam:
		cam.start_boss_intro(boss)
