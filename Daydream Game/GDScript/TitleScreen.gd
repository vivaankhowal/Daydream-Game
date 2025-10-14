extends CanvasLayer

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var start_button: Button = $VBoxContainer/Start
@onready var exit_button: Button = $VBoxContainer/Exit

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	anim.play("fade_in")

	start_button.pressed.connect(_on_start_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_start_pressed():
	anim.play("fade_out")
	await anim.animation_finished
	if get_tree():
		get_tree().change_scene_to_file("res://Scenes/VariationLevel1.tscn")
	else:
		print("Error: Scene tree not available yet")


func _on_exit_pressed():
	get_tree().quit()
