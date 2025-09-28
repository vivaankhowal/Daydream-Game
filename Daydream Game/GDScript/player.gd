extends CharacterBody2D

# -----------------------------
# CONSTANTS
# -----------------------------
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const MAX_HEALTH = 5

# Roll tuning
const ROLL_SPEED = 120.0
const ROLL_DURATION = 0.4  # seconds

# Knockback tuning
const KNOCKBACK_X = 80.0
const KNOCKBACK_Y = -60.0

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
	attack_hitbox.monitoring = false   # off until attacking
	attack_shape.disabled = false      # shape must always be enabled!
	print("Main anims:", anim.sprite_frames.get_animation_names())

	# Add roll timer
	roll_timer = Timer.new()
	roll_timer.one_shot = true
	roll_timer.wait_time = ROLL_DURATION
	add_child(roll_timer)
	roll_timer.connect("timeout", Callable(self, "_end_roll"))

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
	if Input.is_action_just_pressed("p1_up") and is_on_floor() and not rolling:
		velocity.y = JUMP_VELOCITY
		anim.play("jump")

	# Roll
	if Input.is_action_just_pressed("p1_roll") and not rolling:
		start_roll()

	# Attack
	if Input.is_action_just_pressed("p1_attack") and not rolling:
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
	anim.play("roll")   # roll anim can loop
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

		# ✅ Enable attack hitbox
		attack_hitbox.monitoring = true
		attack_shape.disabled = false   # make sure shape is on
		

func _on_attack_hitbox_body_entered(body):
	print("Hitbox touched:", body.name, " Groups:", body.get_groups())
	if body.is_in_group("enemies"):
		if body.has_method("take_hit"):
			print("Damaging enemy")
			body.take_hit(1)

# -----------------------------
# DAMAGE + DEATH
# -----------------------------
func take_damage(amount: int = 1):
	if invulnerable or dead:
		return

	health -= amount
	print(name, "took damage! Hearts left:", health)

	if anim.sprite_frames and anim.sprite_frames.has_animation("hurt"):
		anim.play("hurt")
		hurting = true

	# Knockback
	if facing_right:
		velocity = Vector2(-KNOCKBACK_X, KNOCKBACK_Y)
	else:
		velocity = Vector2(KNOCKBACK_X, KNOCKBACK_Y)

	set_collision_mask_value(2, false)
	invulnerable = true
	invuln_timer.start()

	if health <= 0:
		die()

func die():
	if dead:
		return
	dead = true
	print(name, "died!")

	set_physics_process(false)
	velocity = Vector2.ZERO
	rolling = false
	hurting = false

	if anim.sprite_frames and anim.sprite_frames.has_animation("death"):
		anim.play("death")
		await anim.animation_finished

	visible = false
	collision.disabled = true

# -----------------------------
# SIGNAL CALLBACKS
# -----------------------------
func _on_timer_timeout():
	if dead:
		return
	invulnerable = false
	set_collision_mask_value(2, true)

func _on_AnimatedSprite2D_animation_finished():
	if anim.animation == "hurt":
		hurting = false
	elif hit_anim.animation == "hit":
		hit_anim.visible = false
		attack_hitbox.monitoring = false
		print("Attack hitbox disabled")

func _on_hit_sprite_animation_finished():
	if hit_anim.animation == "hit":
		hit_anim.visible = false

		# ✅ Disable hitbox as soon as swing ends
		attack_hitbox.monitoring = false
		attack_shape.disabled = true
		print("Attack hitbox disabled")

