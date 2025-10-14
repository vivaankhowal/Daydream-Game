extends Area2D

var player_inside: Node = null
@onready var prompt: Label = $PromptLabel

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt.visible = false

func _on_body_entered(body):
	if body.name == "Player1" or body.name == "Player2":
		player_inside = body
		prompt.visible = true

func _on_body_exited(body):
	if body == player_inside:
		player_inside = null
		prompt.visible = false

func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		interact()
		
func interact():
	get_tree().change_scene_to_file("res://Scenes/Level1.tscn")
