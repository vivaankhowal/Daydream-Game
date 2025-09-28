extends AnimatedSprite2D

@export var health: int = 3
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func take_hit(damage: int = 1):
	health -= damage
	print(name, "took", damage, "damage. Health left:", health)

	if health <= 0:
		die()

func die():
	print(name, "died")
	if anim and anim.sprite_frames.has_animation("death"):
		anim.play("death")
		await anim.animation_finished
	queue_free()
