extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D
@onready var interact_label: Label = $Label   # make sure it's named "Label"

var is_open: bool = false
var player_in_range: bool = false

func _ready():
	anim.play("closed")
	interact_label.visible = false
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func open_door():
	if not is_open:
		is_open = true
		anim.play("open")

func _process(delta):
	if is_open and player_in_range:
		interact_label.visible = true
		if Input.is_action_just_pressed("interact"):
			go_to_next_level()
	else:
		interact_label.visible = false

func _on_body_entered(body):
	if body.is_in_group("players"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("players"):
		player_in_range = false

func go_to_next_level():
	print("Loading next level...")
	get_tree().change_scene_to_file("res://Level2.tscn")
