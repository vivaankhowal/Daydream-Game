extends CanvasLayer

@onready var health_bar1: Sprite2D = $HealthBar1
@onready var health_bar2: Sprite2D = $HealthBar2

const MAX_HEALTH := 7  # adjust if needed

func update_health1(value: int):
	value = clamp(value, 0, MAX_HEALTH)
	# Sprite frame 0 = full health, frame 5 = empty (reverse if needed)
	var frame_index = MAX_HEALTH - value
	health_bar1.frame = frame_index

func update_health2(value: int):
	value = clamp(value, 0, MAX_HEALTH)
	# Sprite frame 0 = full health, frame 5 = empty (reverse if needed)
	var frame_index = MAX_HEALTH - value
	health_bar2.frame = frame_index
