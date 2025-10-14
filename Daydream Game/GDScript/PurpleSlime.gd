extends CharacterBody2D

# -----------------------------
# EXPORTS
# -----------------------------
@export var health: int = 3
@export var damage: int = 1
@export var speed: float = 30.0     # patrol speed
@export var gravity: float = 600.0  # gravity strength

# -----------------------------
# NODES
# -----------------------------
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var killzone: Area2D = $Killzone
@onready var edge_check: RayCast2D = $EdgeCheck   # add in scene

# -----------------------------
# VARIABLES
# -----------------------------
var dead: bool = false
var direction: int = -1   # -1 = left, 1 = right

# -----------------------------
# SIGNALS
# -----------------------------
signal enemy_died(enemy)

# -----------------------------
# READY
# -----------------------------
func _ready():
	add_to_group("enemies")
	if anim:
		anim.play("idle")

	if killzone and not killzone.is_connected("body_entered", Callable(self, "_on_Killzone_body_entered")):
		killzone.connect("body_entered", Callable(self, "_on_Killzone_body_entered"))

	# RayCast2D setup (Godot 4)
	if edge_check:
		edge_check.enabled = true
		edge_check.target_position = Vector2(16 * direction, 16)  # look ahead + down

# -----------------------------
# PHYSICS PROCESS (patrol logic)
# -----------------------------
func _physics_process(delta):
	if dead:
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Movement
	velocity.x = direction * speed
	anim.flip_h = direction < 0

	# Turn if wall OR no ground ahead
	if is_on_wall() or (edge_check and not edge_check.is_colliding()):
		direction *= -1
		if edge_check:
			edge_check.target_position.x = 16 * direction   # flip ray direction

	move_and_slide()

# -----------------------------
# COLLISION DAMAGE
# -----------------------------
func _on_killzone_body_entered(body):
	if dead:
		return
	if body.is_in_group("players") and body.has_method("take_damage"):
		body.take_damage(damage)

# -----------------------------
# TAKING DAMAGE
# -----------------------------
func take_hit(damage: int = 1):
	if dead:
		return
	health -= damage

	if anim and anim.sprite_frames.has_animation("hurt"):
		anim.play("hurt")
		await anim.animation_finished

	if health > 0:
		if anim and anim.sprite_frames.has_animation("idle"):
			anim.play("idle")
	else:
		die()

# -----------------------------
# DEATH
# -----------------------------
func die():
	if dead:
		return
	dead = true

	if anim and anim.sprite_frames.has_animation("death"):
		anim.play("death")
		await anim.animation_finished

	emit_signal("enemy_died", self)
	queue_free()
