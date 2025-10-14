extends AnimatedSprite2D  # or AnimatedSprite if using Godot 3.x

func _ready():
	$AnimatedSprite2D.play("loop")  # replace "fire" with your animation name
