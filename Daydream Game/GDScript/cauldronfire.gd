extends Node2D
# Called when the node enters the scene tree for the first time.

func _ready():
	# Get the AnimatedSprite2D child and start playing the "fire" animation
	$AnimatedSprite2D.play("loop")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
