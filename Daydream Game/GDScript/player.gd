extends CharacterBody2D

# -----------------------------
# CONSTANTS
# -----------------------------
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const MAX_HEALTH = 7

# Roll tuning
const ROLL_SPEED = 120.0
const ROLL_DURATION = 0.4  # seconds

# Knockback tuning
const KNOCKBACK_X = 80.0
const KNOCKBACK_Y = -60.0

signal player_died
# -----------------------------
# VARIABLES
# -----------------------------
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_right: bool = true
var rolling: bool = false
var roll_vector: Vector2 = Vector2.ZERO
var health: int = MAX_HEALTH
var invulnerable: bool = false
var hurting: bool = false
var dead: bool = false

# -----------------------------
# NODES
# -----------------------------
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_anim: AnimatedSprite2D = $HitSprite
@onready var attack_hitbox: Area2D = $HitSprite/AttackHitbox
@onready var attack_shape: CollisionShape2D = $HitSprite/AttackHitbox/CollisionShape2D
@onready var invuln_timer: Timer = $Timer
@onready var collision: CollisionShape2D = $CollisionShape2D
var roll_timer: Timer

# -----------------------------
# READY
# -----------------------------
func _ready():
	add_to_group("players")
	collision_layer = 2
	collision_mask = 1 | 4   # ground + hitboxes

	attack_hitbox.monitoring = false   # off until attacking
	attack_shape.disabled = false      # shape must always be enabled!

	print("Main anims:", anim.sprite_frames.get_animation_names())

	# Add roll timer
	roll_timer = Timer.new()
	roll_timer.one_shot = true
	roll_timer.wait_time = ROLL_DURATION
	add_child(roll_timer)
	roll_timer.connect("timeout", Callable(self, "_end_roll"))

	# ✅ Connect hitbox signal safely
	if attack_hitbox and not attack_hitbox.is_connected("body_entered", Callable(self, "_on_attack_hitbox_body_entered")):
		attack_hitbox.connect("body_entered", Callable(self, "_on_attack_hitbox_body_entered"))

# -----------------------------
# PHYSICS PROCESS
# -----------------------------
func _physics_process(delta):
	if dead:
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("p1_up") and is_on_floor() and not rolling and not hurting:
		velocity.y = JUMP_VELOCITY
		anim.play("jump")

	# Roll
	if Input.is_action_just_pressed("p1_roll") and not rolling and not hurting:
		start_roll()

	# Attack
	if Input.is_action_just_pressed("p1_attack") and not rolling and not hurting:
		play_hit()

	# Movement
	if not rolling:
		var direction = Input.get_axis("p1_left", "p1_right")
		if direction != 0:
			velocity.x = direction * SPEED
			facing_right = direction > 0
			anim.flip_h = not facing_right

			# Flip attack hitbox
			var offset = attack_shape.position
			offset.x = abs(offset.x) * (1 if facing_right else -1)
			attack_shape.position = offset

			if is_on_floor() and not Input.is_action_pressed("p1_attack") and not hurting:
				anim.play("run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor() and not Input.is_action_pressed("p1_attack") and not hurting:
				anim.play("idle")
	else:
		velocity.x = roll_vector.x * ROLL_SPEED

	move_and_slide()

# -----------------------------
# ROLL
# -----------------------------
func start_roll():
	rolling = true
	anim.play("roll")
	roll_vector = Vector2.RIGHT if facing_right else Vector2.LEFT
	roll_timer.start()

func _end_roll():
	rolling = false

# -----------------------------
# ATTACK
# -----------------------------
func play_hit():
	if hit_anim:
		hit_anim.visible = true
		hit_anim.z_index = 1
		hit_anim.flip_h = not facing_right

		# Flip position
		var pos = hit_anim.position
		pos.x = abs(pos.x) * (1 if facing_right else -1)
		hit_anim.position = pos

		hit_anim.play("hit")

		# Enable attack hitbox
		attack_hitbox.monitoring = true
		attack_shape.disabled = false

func _on_attack_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_hit"):
			print("Damaging enemy:", body.name)
			body.take_hit(1)
			# Prevent multi-hit spam
			attack_hitbox.monitoring = false

# -----------------------------
# DAMAGE + DEATH
# -----------------------------
func take_damage(amount: int = 1):
	# After health is changed
	if invulnerable or dead or hurting:
		return

	hurting = true
	health -= amount
	HUD.update_health1(health)
	if health < 0:
		health = 0

	print(name, "took", amount, "damage! Hearts left:", health)

	# Play hurt animation
	if anim.sprite_frames.has_animation("hurt"):
		anim.play("hurt")

	# Knockback
	if facing_right:
		velocity = Vector2(-KNOCKBACK_X, KNOCKBACK_Y)
	else:
		velocity = Vector2(KNOCKBACK_X, KNOCKBACK_Y)

	# Temporary invulnerability
	invulnerable = true
	invuln_timer.start()

	# Small hurt cooldown (prevents rapid overlap)
	await get_tree().create_timer(0.35).timeout
	hurting = false

	# Resume idle if alive
	if not dead and is_on_floor():
		anim.play("idle")

	if health <= 0:
		die()

func die():
	if dead:
		return
	dead = true
	emit_signal("player_died")
	print(name, "died!")

	# Stop all active movement / actions
	set_physics_process(false)
	velocity = Vector2.ZERO
	rolling = false
	hurting = false

	# Play death animation first
	if anim.sprite_frames.has_animation("death"):
		anim.play("death")
		await anim.animation_finished  # wait until death animation ends

	# Once animation is done → hide & disable collisions
	visible = false
	collision.disabled = true
	queue_free()  # completely remove from scene


# -----------------------------
# SIGNAL CALLBACKS
# -----------------------------
func _on_timer_timeout():
	if dead:
		return
	invulnerable = false
	set_collision_mask_value(2, true)

func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "hurt":
		hurting = false
		if not dead and not rolling:
			anim.play("idle")

	if hit_anim.animation == "hit":
		hit_anim.visible = false
		attack_hitbox.monitoring = false
		print("Attack hitbox disabled")

func _on_hit_sprite_animation_finished():
	if hit_anim.animation == "hit":
		hit_anim.visible = false
		attack_hitbox.monitoring = false
		attack_shape.disabled = true
		print("Attack hitbox disabled")

func play_death_after_fade():
	if dead:
		return

	dead = true
	print(name, "playing death animation after fade")

	# Ensure this player still processes while game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Disable input & movement
	set_physics_process(false)
	velocity = Vector2.ZERO

	# Play death animation
	if anim and anim.sprite_frames.has_animation("death"):
		anim.play("death")
		await anim.animation_finished

	# Hide after animation completes
	visible = false

	# Optional: reset process mode
	process_mode = Node.PROCESS_MODE_INHERIT
