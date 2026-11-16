extends Camera3D

@export var target_player: Node3D
@export var target_opponent: Node3D

@export var min_distance: float = 2.8
@export var max_distance: float = 6.0
@export var base_height: float = 1.6
@export var follow_speed: float = 8.0

var trauma: float = 0.0
var max_shake_offset: float = 0.18

func _process(delta: float) -> void:
	if not is_instance_valid(target_player) or not is_instance_valid(target_opponent):
		return
		
	var pos_p1 = target_player.global_position
	var pos_p2 = target_opponent.global_position
	
	# Midpoint between the two fighters
	var midpoint = (pos_p1 + pos_p2) * 0.5
	midpoint.y += base_height
	
	# Fighter separation distance
	var fighter_dist = pos_p1.distance_to(pos_p2)
	var cam_dist = clamp(fighter_dist * 0.85 + 1.8, min_distance, max_distance)
	
	# UFC 3 Broadcast Angle: perpendicular to the fighter line
	var fight_line = (pos_p2 - pos_p1).normalized()
	fight_line.y = 0.0
	var perp_dir = Vector3(-fight_line.z, 0.0, fight_line.x).normalized()
	
	# Maintain side consistency
	var current_vec = (global_position - midpoint)
	current_vec.y = 0.0
	if current_vec.dot(perp_dir) < 0.0:
		perp_dir = -perp_dir
		
	var desired_cam_pos = midpoint + perp_dir * cam_dist
	desired_cam_pos.y = midpoint.y + (cam_dist * 0.22)
	
	# Smooth follow
	global_position = global_position.lerp(desired_cam_pos, follow_speed * delta)
	
	# Always look at the chest/head level of the midpoint
	var look_at_pt = midpoint + Vector3(0, 0.1, 0)
	look_at(look_at_pt, Vector3.UP)
	
	# Trauma shake on impacts
	if trauma > 0.0:
		trauma = max(0.0, trauma - delta * 3.0)
		var shake = trauma * trauma
		h_offset = randf_range(-1.0, 1.0) * max_shake_offset * shake
		v_offset = randf_range(-1.0, 1.0) * max_shake_offset * shake
	else:
		h_offset = 0.0
		v_offset = 0.0

func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)
