extends Node2D

@export var next_level: PackedScene

@onready var interact_area: Area2D = $InteractZone
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var is_open: bool = false
var player_inside: bool = false

func _ready():
	if interact_area:
		interact_area.monitoring = true
		# Connect to area_2d-style methods
		interact_area.body_entered.connect(_on_area_2d_body_entered)
		interact_area.body_exited.connect(_on_area_2d_body_exited)
	else:
		push_error("⚠️ InteractZone node not found under Door!")

func open_door():
	if not is_open:
		is_open = true
		print("Level 1 door opened!")
		if anim and anim.sprite_frames.has_animation("open"):
			anim.play("open")

		# If player already inside trigger, mark them
		for body in interact_area.get_overlapping_bodies():
			if body.is_in_group("players"):
				player_inside = true
				break

func _process(delta):
	if is_open and player_inside and Input.is_action_just_pressed("interact"):
		if next_level:
			print("Loading Level 2...")
			get_tree().change_scene_to_packed(next_level)

# -----------------------------
# Signal callbacks (area_2d style)
# -----------------------------
func _on_area_2d_body_entered(body):
	if body.is_in_group("players"):
		player_inside = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("players"):
		player_inside = false
