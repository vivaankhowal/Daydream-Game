extends CharacterBody2D

@export var health: int = 1
@export var damage: int = 1
@export var speed: float = 40.0
@export var gravity: float = 600.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var killzone: Area2D = $Killzone
@onready var edge_check: RayCast2D = $EdgeCheck

var dead: bool = false
var direction: int = -1

signal enemy_died(enemy)

func _ready():
	add_to_group("enemies")
	if anim:
		anim.play("idle")
	if killzone and not killzone.is_connected("body_entered", Callable(self, "_on_Killzone_body_entered")):
		killzone.connect("body_entered", Callable(self, "_on_Killzone_body_entered"))
	if edge_check:
		edge_check.enabled = true
		edge_check.target_position = Vector2(16 * direction, 16)

func _physics_process(delta):
	if dead:
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	velocity.x = direction * speed
	anim.flip_h = direction < 0
	if is_on_wall() or (edge_check and not edge_check.is_colliding()):
		direction *= -1
		if edge_check:
			edge_check.target_position.x = 16 * direction
	move_and_slide()

func _on_Killzone_body_entered(body):
	if dead:
		return
	if body.is_in_group("players") and body.has_method("take_damage"):
		body.take_damage(damage)

func take_hit(damage: int = 1):
	if dead:
		return
	health -= damage
	print(name, "took", damage, "damage. HP left:", health)
	if anim and anim.sprite_frames.has_animation("hurt"):
		anim.play("hurt")
		await anim.animation_finished
	if health > 0:
		if anim and anim.sprite_frames.has_animation("idle"):
			anim.play("idle")
	else:
		die()

func die():
	if dead:
		return
	dead = true
	if anim and anim.sprite_frames.has_animation("death"):
		anim.play("death")
		await anim.animation_finished
	emit_signal("enemy_died", self)
	queue_free()
