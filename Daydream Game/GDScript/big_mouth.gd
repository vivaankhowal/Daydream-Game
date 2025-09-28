extends CharacterBody2D

# -----------------------------
# CONFIG
# -----------------------------
@export var health: int = 6
@export var damage: int = 2
@export var speed: float = 70.0
@export var gravity: float = 600.0
@export var jump_force: float = -300.0
@export var jump_check_distance: float = 24.0
@export var left_bound: float = -9999.0   # set these in Inspector
@export var right_bound: float = 9999.0

# Target logic
# -1 = auto (closest alive player)
#  0 = always chase Player1
#  1 = always chase Player2
@export var target_player_index: int = -1

# -----------------------------
# NODES
# -----------------------------
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var killzone: Area2D = $Killzone

# -----------------------------
# STATE
# -----------------------------
var dead: bool = false
var target: Node = null
var flinching: bool = false   # blocks AI briefly when hit

# -----------------------------
# READY
# -----------------------------
func _ready():
	add_to_group("enemies")
	if anim and anim.sprite_frames.has_animation("idle"):
		anim.play("idle")

	if killzone and not killzone.is_connected("body_entered", Callable(self, "_on_killzone_body_entered")):
		killzone.connect("body_entered", Callable(self, "_on_killzone_body_entered"))

# -----------------------------
# PHYSICS
# -----------------------------
func _physics_process(delta):
	if dead:
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if not flinching:
		# Find target and chase
		_find_target()

		if target:
			var dir = sign(target.global_position.x - global_position.x)
			velocity.x = dir * speed
			anim.flip_h = dir < 0

			# Jump if target is higher
			if is_on_floor() and target.global_position.y < global_position.y - jump_check_distance:
				velocity.y = jump_force
				if anim.sprite_frames.has_animation("jump"):
					anim.play("jump")
			elif anim.sprite_frames.has_animation("run") and anim.animation != "run":
				anim.play("run")
		else:
			velocity.x = 0
			if anim.sprite_frames.has_animation("idle") and anim.animation != "idle":
				anim.play("idle")

	move_and_slide()

	# Clamp to borders so it never leaves level
	global_position.x = clamp(global_position.x, left_bound, right_bound)

# -----------------------------
# TARGET FINDING
# -----------------------------
func _find_target():
	var players = get_tree().get_nodes_in_group("players")

	# If manually assigned to a player
	if target_player_index >= 0 and target_player_index < players.size():
		var forced_target = players[target_player_index]
		if forced_target and is_instance_valid(forced_target) and not forced_target.dead:
			target = forced_target
			return

	# Otherwise chase closest alive player
	var closest_dist = INF
	target = null
	for p in players:
		if p and is_instance_valid(p) and not p.dead:
			var dist = global_position.distance_to(p.global_position)
			if dist < closest_dist:
				closest_dist = dist
				target = p

# -----------------------------
# DAMAGE TO PLAYERS
# -----------------------------
func _on_killzone_body_entered(body):
	if dead:
		return
	if body.is_in_group("players") and body.has_method("take_damage"):
		body.take_damage(damage)

# -----------------------------
# TAKING DAMAGE (with flinch)
# -----------------------------
func take_hit(amount: int = 1, knockback_dir: int = 0):
	if dead:
		return
	health -= amount
	print(name, "took", amount, "damage. HP left:", health)

	# Flinch knockback
	flinching = true
	velocity.x = knockback_dir * 150   # short push
	velocity.y = -100                  # little hop

	if anim and anim.sprite_frames.has_animation("hurt"):
		anim.play("hurt")

	# Resume AI after short delay
	await get_tree().create_timer(0.25).timeout
	flinching = false

	if health <= 0:
		die()
	elif anim.sprite_frames.has_animation("idle"):
		anim.play("idle")

# -----------------------------
# DEATH
# -----------------------------
func die():
	if dead:
		return
	dead = true
	print(name, "died!")
	if anim and anim.sprite_frames.has_animation("death"):
		anim.play("death")
		await anim.animation_finished
	queue_free()
