extends Camera2D

@export var player1_path: NodePath
@export var player2_path: NodePath

@export var min_zoom: float = 3.5   # normal zoom
@export var max_zoom: float = 3.0   # zoomed out
@export var max_distance: float = 400.0  # distance at which camera fully zooms out
@export var smooth_speed: float = 5.0    # camera smoothing speed

func _process(delta):
	var p1_node = get_node_or_null(player1_path)
	var p2_node = get_node_or_null(player2_path)
	if not p1_node and not p2_node:
		return  # no players to track

	var alive_players: Array = []
	if p1_node and not p1_node.dead:
		alive_players.append(p1_node)
	if p2_node and not p2_node.dead:
		alive_players.append(p2_node)

	if alive_players.size() == 0:
		return  # no alive players, do nothing

	elif alive_players.size() == 1:
		# Follow only the live player
		var target_pos = alive_players[0].global_position
		global_position = global_position.lerp(target_pos, delta * smooth_speed)
		zoom = zoom.lerp(Vector2.ONE * min_zoom, delta * smooth_speed)

	else:
		# Both alive: midpoint + dynamic zoom
		var p1 = p1_node.global_position
		var p2 = p2_node.global_position

		# Midpoint
		var midpoint = (p1 + p2) / 2.0
		global_position = global_position.lerp(midpoint, delta * smooth_speed)

		# Distance-based zoom
		var distance = p1.distance_to(p2)
		var t = clamp(distance / max_distance, 0.0, 1.0)
		var target_zoom = Vector2.ONE * lerp(min_zoom, max_zoom, t)
		zoom = zoom.lerp(target_zoom, delta * smooth_speed)
