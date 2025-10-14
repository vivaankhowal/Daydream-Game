extends CharacterBody2D

@export var health: int = 2
@export var damage: int = 2
@export var speed: float = 20.0
@export var gravity: float = 600.0
# -----------------------------
# NODES
# -----------------------------
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var killzone: Area2D = $Killzone
@onready var edge_check: RayCast2D = $EdgeCheck

# -----------------------------
# STATE
# -----------------------------
var dead: bool = false
var hurting: bool = false
var direction: int = -1

signal enemy_died(enemy)

# -----------------------------
# READY
# -----------------------------
func _ready():
	add_to_group("enemies")
	collision_layer = 3
	collision_mask = 1 | 4   # ground + hitboxes

	if anim:
		anim.play("idle")

	if killzone and not killzone.is_connected("body_entered", Callable(self, "_on_Killzone_body_entered")):
		killzone.connect("body_entered", Callable(self, "_on_Killzone_body_entered"))

	if edge_check:
		edge_check.enabled = true
		edge_check.target_position = Vector2(16 * direction, 16)

# -----------------------------
# PHYSICS PROCESS
# -----------------------------
func _physics_process(delta):
	if dead:
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Only move if not hurting
	if not hurting:
		velocity.x = direction * speed
		anim.flip_h = direction < 0

		# Turn around at walls or edges
		if is_on_wall() or (edge_check and not edge_check.is_colliding()):
			direction *= -1
			if edge_check:
				edge_check.target_position.x = 16 * direction
	else:
		# Stop horizontal movement while hurt
		velocity.x = 0

	move_and_slide()

# -----------------------------
# PLAYER COLLISION
# -----------------------------
func _on_killzone_body_entered(body):
	if dead:
		return
	if body.is_in_group("players") and body.has_method("take_damage"):
		body.take_damage(damage)

# -----------------------------
# DAMAGE + DEATH
# -----------------------------
func take_hit(damage: int = 1):
	if dead or hurting:
		return

	hurting = true
	health -= damage
	if health < 0:
		health = 0

	print(name, "took", damage, "damage. HP left:", health)

	# Play hurt animation once if available
	if anim and anim.sprite_frames.has_animation("hurt"):
		anim.play("hurt")

	# If health is gone → die immediately
	if health <= 0:
		die()
		return

	# Small delay to let hurt frame show before returning to idle
	await get_tree().create_timer(0.2).timeout
	if not dead:
		hurting = false
		if anim and anim.sprite_frames.has_animation("idle"):
			anim.play("idle")

# -----------------------------
# DEATH (instant removal)
# -----------------------------
func die():
	if dead:
		return

	dead = true
	print(name, "died!")

	# Optional: play a quick death flash if you have one
	if anim and anim.sprite_frames.has_animation("death"):
		anim.play("death")

	emit_signal("enemy_died", self)
	queue_free()
