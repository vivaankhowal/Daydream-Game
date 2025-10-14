extends Area2D

@export var damage: int = 1

func _ready():
	collision_layer = 4
	collision_mask = 2   # detect player only
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node):
	print("KillZone touched:", body.name)
	if body.is_in_group("players") and body.has_method("take_damage"):
		body.take_damage(damage)
