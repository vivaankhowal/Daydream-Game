extends Camera2D

@export var min_zoom: float = 3.5
@export var max_zoom: float = 3.0
@export var max_distance: float = 400.0
@export var smooth_speed: float = 5.0
@export var boss_zoom: float = 2.0
@export var boss_hold_time: float = 2.0   # seconds to hold on boss before returning

var live_players: Array[Node] = []
signal death_cinematic_done

var boss_intro_mode: bool = false
var boss_target: Node = null
var boss_timer: float = 0.0

func _ready():
	_refresh_players()
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)

func _process(delta):
	live_players = live_players.filter(func(p): return is_instance_valid(p) and not p.dead)

	if live_players.size() == 0:
		return

	# --- Normal behavior ---
	if live_players.size() == 1:
		var target = live_players[0].global_position
		global_position = global_position.lerp(target, delta * smooth_speed)
		zoom = zoom.lerp(Vector2.ONE * min_zoom, delta * smooth_speed)
	else:
		var midpoint = _get_midpoint()
		global_position = global_position.lerp(midpoint, delta * smooth_speed)

		var max_dist = 0.0
		for i in live_players.size():
			for j in range(i + 1, live_players.size()):
				max_dist = max(max_dist, live_players[i].global_position.distance_to(live_players[j].global_position))

		var t = clamp(max_dist / max_distance, 0.0, 1.0)
		var target_zoom = Vector2.ONE * lerp(min_zoom, max_zoom, t)
		zoom = zoom.lerp(target_zoom, delta * smooth_speed)

# -----------------------------
# Helpers
# -----------------------------
func _refresh_players():
	live_players.clear()
	var players = get_tree().get_nodes_in_group("players")
	for p in players:
		if p and not p.dead:
			live_players.append(p)

func _on_node_added(node):
	if node.is_in_group("players") and not node.dead:
		live_players.append(node)

func _on_node_removed(node):
	if node in live_players:
		live_players.erase(node)

func _get_midpoint() -> Vector2:
	var midpoint = Vector2.ZERO
	for p in live_players:
		midpoint += p.global_position
	return midpoint / live_players.size()

# -----------------------------
# Boss cinematic control
# -----------------------------
func start_boss_intro(boss: Node):
	boss_intro_mode = true
	boss_target = boss
	boss_timer = 0.0

	# Play animation on boss (idle for testing, roar later)
	if boss.has_node("AnimatedSprite2D"):
		var anim: AnimatedSprite2D = boss.get_node("AnimatedSprite2D")
		if anim.sprite_frames.has_animation("idle"):
			anim.play("idle")

func _end_boss_intro():
	boss_intro_mode = false
	boss_target = null
	boss_timer = 0.0

# -----------------------------
# Death cinematic (no zoom)
# -----------------------------
func start_death_cinematic(dead_player: Node):
	if not dead_player or not is_instance_valid(dead_player):
		return

	print("Starting death cinematic on:", dead_player.name)
	
	# Temporarily stop normal camera logic
	boss_intro_mode = true
	boss_target = dead_player
	boss_timer = 0.0

	var target_pos = dead_player.global_position
	var tween = create_tween()

	# Smoothly move camera to the dead player
	tween.tween_property(self, "global_position", target_pos, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished

	# Optional: pause briefly for dramatic effect
	await get_tree().create_timer(0.6).timeout

	# Return control back to normal
	boss_intro_mode = false
	boss_target = null
	boss_timer = 0.0

	emit_signal("death_cinematic_done")
