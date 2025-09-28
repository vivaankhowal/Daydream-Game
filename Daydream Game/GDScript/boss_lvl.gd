extends Node2D

@export var boss_scene: PackedScene
@onready var boss_spawn_point: Marker2D = $BossSpawnPoint

var boss: Node = null
var boss_spawned: bool = false

func _ready():
	_spawn_boss()

func _spawn_boss():
	if not boss_scene or not boss_spawn_point:
		push_warning("Boss scene or spawn point not set!")
		return

	boss = boss_scene.instantiate()
	boss.global_position = boss_spawn_point.global_position
	add_child(boss)
	boss_spawned = true

	print("Boss spawned at: ", boss.global_position)

	var cam: Camera2D = get_viewport().get_camera_2d()
	if cam:
		cam.start_boss_intro([get_node("Player1"), get_node("Player2")], boss, $TileMap.get_used_rect())

