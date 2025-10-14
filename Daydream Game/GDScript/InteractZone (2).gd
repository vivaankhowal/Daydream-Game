extends Area2D

var player_inside: Node = null
@export var next_level: PackedScene   # drag Level2.tscn in the Inspector
@export var require_open: bool = true # if true, needs door open before interacting

var is_open: bool = false  # controlled externally if needed

func _ready():
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("players"):
		player_inside = body

func _on_body_exited(body):
	if body == player_inside:
		player_inside = null

func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		if not require_open or is_open:
			interact()

func interact():
	if next_level:
		print("Loading next level...")
		get_tree().change_scene_to_packed(next_level)
