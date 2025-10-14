extends Node2D

@onready var spawn_point = $SpawnPoint

func _ready():
	spawn_players()

func spawn_players():
	# Use exact paths from FileSystem
	var player1_scene = load("res://Scenes/Player.tscn")
	var player2_scene = load("res://Scenes/Player2.tscn")

	var player1 = player1_scene.instantiate()
	var player2 = player2_scene.instantiate()

	player1.global_position = spawn_point.global_position + Vector2(-16, 0)
	player2.global_position = spawn_point.global_position + Vector2(16, 0)

	add_child(player1)
	add_child(player2)
