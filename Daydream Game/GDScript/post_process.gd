extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
# Makes the world fade smoothly to grayscale
func fade_to_grayscale(duration: float = 2.0):
	if not color_rect.material:
		return
	
	var tween = create_tween()
	tween.tween_property(
		color_rect.material,
		"shader_parameter/desaturate",
		1.0,
		duration
	)
func reset_grayscale():
	if color_rect.material:
		color_rect.material.set_shader_parameter("desaturate", 0.0)
