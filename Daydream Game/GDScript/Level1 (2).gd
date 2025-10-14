extends Node2D

# ---------------------------
# ONREADY VARIABLES
# ---------------------------
@onready var door = $Door
@onready var post_process = $PostProcess  # 🔥 for grayscale effect
@onready var camera: Camera2D = $Camera2D
@onready var game_over_skull_scene: PackedScene = preload("res://Scenes/game_over_skull.tscn")


# ---------------------------
# EXPORT VARIABLES
# ---------------------------
@export var boss_scene: PackedScene   # assign big_mouth.tscn in editor

# ---------------------------
# STATE VARIABLES
# ---------------------------
var enemies: Array = []
var boss_spawned: bool = false
var players_alive: int = 2   # update if you add more players

# ---------------------------
# READY
# ---------------------------
func _ready():
	enemies = get_tree().get_nodes_in_group("enemies")
	print("Level started with", enemies.size(), "enemies.")

	# Connect player death signals
	var player1 = get_node_or_null("Player1")
	var player2 = get_node_or_null("Player2")

	if player1 and player1.has_signal("player_died"):
		player1.connect("player_died", Callable(self, "_on_player_died"))
	if player2 and player2.has_signal("player_died"):
		player2.connect("player_died", Callable(self, "_on_player_died"))

# ---------------------------
# PROCESS
# ---------------------------
func _process(delta):
	if enemies.size() > 0:
		enemies = enemies.filter(
			func(e):
				return is_instance_valid(e) and not e.dead
		)

	# All small enemies gone → spawn boss
	if enemies.size() == 0:
		door.open_door()

# ---------------------------

# ---------------------------
# PLAYER DEATH HANDLING
# ---------------------------
func _on_player_died():
	players_alive -= 1
	print("Player died! Remaining alive:", players_alive)

	if players_alive <= 0:
		print("All players dead — triggering full game over sequence")

		var last_dead = null
		var player1 = get_node_or_null("Player1")
		var player2 = get_node_or_null("Player2")

		if player1 and player1.dead:
			last_dead = player1
		elif player2 and player2.dead:
			last_dead = player2

		# Freeze world
		get_tree().paused = true

		# Hide HUD (autoload)
		if HUD:
			HUD.visible = false

		# Fade to grayscale (fast)

		# Let dying player still animate
# Fade to grayscale (fast)
# Fade to grayscale (fast)
		post_process.fade_to_grayscale(0.5)

# Wait for the fade to complete + 1s delay for drama
# Let dying player still animate
		if last_dead:
			last_dead.process_mode = Node.PROCESS_MODE_ALWAYS
			last_dead.play_death_after_fade()

		await get_tree().create_timer(2.0).timeout

# ✅ Now spawn the red skull overlay
		var skull = game_over_skull_scene.instantiate()
		get_tree().root.add_child(skull)
		skull.play_skull_animation()
