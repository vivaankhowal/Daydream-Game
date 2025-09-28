extends CharacterBody2D

# Health
var health: int = 200
var health_max: int = 200
var health_min: int = 0

# Movement
@export var speed: float = 120.0
@export var gravity: float = 800.0
@export var jump_force: float = -400.0

# Combat
@export var damage: int = 20
@export var attack_range: float = 60.0
@export var attack_cooldown: float = 1.0
var attack_timer: float = 0.0

# References
var player: CharacterBody2D = null
var is_attacking: bool = false
var is_dead: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	# Find player node in the scene
	player = get_tree().current_scene.get_node("Player")
	if player == null:
		print("Warning: Player not found!")


func _physics_process(delta: float) -> void:
	if is_dead or player == null:
		return

	attack_timer -= delta
	velocity.y += gravity * delta

	var to_player = player.global_position - global_position

	# Decide actions
	if is_attacking:
		velocity.x = 0
		anim.play("Attack")
	elif health <= 0:
		die()
	elif to_player.length() <= attack_range and attack_timer <= 0:
		attack()
	elif to_player.length() <= 400:  # Chase range
		# Move toward player
		velocity.x = sign(to_player.x) * speed
		anim.play("Run")
		# Jump if player is higher
		if to_player.y < -16 and is_on_floor():
			velocity.y = jump_force
	else:
		velocity.x = 0
		anim.play("Idle")

	move_and_slide()


func attack() -> void:
	is_attacking = true
	attack_timer = attack_cooldown
	print("Boss attacking!")  # Placeholder for attack logic (deal damage)
	anim.play("Attack")

	# Simulate attack duration
	await get_tree().create_timer(0.5).timeout
	is_attacking = false


func take_damage(amount: int) -> void:
	if is_dead:
		return
	health -= amount
	if health > 0:
		anim.play("Damage")
	else:
		die()


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	anim.play("Death")
	await anim.animation_finished
	queue_free()
