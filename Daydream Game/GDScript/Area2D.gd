extends Area2D

@export var label: Label

var player_in_range: bool = false

func _ready():
	if label:
		label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta):
	if player_in_range:
		if Input.is_action_just_pressed("interact"):
			print("Player pressed E!")
			# Call your door's go_to_next_level() or emit a signal here

func _on_body_entered(body):
	if body.is_in_group("players"):
		player_in_range = true
		if label:
			label.visible = true

func _on_body_exited(body):
	if body.is_in_group("players"):
		player_in_range = false
		if label:
			label.visible = false
