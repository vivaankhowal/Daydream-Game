extends CharacterBody2D

# ----------------------
# CONFIG
# ----------------------
@export var health: int = 3   # slime HP (change per enemy)
@export var damage: int = 1   # how much damage it does to the player

# ----------------------
# NODES
# ----------------------
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var killzone: Area2D = $Killzone

# ----------------------
# READY
# ----------------------
func _ready():
	add_to_group("enemies")  # so Player hitbox can find it
	if killzone and not killzone.is_connected("body_entered", Callable(self, "_on_Killzone_body_entered")):
		killzone.connect("body_entered", Callable(self, "_on_Killzone_body_entered"))
	print(name, "is ready with HP:", health)

# ----------------------
# KILLZONE → damages players
# ----------------------
func _on_killzone_body_entered(body):
	print("Killzone touched:", body.name, " Groups:", body.get_groups())
	if body.is_in_group("players"):
		if body.has_method("take_damage"):
			print(name, "is damaging", body.name)
			body.take_damage(damage)

# ----------------------
# TAKE DAMAGE → called by Player attack
# ----------------------
func take_hit(damage: int = 1):
	health -= damage
	print(name, "took", damage, "damage. HP left:", health)

	if anim and anim.sprite_frames.has_animation("hurt"):
		anim.play("hurt")

	if health <= 0:
		die()

# ----------------------
# DEATH
# ----------------------
func die():
	print(name, "died!")
	if anim and anim.sprite_frames.has_animation("death"):
		anim.play("death")
		await anim.animation_finished
	queue_free()
